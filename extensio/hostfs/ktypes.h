#include <sys/stat.h>

typedef struct mint_filesys MINT_FILESYS;
typedef struct mint_devdrv MINT_DEVDRV;
typedef struct mint_file MINT_FILEPTR;
typedef struct fcookie fcookie;
typedef struct mint_dirstruct MINT_DIR;


struct mint_devdrv
{
	long __CDECL (*open)	(MINT_FILEPTR *f);
	long __CDECL (*write)	(MINT_FILEPTR *f, const char *buf, long bytes);
	long __CDECL (*read)	(MINT_FILEPTR *f, char *buf, long bytes);
	long __CDECL (*lseek)	(MINT_FILEPTR *f, long where, short whence);
	long __CDECL (*ioctl)	(MINT_FILEPTR *f, short mode, void *buf);
	long __CDECL (*datime)	(MINT_FILEPTR *f, unsigned short *timeptr, short rwflag);
	long __CDECL (*close)	(MINT_FILEPTR *f, short pid);
	long __CDECL (*select)	(MINT_FILEPTR *f, long proc, short mode);
	void __CDECL (*unselect)	(MINT_FILEPTR *f, long proc, short mode);
	
	/* extensions, check dev_descr.drvsize (size of DEVDRV struct) before calling:
	 * fast RAW tty byte io
	 */
	long __CDECL (*writeb)	(MINT_FILEPTR *f, const char *buf, long bytes);
	long __CDECL (*readb)	(MINT_FILEPTR *f, char *buf, long bytes);
	
	/* what about: scatter/gather io for DMA devices...
	 * long __CDECL (*writev)(MINT_FILEPTR *f, const struct iovec *iov, long cnt);
	 * long __CDECL (*readv)	(MINT_FILEPTR *f, struct iovec *iov, long cnt);
	 */
};

struct mint_filesys
{
	/* kernel data
	 */
	MINT_FILESYS	*next;			/* link to next file system on chain */
	long	fsflags;
# define FS_KNOPARSE		0x0001	/* kernel shouldn't do parsing */
# define FS_CASESENSITIVE	0x0002	/* file names are case sensitive */
# define FS_NOXBIT		0x0004	/* if a file can be read, it can be executed */
# define FS_LONGPATH		0x0008	/* file system understands "size" argument to "getname" */
# define FS_NO_C_CACHE		0x0010	/* don't cache cookies for this filesystem */
# define FS_DO_SYNC		0x0020	/* file system has a sync function */
# define FS_OWN_MEDIACHANGE	0x0040	/* filesystem control self media change (dskchng) */
# define FS_REENTRANT_L1	0x0080	/* fs is level 1 reentrant */
# define FS_REENTRANT_L2	0x0100	/* fs is level 2 reentrant */
# define FS_EXT_1		0x0200	/* extensions level 1 - mknod & unmount */
# define FS_EXT_2		0x0400	/* extensions level 2 - additional place at the end */
# define FS_EXT_3		0x0800	/* extensions level 3 - stat & native UTC timestamps */
	
	/* filesystem functions
	 */
	long	__CDECL (*root)		(short drv, fcookie *fc);
	long	__CDECL (*lookup)	(fcookie *dir, const char *name, fcookie *fc);
	long	__CDECL (*creat)	(fcookie *dir, const char *name, unsigned short mode, short attrib, fcookie *fc);
	MINT_DEVDRV*	__CDECL (*getdev)	(fcookie *file, long *devspecial);
	long	__CDECL (*getxattr)	(fcookie *file, XATTR *xattr);
	long	__CDECL (*chattr)	(fcookie *file, short attr);
	long	__CDECL (*chown)	(fcookie *file, short uid, short gid);
	long	__CDECL (*chmode)	(fcookie *file, unsigned short mode);
	long	__CDECL (*mkdir)	(fcookie *dir, const char *name, unsigned short mode);
	long	__CDECL (*rmdir)	(fcookie *dir, const char *name);
	long	__CDECL (*remove)	(fcookie *dir, const char *name);
	long	__CDECL (*getname)	(fcookie *relto, fcookie *dir, char *pathname, short size);
	long	__CDECL (*rename)	(fcookie *olddir, char *oldname, fcookie *newdir, const char *newname);
	long	__CDECL (*opendir)	(MINT_DIR *dirh, short tosflag);
	long	__CDECL (*readdir)	(MINT_DIR *dirh, char *name, short namelen, fcookie *fc);
	long	__CDECL (*rewinddir)(MINT_DIR *dirh);
	long	__CDECL (*closedir)	(MINT_DIR *dirh);
	long	__CDECL (*pathconf)	(fcookie *dir, short which);
	long	__CDECL (*dfree)	(fcookie *dir, long *buf);
	long	__CDECL (*writelabel)(fcookie *dir, const char *name);
	long	__CDECL (*readlabel)(fcookie *dir, char *name, short namelen);
	long	__CDECL (*symlink)	(fcookie *dir, const char *name, const char *to);
	long	__CDECL (*readlink)	(fcookie *dir, char *buf, short len);
	long	__CDECL (*hardlink)	(fcookie *fromdir, const char *fromname, fcookie *todir, const char *toname);
	long	__CDECL (*fscntl)	(fcookie *dir, const char *name, short cmd, long arg);
	long	__CDECL (*dskchng)	(short drv, short mode);
	long	__CDECL (*release)	(fcookie *);
	long	__CDECL (*dupcookie)(fcookie *new, fcookie *old);
	long	__CDECL (*sync)		(void);
	long	__CDECL (*mknod)	(fcookie *dir, const char *name, unsigned long mode);
	long	__CDECL (*unmount)	(short drv);
	long	__CDECL (*stat64)	(fcookie *file, struct stat *stat);
	
	long tz_offset;
	long res2, res3;	/* reserved */
	
	/* experimental extension
	 */
	unsigned long lock;			/* for non-blocking DMA */
	unsigned long sleepers;		/* sleepers on this filesystem */
	void	__CDECL (*block)		(MINT_FILESYS *fs, unsigned short dev, const char *);
	void	__CDECL (*deblock)	(MINT_FILESYS *fs, unsigned short dev, const char *);
};


struct fcookie
{
	MINT_FILESYS *fs;	/* filesystem that knows about this cookie */
	unsigned short dev;	/* device info (e.g. Rwabs device number) */
	unsigned short aux;	/* extra data that the file system may want */
	long index;			/* this+dev uniquely identifies a file */
};


struct mint_file
{
	short	links;			/* number of copies of this descriptor */
	unsigned short flags;	/* file open mode and other file flags */
	long	pos;			/* position in file */
	long	devinfo;		/* device driver specific info */
	fcookie	fc;				/* file system cookie for this file */
	MINT_DEVDRV	*dev;		/* device driver that knows how to deal with this */
	MINT_FILEPTR *next;		/* link to next fileptr for this file */
};


/* structure for opendir/readdir/closedir */
struct mint_dirstruct
{
	fcookie fc;				/* cookie for this directory */
	unsigned short	index;	/* index of the current entry */
	unsigned short	flags;	/* flags (e.g. tos or not) */
# define TOS_SEARCH	0x01
	void *dta;				/* dta using this entry */
	char	fsstuff[56];	/* anything else the file system wants */
							/* NOTE: this must be at least 45 bytes */
	MINT_DIR	*next;		/* linked together so we can close them
				 * on process termination */
	short	fd;		/* associated fd, for use with dirfd */
};

/* structure for internal kernel locks */
typedef struct mint_ilock MINT_LOCK;
struct mint_ilock
{
	struct flock l;		/* the actual lock */
	struct mint_ilock *next;	/* next lock in the list */
	long reserved [4];	/* reserved for future expansion */
};
