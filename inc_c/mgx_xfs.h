/*********************************************************************
*
* MagiC 3/4/5
* ===========
*
* Strukturen fÅr die Einbindung eines XFS.
* FÅr die Implementation eines XFS in 'C' sind die korrespondierenden
* CDECL_xxx Strukturen fÅr MX_XFS und MX_DEV definiert.
* Dies ermîglicht die Verwendung eines beliebigen Compilers.
*
* Es wird <portab.h> benîtigt.
*
* Version: 10.5.97
*
*********************************************************************/


#define ELINK  -300           /* Datei ist symbolischer Link */

/* Die Struktur(en) fÅr dev_stat */
typedef union unsel_union
{
	void	(*unsel)(union unsel_union *un, APPL *ap);
	/*
	 * zero/negative: error return from interrupt
	 * 1: OK
	 * else: function pointer above
	 */
	LONG	status;
} UNSELECT;

typedef struct magx_unsel_struct
{
	UNSELECT	unsel;
	LONG		param;
} MAGX_UNSEL;

typedef struct {
     WORD version;
     void (*fast_clrmem)      ( void *von, void *bis );
     char (*toupper)          ( char c );
     void cdecl (*_sprintf)   ( char *dest, const char *source, LONG *p );
     PD	**act_pd;
     APPL **act_appl;
     APPL **keyb_app;
     WORD *pe_slice;
     WORD *pe_timer;
     void (*appl_yield)       ( void );
     void (*appl_suspend)     ( void );
     void (*appl_begcritic)   ( void );
     void (*appl_endcritic)   ( void );
     long (*evnt_IO)          ( LONG ticks_50hz, MAGX_UNSEL *unsel );
     void (*evnt_mIO)         ( LONG ticks_50hz, MAGX_UNSEL *unsel, WORD cnt );
     void (*evnt_emIO)        ( APPL *ap );
     void (*appl_IOcomplete)  ( APPL *ap );
     long (*evnt_sem)         ( WORD mode, void *sem, LONG timeout );
     void (*Pfree)            ( PD *pd );
     WORD int_msize;
     LONG (*int_malloc)       ( void );
     void (*int_mfree)        ( void *memblk );
     void (*resv_intmem)      ( void *mem, LONG bytes );
     LONG (*diskchange)       ( WORD drv );
/* Ab Kernelversion 1: */
     LONG (*DMD_rdevinit)     ( struct _mx_dmd *dmd );
/* Ab Kernelversion 2: */
     LONG (*proc_info)        ( WORD code, PD *pd );
/* Ab Kernelversion 4: */
     LONG (*mxalloc)          ( LONG amount, WORD mode, PD *pd );
     LONG (*mfree)            ( void *block );
     LONG (*mshrink)          ( void *block, LONG newlen );
} MX_KERNEL;


typedef struct {
	WORD	version;
	LONG	(*_dir_srch)(void /* DD */ *dir, char *fname, LONG pos);
	LONG	(*reopen_FD)(void /* DD_FD */ *dir, WORD omode);
	LONG	(*close_DD)(void /* FD */ *file);
	WORD	(*match_8_3)(const char *pattern, const char *fname);
	void	(*conv_8_3)(const char *from, char *to);
	void	(*init_DTA)(void /* DIR */ *dirfile, DTA *dta);
	char    *(*rcnv_8_3)(const char *from, char *to);
} MX_DFSKERNEL;


typedef struct _mx_dev {
     long      (*dev_close)(struct _mx_fd *f);
     long      (*dev_read)(struct _mx_fd *f, LONG count, void *buf);
     long      (*dev_write)(struct _mx_fd *f, LONG count, void *buf);
     long      (*dev_stat)(struct _mx_fd *f, MAGX_UNSEL *unselect, WORD rwflag, LONG apcode);
     long      (*dev_seek)(struct _mx_fd *f, LONG where, WORD mode);
     long      (*dev_datime)(struct _mx_fd *f, WORD d[2], WORD set);
     long      (*dev_ioctl)(struct _mx_fd *f, WORD cmd, void *buf);
     long      (*dev_getc)(struct _mx_fd *f, WORD mode);
     long      (*dev_getline)(struct _mx_fd *f, char *buf, WORD mode, LONG size);
     long      (*dev_putc)(struct _mx_fd *f, WORD mode, LONG val);
} MX_DEV;

typedef struct _cdecl_mx_dev {
     LONG cdecl (*dev_close)(struct _mx_fd *f);
     LONG cdecl	(*dev_read)(struct _mx_fd *f, LONG count, void *buf);
     LONG cdecl (*dev_write)(struct _mx_fd *f, LONG count, void *buf);
     LONG cdecl (*dev_stat)(struct _mx_fd *f, MAGX_UNSEL *unselect, WORD rwflag, LONG apcode);
     LONG cdecl (*dev_seek)(struct _mx_fd *f, LONG where, WORD mode);
     LONG cdecl (*dev_datime)(struct _mx_fd *f, WORD d[2], WORD set);
     LONG cdecl (*dev_ioctl)(struct _mx_fd *f, WORD cmd, void *buf);
     LONG cdecl	(*dev_getc)(struct _mx_fd *f, WORD mode);
     LONG cdecl (*dev_getline)(struct _mx_fd *f, char *buf, WORD mode, LONG size);
     LONG cdecl (*dev_putc)(struct _mx_fd *f, WORD mode, LONG val);
} CDECL_MX_DEV;


typedef struct _mx_dd {
     struct _mx_dmd *dd_dmd;
     WORD      dd_refcnt;
} MX_DD;


typedef struct _mx_fd {
     struct _mx_dmd *fd_dmd;
     WORD      fd_refcnt;
     WORD      fd_mode;
     const MX_DEV    *fd_dev;
} MX_FD;


typedef struct _mx_dhd {
     struct _mx_dmd *dhd_dmd;
} MX_DHD;


typedef struct _mx_dta {
     char      dta_res1[20];
     char      dta_drive;
     char      dta_attrib;
     WORD      dta_time;
     WORD      dta_date;
     ULONG     dta_len;
     char      dta_name[14];
} MX_DTA;


typedef struct _mx_dmd {
     struct _mx_xfs *d_xfs;
     WORD      d_drive;
     MX_DD     *d_root;
     WORD      d_biosdev;
     LONG      d_driver;
     LONG      d_devcode;
} MX_DMD;


/* structure for getxattr (-> MiNT) */

#ifndef S_IFMT

#if !defined(__XATTR) && !defined(__KERNEL__) && !defined(__KERNEL_MODULE__)
#define __XATTR
typedef struct xattr {
     unsigned short mode;
/* file types */
#define S_IFMT 0170000        /* mask to select file type */
#define S_IFCHR     0020000        /* BIOS special file */
#define S_IFDIR     0040000        /* directory file */
#define S_IFREG 0100000       /* regular file */
#define S_IFIFO 0120000       /* FIFO */
#define S_IMEM 0140000        /* memory region or process */
#define S_IFLNK     0160000        /* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID     04000
#define S_ISGID 02000
#define S_ISVTX     01000

/* file access modes for user, group, and other*/
#define S_IRUSR     0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#define S_IRGRP 0040
#define S_IWGRP     0020
#define S_IXGRP     0010
#define S_IROTH     0004
#define S_IWOTH     0002
#define S_IXOTH     0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE     (0666)
     long index;
     unsigned short dev;
     unsigned short reserved1;
     unsigned short nlink;
     unsigned short uid;
     unsigned short gid;
     long size;
     long blksize, nblocks;
     short     mtime, mdate;
     short     atime, adate;
     short     ctime, cdate;
     short     attr;
     short     reserved2;
     long reserved3[2];
} XATTR;
#endif
#endif

/*
 * For reference only.
 * Some of the functions return values in more
 * than one register, which makes it impossible to directly
 * call them from C-Code without a wrapper.
 * For XFS implemented in C, use CDECL_MX_XFS
 */
typedef struct _mx_xfs {
     char      xfs_name[8];
     struct    _mx_xfs *xfs_next;
     ULONG     xfs_flags;
     long      (*xfs_init)(void);
     long      (*xfs_sync)(MX_DMD *dmd);
     long      (*xfs_pterm)(MX_DMD *dmd, PD *pd);
     long      (*xfs_garbcoll)(MX_DMD *dmd);
     long      (*xfs_freeDD)(MX_DD *dd);
     long      (*xfs_drv_open)(MX_DMD *dmd);
     long      (*xfs_drv_close)(MX_DMD *dmd, WORD mode);
     long      (*xfs_path2DD)(MX_DD *dd, char *path, WORD mode, /* d1= */ char **restp, /* a0= */ MX_DD **symlink_dd, /* a1= */ void **symlink);
     long      (*xfs_sfirst)(MX_DD *dd, char *name, DTA *dta, WORD attrib, /* a0= */ void **symlink);
     long      (*xfs_snext)(DTA *dta, MX_DMD *dmd, void **symlink);
     long      (*xfs_fopen)(MX_DD *dd, char *name, WORD omode, WORD attrib, /* a0= */ void **symlink);
     long      (*xfs_fdelete)(MX_DD *dd, char *name);
     long      (*xfs_link)(MX_DD *altdd, MX_DD *neudd, /* d0= */ char *altname, /* d1= */ char *neuname, /* d2= */ WORD flag);
     long      (*xfs_xattr)(MX_DD *dd, char *name, /* d0= */ XATTR *xa, /* d1= */ WORD mode);
     long      (*xfs_attrib)(MX_DD *dd, char *name, WORD mode, WORD attrib, void **symlink);
     long      (*xfs_chown)(MX_DD *dd, char *name, UWORD uid, UWORD gid);
     long      (*xfs_chmod)(MX_DD *dd, char *name, UWORD mode);
     long      (*xfs_dcreate)(MX_DD *dd, char *name, UWORD mode);
     long      (*xfs_ddelete)(MX_DD *dd);
     long      (*xfs_DD2name)(MX_DD *dd, char *buf, WORD buflen);
     long      (*xfs_dopendir)(MX_DD *d, WORD tosflag);
     long      (*xfs_dreaddir)(MX_DHD *dh, WORD len, char *buf, XATTR *xattr, LONG *xr);
     long      (*xfs_drewinddir)(MX_DHD *dhd);
     long      (*xfs_dclosedir)(MX_DHD *dhd);
     long      (*xfs_dpathconf)(MX_DD *dd, WORD which);
     long      (*xfs_dfree)(MX_DD *dd, LONG buf[4]);
     long      (*xfs_wlabel)(MX_DD *dd, char *name);
     long      (*xfs_rlabel)(MX_DD *dd, char *name, char *buf, WORD buflen);
     long      (*xfs_symlink)(MX_DD *dd, char *name, char *to);
     long      (*xfs_readlink)(MX_DD *dd, char *name, char *buf, WORD buflen);
     long      (*xfs_dcntl)(MX_DD *dd, char *name, WORD cmd, LONG arg);
} MX_XFS;

typedef struct _cdecl_mx_xfs {
     char			xfs_name[8];
     struct _cdecl_mx_xfs *xfs_next;
     ULONG		xfs_flags;
     LONG cdecl	(*xfs_init)(void);
     void cdecl (*xfs_sync)(MX_DMD *dmd);
     void cdecl (*xfs_pterm)(MX_DMD *dmd, PD *pd);
     LONG cdecl	(*xfs_garbcoll)(MX_DMD *dmd);
     void cdecl	(*xfs_freeDD)(MX_DD *dd);
     LONG cdecl (*xfs_drv_open)(MX_DMD *dmd);
     LONG cdecl (*xfs_drv_close)(MX_DMD *dmd, WORD mode);
     LONG cdecl (*xfs_path2DD)(MX_DD *dd, const char *path, WORD mode,
     						const char **restp, MX_DD **symlink_dd,
     						void **symlink);
     LONG cdecl (*xfs_sfirst)(MX_DD *dd, const char *name, DTA *dta, WORD attrib, void **symlink);
     LONG cdecl (*xfs_snext)(DTA *dta, MX_DMD *dmd, void **symlink);
     LONG cdecl (*xfs_fopen)(MX_DD *dd, const char *name, WORD omode, WORD attrib, void **symlink);
     LONG cdecl (*xfs_fdelete)(MX_DD *dd, const char *name);
     LONG cdecl (*xfs_link)(MX_DD *altdd, MX_DD *neudd, const char *altname, const char *neuname, WORD flag);
     LONG cdecl (*xfs_xattr)(MX_DD *dd, const char *name, XATTR *xa, WORD mode, void **symlink);
     LONG cdecl (*xfs_attrib)(MX_DD *dd, const char *name, WORD mode, WORD attrib, void **symlink);
     LONG cdecl (*xfs_chown)(MX_DD *dd, const char *name, UWORD uid, UWORD gid, void **symlink);
     LONG cdecl (*xfs_chmod)(MX_DD *dd, const char *name, UWORD mode, void **symlink);
     LONG cdecl (*xfs_dcreate)(MX_DD *dd, const char *name, UWORD mode);
     LONG cdecl (*xfs_ddelete)(MX_DD *dd);
     LONG cdecl (*xfs_DD2name)(MX_DD *dd, char *buf, WORD buflen);
     LONG cdecl (*xfs_dopendir)(MX_DD *d, WORD tosflag);
     LONG cdecl (*xfs_dreaddir)(MX_DHD *dh, WORD len, char *buf, XATTR *xattr, LONG *xr);
     LONG cdecl (*xfs_drewinddir)(MX_DHD *dhd);
     LONG cdecl (*xfs_dclosedir)(MX_DHD *dhd);
     LONG cdecl (*xfs_dpathconf)(MX_DD *dd, WORD which);
     LONG cdecl (*xfs_dfree)(MX_DD *dd, DISKINFO *buf);
     LONG cdecl (*xfs_wlabel)(MX_DD *dd, const char *name);
     LONG cdecl (*xfs_rlabel)(MX_DD *dd, const char *name, char *buf, WORD buflen);
     LONG cdecl (*xfs_symlink)(MX_DD *dd, const char *name, const char *to);
     LONG cdecl (*xfs_readlink)(MX_DD *dd, const char *name, char *buf, WORD buflen);
     LONG cdecl (*xfs_dcntl)(MX_DD *dd, const char *name, WORD cmd, LONG arg, void **symlink);
} CDECL_MX_XFS;

/* Dcntl(KER_DOSLIMITS) -> Zeiger auf Zeiger auf: */

typedef struct {
     UWORD     version;                 /* Versionsnummer */
     UWORD     num_drives;              /* max. Anzahl Laufwerke */
     ULONG     max_secsizb;             /* max. Sektorgrîûe in Bytes */
     UWORD     min_nfats;               /* min. Anzahl FATs */
     UWORD     max_nfats;               /* max. Anzahl FATs */
     ULONG     min_nclsiz;              /* min. Anzahl Sektoren/Cluster */
     ULONG     max_nclsiz;              /* max. Anzahl Sektoren/Cluster */
     ULONG     max_ncl;                 /* max. Anzahl Cluster */
     ULONG     max_nsec;                /* max. Anzahl Sektoren */
} MX_DOSLIMITS;

/* Schreib-/Lesemodi fÅr Fgetchar und Fputchar */

#define   CMODE_RAW      0
#define   CMODE_COOKED   1
#define   CMODE_ECHO     2

/* Open- Modus von Dateien (Mag!X- intern)                                 */
/* NOINHERIT wird nicht unterstÅtzt, weil nach TOS- Konvention nur die     */
/* Handles 0..5 vererbt werden                                             */
/* HiByte wie unter MiNT verwendet                                         */

#define   OM_RPERM       1
#define   OM_WPERM       2
#define   OM_EXEC        4
#define   OM_APPEND      8
#define   OM_RDENY       16
#define   OM_WDENY       32
#define   OM_NOCHECK     64

/*
 * Dont get fooled by Pure-C header files;
 * we need the MiNT values here
 */
#undef O_CREAT
#undef O_TRUNC
#undef O_EXCL
#define O_CREAT		0x200
#define O_TRUNC		0x400
#define O_EXCL		0x800


/* unterstÅtzte Dcntl- Modi (Mag!X- spezifisch!) */
#define   KER_GETINFO    0x0100
#define   KER_DOSLIMITS  0x0101
#define   KER_INSTXFS    0x0200
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00
#ifndef CDROMEJECT
#define	CDROMEJECT     0x4309	/* Kernel: Medium auswerfen */
#endif

/*
 * MagiC opcodes (all group 'm' opcodes are reserved for MagiC)
 */

#define MX_KER_GETINFO		(('m'<< 8) | 0)		/* mgx_dos.txt */
#define MX_KER_DOSLIMITS	(('m'<< 8) | 1)		/* mgx_dos.txt */
#define MX_KER_INSTXFS		(('m'<< 8) | 2)		/* mgx_dos.txt */
#define MX_KER_DRVSTAT		(('m'<< 8) | 4)		/* mgx_dos.txt */
#define MX_KER_XFSNAME		(('m'<< 8) | 5)		/* mgx_dos.txt */
#define MX_DEV_INSTALL	 	(('m'<< 8) | 0x20)	/* mgx_dos.txt */
#define MX_DEV_INSTALL2	 	(('m'<< 8) | 0x21)	/* mgx_dos.txt */
#define MX_DFS_GETINFO		(('m'<< 8) | 0x40)	/* mgx_dos.txt */
#define MX_DFS_INSTDFS		(('m'<< 8) | 0x41)	/* mgx_dos.txt */

/* unterstÅtzte Dcntl- Modi */
/* # define FUTIME       0x4603 */

/* unterstÅtzte Fcntl- Modi */
#ifndef FSTAT
#define   FSTAT          (('F'<< 8) | 0)
#endif
#define   FIONREAD       0x4601
#define   FIONWRITE      0x4602
#define   FUTIME         0x4603
#define   FTRUNCATE      0x4604
#define   SHMGETBLK      0x4d00
#define   SHMSETBLK      0x4d01
#define   PBASEADDR      0x5002
