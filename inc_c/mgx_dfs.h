/*********************************************************************
*
* Mag!X 3.00
* ==========
*
* Strukturen fÅr die Einbindung eines DFS.
* Die korrekten Prototypen fÅr die Implementation eines DFS
* in 'C' folgen, so wie die 'C'- Schnittstelle fertig ist.
*
* Da z.T. mehrere Register fÅr RÅckgabewerte verwendet werden und
* auûerdem Zeiger in Datenregistern Åbergeben werden, ist eine
* Schnittstelle als _cdecl geplant, d.h. sÑmtliche Parameter werden
* auf dem Stapel Åbergeben, dies ermîglicht die Verwendung eines
* beliebigen Compilers.
*
* Version: 4.4.94
*
*********************************************************************/

typedef struct _mx_dosfd MX_DOSFD;
typedef struct _mx_dosdir MX_DOSDIR;

typedef struct _mx_ddev {
     LONG cdecl (*ddev_open)(MX_DOSFD *f);
     LONG cdecl (*ddev_close)(MX_DOSFD *f);
     LONG cdecl (*ddev_read)(MX_DOSFD *f, void *buf, long len);
     LONG cdecl (*ddev_write)(MX_DOSFD *f, void *buf, long len);
     LONG cdecl (*ddev_stat)(MX_DOSFD *f, short rwflag, void *unsel, APPL *appl);
     LONG cdecl (*ddev_seek)(MX_DOSFD *f, long where, short whence);
     LONG cdecl (*ddev_datime)(MX_DOSFD *f, short *buf, short rwflag);
     LONG cdecl (*ddev_ioctl)(MX_DOSFD *f, short cmd, void *buf);
     LONG cdecl (*ddev_delete)(MX_DOSFD *f, MX_DOSDIR *dir);
     LONG cdecl (*ddev_getc)(MX_DOSFD *f, short mode);
     LONG cdecl (*ddev_getline)(MX_DOSFD *f, char *buf, long size, short mode);
     LONG cdecl (*ddev_putc)(MX_DOSFD *f, short mode, long val);
} MX_DDEV;


struct _mx_dosfd {
     struct _mx_dosdmd	*fd_dmd;
     WORD      fd_refcnt;
     WORD      fd_mode;
     MX_DEV    *fd_dev;
     MX_DDEV   *fd_ddev;
     char      fd_name[11];
     char      fd_attr;
     PD        *fd_owner;
     struct _mx_dosfd  *fd_parent;
     struct _mx_dosfd  *fd_children;
     struct _mx_dosfd  *fd_next;
     struct _mx_dosfd  *fd_multi;
     struct _mx_dosfd  *fd_multi1;
     ULONG     fd_fpos;
     char      fd_dirch;
     char      fd_unused;
     WORD      fd_time;
     WORD      fd_date;
     WORD      fd_stcl;
     ULONG     fd_len;
     ULONG     fd_dirpos;
     ULONG     fd_user1;
     ULONG     fd_user2;
     char		*fd_longname;
};

typedef struct _mx_dosdta {
     char      dta_sname[12];
     ULONG     dta_usr1;
     ULONG     dta_usr2;
     char      dta_drive;
     char      dta_attr;
     WORD      dta_time;
     WORD      dta_date;
     ULONG     dta_len;
     char      dta_name[14];
} MX_DOSDTA;


typedef struct _mx_dosdmd {
     MX_XFS    *d_xfs;
     WORD      d_drive;
     MX_DOSFD  *d_root;
     WORD      biosdev;
     LONG      driver;
     LONG      devcode;
     struct _mx_dfs    *d_dfs;
     WORD		d_flags;
} MX_DOSDMD;


struct _mx_dosdir {
     char      dir_name[11];
     char      dir_attr;
     WORD      dir_usr1;
     ULONG     dir_usr2;
     ULONG     dir_usr3;
     WORD      dir_time;
     WORD      dir_date;
     WORD      dir_stcl;
     ULONG     dir_flen;
};



typedef struct _mx_dfs {
     char      dfs_name[8];
     struct _mx_dfs   *dfs_next;
     long      (*dfs_init)(void);
     long      (*dfs_sync)(MX_DOSDMD *d);
     long      (*dfs_drv_open)(MX_DOSDMD *d);
     long      (*dfs_drv_close)(MX_DOSDMD *d, short mode);
     long      (*dfs_dfree)(MX_DOSDMD *, long df[4]);
     long      (*dfs_sfirst)(MX_DOSFD *dd, MX_DOSDIR *dir, LONG pos, MX_DOSDTA *dta, void *link);
     long      (*dfs_snext)(MX_DOSDTA *dta, MX_DOSDMD *d, void *next);
     long      (*dfs_ext_fd)(MX_DOSFD *dd);
     long      (*dfs_fcreate)(MX_DOSFD *fd, MX_DOSDIR *dir, short cmd, long arg);
     long      (*dfs_fxattr)(MX_DOSFD *dd, MX_DOSDIR *dir, short mode, XATTR *xattr, void *link);
     long      (*dfs_dir2index)(MX_DOSFD *dd, MX_DOSDIR *dir, void *link);
     long      (*dfs_readlink)(MX_DOSFD *dd, MX_DOSDIR *dir, void *link);
     long      (*dfs_dir2FD)(MX_DOSFD *dd, MX_DOSDIR *dir, void *link);
     long      (*dfs_fdelete)(MX_DOSFD *dd, MX_DOSDIR *dir, long pos);
     long      (*dfs_pathconf)(MX_DOSFD *dd, short cmd);
} MX_DFS;

/* unterstÅtzte Dcntl- Modi */
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00

/* zusÑtzliche Attributbits */
#ifndef FA_SYMLINK
#define	FA_SYMLINK	0x40
#endif
