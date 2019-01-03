#ifndef DP_IOPEN
#define DP_IOPEN	0	/* internal limit on # of open files */
#define DP_MAXLINKS	1	/* max number of hard links to a file */
#define DP_PATHMAX	2	/* max path name length */
#define DP_NAMEMAX	3	/* max length of an individual file name */
#define DP_ATOMIC	4	/* # of bytes that can be written atomically */
#define DP_TRUNC	5	/* file name truncation behavior */
#	define	DP_NOTRUNC	0	/* long filenames give an error */
#	define	DP_AUTOTRUNC	1	/* long filenames truncated */
#	define	DP_DOSTRUNC	2	/* DOS truncation rules in effect */
#define DP_CASE		6
#	define	DP_CASESENS	0	/* case sensitive */
#	define	DP_CASECONV	1	/* case always converted */
#	define	DP_CASEINSENS	2	/* case insensitive, preserved */
#define DP_MODEATTR		7
#	define	DP_ATTRBITS	0x000000ffL	/* mask for valid TOS attribs */
#	define	DP_MODEBITS	0x000fff00L	/* mask for valid Unix file modes */
#	define	DP_FILETYPS	0xfff00000L	/* mask for valid file types */
#	define	DP_FT_DIR	0x00100000L	/* directories (always if . is there) */
#	define	DP_FT_CHR	0x00200000L	/* character special files */
#	define	DP_FT_BLK	0x00400000L	/* block special files, currently unused */
#	define	DP_FT_REG	0x00800000L	/* regular files */
#	define	DP_FT_LNK	0x01000000L	/* symbolic links */
#	define	DP_FT_SOCK	0x02000000L	/* sockets, currently unused */
#	define	DP_FT_FIFO	0x04000000L	/* pipes */
#	define	DP_FT_MEM	0x08000000L	/* shared memory or proc files */
#endif
#ifndef DP_XATTRFIELDS
#define DP_XATTRFIELDS 8		/* information about supported extended attributes */
#  define   DP_INDEX    (0x0001)    /* index field unique for every file on the fs */
#  define   DP_DEV      (0x0002)    /* device field valid */
#  define   DP_RDEV     (0x0004)    /* rdev field valid (and not identical to dev) */
#  define   DP_NLINK    (0x0008)    /* number of links valid */
#  define   DP_UID      (0x0010)    /* user id valid */
#  define   DP_GID      (0x0020)    /* group id valid */
#  define   DP_BLKSIZE  (0x0040)    /* block size valid */
#  define   DP_SIZE     (0x0080)    /* size field valid (and meaningful!) */
#  define   DP_NBLOCKS  (0x0100)    /* number of blocks valid */
#  define   DP_ATIME    (0x0200)    /* file system has last access time */
#  define   DP_CTIME    (0x0400)    /* file system has last status change time */
#  define   DP_MTIME    (0x0800)    /* file system has last modification time */
#endif
#define DP_VOLNAMEMAX 9         /* maximum length of a volume name (0 if volume names not supported) */
#define DP_MAXREQ	(-1) /* Dpathconf(-1) */			/* highest legal request */

/**** internal stuff ****/

#define _hz_200 ((long *)0x4ba)

#define get_hz() (*_hz_200)

#ifndef UNUSED
#  define UNUSED(x) (void)(x)
#endif

/*
 * Dont get fooled by C-library header files;
 * we need the kernel values here
 */
#undef S_IFMT
#undef S_IFCHR
#undef S_IFDIR
#undef S_IFREG
#undef S_IFIFO
#undef S_IMEM
#undef S_IFLNK

#ifndef S_IRWXU
/* File types.  */
#define __S_IFSOCK	0010000	/* Socket.  */
#define	__S_IFCHR	0020000	/* Character device.  */
#define	__S_IFDIR	0040000	/* Directory.  */
#define __S_IFBLK	0060000	/* Block device.  */
#define	__S_IFREG	0100000	/* Regular file.  */
#define __S_IFIFO	0120000	/* FIFO.  */
#define __S_IFMEM	0140000 /* memory region or process */
#define	__S_IFLNK	0160000	/* Symbolic link.  */

#define	S_IRUSR	0400	/* Read by owner.  */
#define	S_IWUSR	0200	/* Write by owner.  */
#define	S_IXUSR	0100	/* Execute by owner.  */
/* Read, write, and execute by owner.  */
#define	S_IRWXU	(S_IRUSR|S_IWUSR|S_IXUSR)

#define	S_IRGRP	0040	/* Read by group.  */
#define	S_IWGRP	0020	/* Write by group.  */
#define	S_IXGRP	0010	/* Execute by group.  */
/* Read, write, and execute by group.  */
#define	S_IRWXG	(S_IRWXU >> 3)

#define	S_IROTH	0004	/* Read by others.  */
#define	S_IWOTH	0002	/* Write by others.  */
#define	S_IXOTH	0001	/* Execute by others.  */
/* Read, write, and execute by others.  */
#define	S_IRWXO	(S_IRWXG >> 3)

#endif

#ifndef FALSE
# define FALSE 0
# define TRUE  1
#endif

extern FILESYSTEM const hfs;
extern FILESYSTEM const tocfs;
extern FILESYSTEM const isofs;

extern unsigned long const proc_len;
extern short proc_device;
extern unsigned char proc_track;
extern unsigned char const proc_file[];

extern unsigned long spin_creator;
