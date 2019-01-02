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
