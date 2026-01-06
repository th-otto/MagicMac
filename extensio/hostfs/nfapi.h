/*
 * general XFS driver version
 */
#define HOSTFS_XFS_VERSION       0

/* if you change anything in the enum {} below you have to increase
   this HOSTFS_NFAPI_VERSION!
*/
#define HOSTFS_NFAPI_VERSION    04

enum {
	GET_VERSION = 0,	/* subID = 0 */
	GET_DRIVE_BITS,     /* 1: get mapped drive bits */
	/* hostfs_xfs */
	XFS_INIT,			/* 2: XFS_INIT(long device_num, char *mountpoint, char *hostroot, long halfsensitive, FILESYS *fs, DEVDRV *dev) */
	XFS_ROOT,			/* 3: XFS_ROOT(long drive, fcooke *fc) */
	XFS_LOOKUP,			/* 4: XFS_LOOKUP(fcookie *dir, const char *name, fccokie *fc) */
	XFS_CREATE,			/* 5: XFS_CREATE(fcookie *dir, const char *name, long mode, long attrib, fcookie *fc) */
	XFS_GETDEV,			/* 6: XFS_GETDEV(fcookie *fc, long *devspecial) */
	XFS_GETXATTR,		/* 7: XFS_GETXATTR(fcookie *fc, XATTR *xattr) */
	XFS_CHATTR,			/* 8: XFS_CHATTR(fcookie *fc, long attrib) */
	XFS_CHOWN,			/* 9: XFS_CHOWN(fcookie *fc, long uid, long gid) */
	XFS_CHMOD,			/* 10: XFS_CHMOD(fcookie *fc, long mode) */
	XFS_MKDIR,			/* 11: XFS_MKDIR(fcookie *dir, const char *name, long mode) */
	XFS_RMDIR,			/* 12: XFS_RMDIR(fcookie *dir, const char *name) */
	XFS_REMOVE,			/* 13: XFS_REMOVE(fcookie *dir, const char *name) */
	XFS_GETNAME,		/* 14: XFS_GETNAME(fcookie *relto, fcookie *fc, char *name, long namelen) */
	XFS_RENAME,			/* 15: XFS_RENAME(fcookie *olddir, const char *oldname, fcookie *newdir, const char *newname) */
	XFS_OPENDIR,		/* 16: XFS_OPENDIR(DIR *dir, long flags) */
	XFS_READDIR,		/* 17: XFS_READDIR(DIR *dir, char *name, long namelen, fcookie *entry) */
	XFS_REWINDDIR,		/* 18: XFS_READDIR(DIR *dir) */
	XFS_CLOSEDIR,		/* 19: XFS_CLOSEDIR(DIR *dir) */ 
	XFS_PATHCONF,		/* 20: XFS_PATHCONF(fcookie *fc, long which) */ 
	XFS_DFREE,			/* 21: XFS_DFREE(fcookie *dir, DISKINFO *buf) */ 
	XFS_WRITELABEL,		/* 22: XFS_WRITELABEL(fcookie *dir, const char *name) */ 
	XFS_READLABEL,		/* 23: XFS_READLABEL(fcookie *dir, char *name, long namelen) */ 
	XFS_SYMLINK,		/* 24: XFS_SYMLINK(fcookie *dir, const char *name, const char *to) */
	XFS_READLINK,		/* 25: XFS_READLINK(fcookie *fc, char *name, long namelen) */
	XFS_HARDLINK,		/* 26: XFS_HARDLINK(fcookie *olddir, const char *oldname, fcookie *newdir, const char *newname) */
	XFS_FSCNTL,			/* 27: XFS_FSCNTL(fcookie *dir, const char *name, long cmd, long arg) */
	XFS_DSKCHNG,		/* 28: XFS_DSKCHNG(long drv, long mode) */
	XFS_RELEASE,		/* 29: XFS_RELEASE(fcookie *fc) */
	XFS_DUPCOOKIE,		/* 30: XFS_RELEASE(fcookie *new, fcookie *old) */
	XFS_SYNC,			/* 31: XFS_SYNC(void) */
	XFS_MKNOD,			/* 32: XFS_MKNOD(fcookie *dir, const char *name, unsigned long mode) */
	XFS_UNMOUNT,		/* 33: XFS_UNMOUNT(long drive) */
	/* hostfs_dev */
	DEV_OPEN,			/* 34: DEV_OPEN(FILEPTR *file) */
	DEV_WRITE,			/* 35: DEV_WRITE(FILEPTR *file, void *buf, long count) */
	DEV_READ,			/* 36: DEV_READ(FILEPTR *file, void *buf, long count) */
	DEV_LSEEK,			/* 37: DEV_SEEK(FILEPTR *file, long offset, long whence) */
	DEV_IOCTL,			/* 38: DEV_IOCTL(FILEPTR *file, long cmd, long arg) */
	DEV_DATIME,			/* 39: DEV_DATIME(FILEPTR *file, WORD timeptr[2], long set) */
	DEV_CLOSE,			/* 40: DEV_CLOSE(FILEPTR *file, long pid) */
	DEV_SELECT,			/* 41: DEV_SELECT(FILEPTR *file, PROC *proc, long rwflag) */
	DEV_UNSELECT,		/* 42: DEV_UNSELECT(FILEPTR *file, PROC *proc, long rwflag) */
	/* new from 0.04 */
	XFS_STAT64			/* 43: XFS_STAT64(fcookie *fc, struct stat *stat) */
};

extern unsigned long nf_hostfs_id;
extern long __CDECL (*nf_call)(long id, ...);

#define HOSTFS(a)	(nf_hostfs_id + a)
