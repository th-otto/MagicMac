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

/* BIOS level errors */

#define E_OK	  0L	/* OK, no error 		*/
#define ERROR	 -1L	/* basic, fundamental error	*/
#define EDRVNR	 -2L	/* drive not ready		*/
#define EUNCMD	 -3L	/* unknown command		*/
#define E_CRC	 -4L	/* CRC error			*/
#define EBADRQ	 -5L	/* bad request			*/
#define E_SEEK	 -6L	/* seek error			*/
#define EMEDIA	 -7L	/* unknown media		*/
#define ESECNF	 -8L	/* sector not found		*/
#define EPAPER	 -9L	/* no paper			*/
#define EWRITF	-10L	/* write fault			*/
#define EREADF	-11L	/* read fault			*/
#define EGENRL	-12L	/* general error		*/
#define EWRPRO	-13L	/* write protect		*/
#define E_CHNG	-14L	/* media change 		*/
#define EUNDEV	-15L	/* unknown device		*/
#define EBADSF	-16L	/* bad sectors on format	*/
#define EOTHER	-17L	/* insert other disk	*/

/* BDOS level errors */

#define EINVFN	-32L	/* invalid function number		 1 */
#define EFILNF	-33L	/* file not found				 2 */
#define EPTHNF	-34L	/* path not found				 3 */
#define ENHNDL	-35L	/* no handles left				 4 */
#define EACCDN	-36L	/* access denied				 5 */
#define EIHNDL	-37L	/* invalid handle				 6 */
#define ENSMEM	-39L	/* insufficient memory			 8 */
#define EIMBA	-40L	/* invalid memory block address 	 9 */
#define EDRIVE	-46L	/* invalid drive was specified	15 */
#define ENSAME -48L /* MV between two different drives 17 */
#define ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define ERANGE	-64L	/* range error					33 */
#define EINTRN	-65L	/* internal error				34 */
#define EPLFMT	-66L	/* invalid program load format	35 */
#define EGSBF	-67L	/* setblock failure 			36 */

/* KAOS extensions */

#define EBREAK	-68L	/* user break (^C)				37 */
#define EXCPT	-69L	/* 68000- exception ("bombs")		38 */

/* MiNT extensions */

#define ELOCKED -58L
#define ENSLOCK -59L

/*  MagiC extensions */

#define EPTHOV -70L /* path overflow                           MAG!X    */
#define ELOOP  -80L /* too many symlinks in path               MiNT */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */


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


typedef struct			/* Header for executable files */
{
	WORD branch;		/* always == 0x601a */
	LONG tlen;		/* length of TEXT segment */
	LONG dlen;		/* length of DATA segment */
	LONG blen;		/* length of BSS segment */
	LONG slen;		/* length of symbol table */
	LONG res1;		/* unused, must be zero */
	LONG flags;		/* different flags */
	WORD reloflag;		/* if not zero, neither relocate nor clear BSS */
} PH;

#define PH_MAGIC	0x601a					/* value of PH.branch */
#define PHFLAG_DONT_CLEAR_HEAP	0x00000001	/* PH.flags */
#define PHFLAG_LOAD_TO_FASTRAM	0x00000002	/* PH.flags */
#define PHFLAG_MALLOC_FROM_FASTRAM	0x00000004	/* PH.flags */
#define PHFLAG_MINIMAL_RAM		0x00000008	/* PH.flags (MagiC 5.20) */
#define PHFLAG_MEMPROT			0x000000f0	/* PH.flags (MiNT) */
#define PHFLAG_SHARED_TEXT		0x00000800	/* PH.flags (MiNT) */
#define PHFLAG_TPA_SIZE			0xf0000000	/* PH.flags */


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

/* Sconfig(2) -> */

#ifndef _DOSVARS
#define _DOSVARS
typedef struct
   {
   char      *in_dos;                 /* Adresse der DOS- Semaphore */
   int       *dos_time;               /* Adresse der DOS- Zeit      */
   int       *dos_date;               /* Adresse des DOS- Datums    */
   long      res1;                    /*                            */
   long      res2;                    /*                            */
   long      res3;                    /* ist 0L                     */
   void      *act_pd;                 /* Laufendes Programm         */
   long      res4;                    /*                            */
   int       res5;                    /*                            */
   void      *res6;                   /*                            */
   void      *res7;                   /* interne DOS- Speicherliste */
   void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
   long      (*etv_critic)();         /* etv_critic des GEMDOS      */
   char *    ((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
   long      res8;                    /*                            */
   long      res9;                    /*                            */
   long      res10;                   /*                            */
   } DOSVARS;
#endif

/* os_magic -> */

#ifndef _AESVARS
#define _AESVARS
typedef struct
     {
     long magic;                   /* muž $87654321 sein              */
     void *membot;                 /* Ende der AES- Variablen         */
     void *aes_start;              /* Startadresse                    */
     long magic2;                  /* ist 'MAGX'                      */
     long date;                    /* Erstelldatum ttmmjjjj           */
     void (*chgres)(int res, int txt);  /* Aufl”sung „ndern           */
     long (**shel_vector)(void);   /* residentes Desktop              */
     char *aes_bootdrv;            /* von hieraus wurde gebootet      */
     int  *vdi_device;             /* vom AES benutzter VDI-Treiber   */
     void *reservd1;
     void *reservd2;
     void *reservd3;
     int  version;                 /* z.B. $0201 ist V2.1             */
     int  release;                 /* 0=alpha..3=release              */
     } AESVARS;
#endif

/* Cookie MagX --> */

#ifndef _MAGX_COOKIE
#define _MAGX_COOKIE
typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     void *res1;
     void *hddrv_functions;
     long status_bits;             /* MagiC 3 ab 24.5.95         */
     } MAGX_COOKIE;
#endif

/* Bits for <status_bits> in MAGX_COOKIE (read only!) */

#define MGXSTB_TSKMAN_ACTIVE  1    /* MagiC task manager is currently active */

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
