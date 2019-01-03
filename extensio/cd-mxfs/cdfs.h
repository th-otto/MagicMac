/*
	@(#)CD-FS/cdfs.h
	
	Julian F. Reschke, 1. Mai 1997
*/

/**** Device structures ****/

#define BLOCKSIZE			2048L
#define LONGNAMELENGTH		128

typedef struct
{
	/* start of length of primary and associated file */
	struct {
		unsigned long start, length;
	} pri;
	struct {
		unsigned long start, length;
	} ass;

	/* internal index */
	unsigned long	iindex;

	/* other user visible file attributes */
	unsigned int	mode;
	unsigned int	adate, atime;
	unsigned int	cdate, ctime;
	unsigned int	mdate, mtime;
	unsigned int 	nlink, uid, gid;
	unsigned char	tosattr, fsprivate;
	char			longname[LONGNAMELENGTH];
	char			truncname[14];
	long			type, creator;
} DIRENTRY;

/* File structure, 8 longs max */
typedef struct
{
	unsigned long	start;
	unsigned long	size;
	unsigned long	offset;
	unsigned long	iindex;
	unsigned long	de_end;
	unsigned int	dev;
	unsigned int	dirflg;
} MYFILE;

#if sizeof (MYFILE) > 32
#error MYFILE structure too big for MetaDOS
#endif

typedef struct logical_dev LOGICAL_DEV;

typedef struct
{
	long	(*get_root)(LOGICAL_DEV *ldp, unsigned long lba, int count);
	long	(*get_direntry)(LOGICAL_DEV *ldp, unsigned long *adr,
				unsigned long dirend, DIRENTRY *de);
	long	(*readfile)(LOGICAL_DEV *ldp, long start, long offset,
				long size, long iindex, long cnt, char *buffer);
	long	(*label)(LOGICAL_DEV *ldp, char *str, int size, int rw);
	long	(*pathconf)(LOGICAL_DEV *ldp, int mode);
} FILESYSTEM;

typedef struct
{
	unsigned char	data[BLOCKSIZE];
	unsigned long	timestamp;
	unsigned long	blkno;
	unsigned int	device;
} CACHEENTRY;

typedef struct
{
	unsigned short block;				/* first allocation block */
	unsigned short count;				/* number of allocation blocks */
} hfs_extent;

typedef hfs_extent hfs_extent_rec[3];

struct logical_dev
{
	short 			metadevice;
	short			fspreference;
#define FSPREFERENCE_ISO   0
#define FSPREFERENCE_HFS   1
#define FSPREFERENCE_TOC   2
	FILESYSTEM		fs;
	char			scratch[2352]; /* CD_FRAMESIZE_RAW */
	short			fsprivate;
	char			fslabel[65];
	unsigned long	blocksize;
	unsigned long	totalsize;
	unsigned long	rootdir;
	unsigned long	rootdirsize;
	unsigned long	mediatime;
	unsigned short	mount_date;
	unsigned short	mount_time;
	union {
		struct {
			unsigned long partoffset;
			unsigned long allocstart;
			unsigned long blocksize;
			hfs_extent_rec catalogextents;
			hfs_extent_rec overflowextents;
		} hfs;
	} p;
	struct {
		DIRENTRY		de;
		char 			name[512];
		char			*tail;
		unsigned long	parentstart;
		unsigned short	inuse;
		unsigned long	index;
	} lastde;
};


/**** Cache control ****/

#define DEFAULTCACHESIZE	8

/* clear all cache entries for the logical device */
void DCClear(LOGICAL_DEV *ldp);

/* read from a logical device */
long DCRead(LOGICAL_DEV *ldp, unsigned long adr, unsigned long cnt, void *buffer);

/* size of cache in blocks */
extern int DCSize;

/* pointer to cache entries */
extern CACHEENTRY *DCCache;


/**** CD lib kernel ****/

/* initialize the device */
int DKInitVolume(LOGICAL_DEV *ldp);

/* convert DIRENTRY structure to XATTR structure */
void DKDirentry2Xattr(LOGICAL_DEV *ldp, DIRENTRY *de, int drive, XATTR *xap);

/* convert filename to 8+3 format */
void DKTosify(char *dst, const char *src);

/* flip filesystem type preference */
void DKFlipPreferred(LOGICAL_DEV *ldp);
void DKFlipPreferredReversed(LOGICAL_DEV *ldp);

/* set to # of open files supported by the kernel if not unlimited */
extern long DKMaxOpenFiles;

/**** to be supplied by FS specific part ****/

/* convert Unix time to DOS time */
unsigned long DMDosTime(unsigned long t);

/**** internal stuff ****/

#define MEDIADELAY	400

#define METADOS_IOCTL_MAGIC 0x4643544CL /* 'FCTL' */
