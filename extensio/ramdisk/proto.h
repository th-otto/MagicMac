/*
 * proto.h vom 23.06.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * EnthÑlt sÑmtliche Prototypen und globale Variablen fÅr das
 * Ramdisk-XFS und wird von ramdisk.h eingebunden.
 *
 * History:
 * 30.12.1995: Erstellung
 * 31.12.1995: Neuer Prototyp increase_refcnts.
 *             Prototyp von ramdisk_path2DD an neue Parameterform
 *             angepaût.
 * 02.01.1996: uptonow beim Prototyp zu get_size entfernt.
 *             Im Prototyp getline size und mode vertauscht, weil es
 *             in der Pure-C-Schnittstelle verdreht definiert war.
 * 14.02.1996: Neue Prototypen read_infofile und readline.
 * 16.02.1996: Neuer Prototyp set_ramdisk_drive, Prototyp von
 *             read_infofile verÑndert.
 * 17.02.1996: Neue Variable eight_bit.
 * 26.02.1996: Neue Variable volume_label.
 * 23.04.1996: Neuer Prototyp get_cookie.
 * 23.06.1996: Neue Prototypen Pdomain_gemdos, Pdomain_kernel,
 *             Mxalloc_kernel und Mfree_kernel, neue Variablen
 *             Pdomain, _Mxalloc und _Mfree
 */

#ifndef _RAMDISK_PROTO_H
#define _RAMDISK_PROTO_H

/* Prototypen */
void read_infofile(void);
WORD readline(WORD handle, char *buffer);
LONG get_and_set_drive(void);
LONG set_ramdisk_drive(void);
void increase_refcnts(RAMDISK_FD *dd);
LONG attrib_action(DIRENTRY *entry, LONG rwflag, LONG attrib);
LONG chmod_action(DIRENTRY *entry, LONG _mode, LONG dummy);
LONG get_size(DIRENTRY *search);
LONG dcntl_action(DIRENTRY *entry, LONG cmd, LONG arg);

void ramdisk_sync(MX_DMD *d);
void ramdisk_pterm(MX_DMD *dmd, PD *pd);
LONG ramdisk_garbcoll(MX_DMD *d);
void ramdisk_freeDD(MX_DD *dd);
LONG ramdisk_drv_open(MX_DMD *d);
LONG ramdisk_drv_close(MX_DMD *d, WORD mode);
LONG ramdisk_path2DD(MX_DD *reldir, const char *pathname, WORD mode,
	const char **lastpath, MX_DD **linkdir, void **symlink);
LONG ramdisk_sfirst(MX_DD *srchdir, const char *name, DTA *dta,
	WORD attrib, void **symlink);
LONG ramdisk_snext(DTA *dta, MX_DMD *dmd, void **symlink);
LONG ramdisk_fopen(MX_DD *dir, const char *name, WORD omode, WORD attrib,
	void **symlink);
LONG ramdisk_fdelete(MX_DD *dir, const char *name);
LONG ramdisk_link(MX_DD *olddir, MX_DD *newdir, const char *oldname,
	const char *newname, WORD flag_link);
LONG ramdisk_xattr(MX_DD *dir, const char *name, XATTR *xattr, WORD mode,
	void **symlink);
LONG ramdisk_attrib(MX_DD *dir, const char *name, WORD rwflag, WORD attrib,
	void **symlink);
LONG ramdisk_chown(MX_DD *dir, const char *name, UWORD uid, UWORD gid,
	void **symlink);
LONG ramdisk_chmod(MX_DD *dir, const char *name, UWORD mode,
	void **symlink);
LONG ramdisk_dcreate(MX_DD *dir, const char *name, UWORD mode);
LONG ramdisk_ddelete(MX_DD *dir);
LONG ramdisk_DD2name(MX_DD *dir, char *name, WORD bufsize);
LONG ramdisk_dopendir(MX_DD *dir, WORD tosflag);
LONG ramdisk_dreaddir(MX_DHD *dhd, WORD size, char *buf, XATTR *xattr,
	LONG *xr);
LONG ramdisk_drewinddir(MX_DHD *dhd);
LONG ramdisk_dclosedir(MX_DHD *dhd);
LONG ramdisk_dpathconf(MX_DD *dir, WORD which);
LONG ramdisk_dfree(MX_DD *dd, DISKINFO *free);
LONG ramdisk_wlabel(MX_DD *dir, const char *name);
LONG ramdisk_rlabel(MX_DD *dir, const char *name, char *buf, WORD len);
LONG ramdisk_symlink(MX_DD *dir, const char *name, const char *to);
LONG ramdisk_readlink(MX_DD *dir, const char *name, char *buf, WORD size);
LONG ramdisk_dcntl(MX_DD *dir, const char *name, WORD cmd, LONG arg,
	void **symlink);

LONG ramdisk_close(MX_FD *file);
LONG ramdisk_read(MX_FD *file, LONG count, void *buffer);
LONG ramdisk_write(MX_FD *file, LONG count, void *buffer);
LONG ramdisk_stat(MX_FD *file, MAGX_UNSEL *unselect, WORD rwflag,
	LONG apcode);
LONG ramdisk_seek(MX_FD *file, LONG where, WORD mode);
LONG ramdisk_datime(MX_FD *file, WORD *d, WORD setflag);
LONG ramdisk_ioctl(MX_FD *file, WORD cmd, void *buf);
LONG ramdisk_getc(MX_FD *file, WORD mode);
LONG ramdisk_getline(MX_FD *file, char *buf, WORD mode, LONG size);
LONG ramdisk_putc(MX_FD *file, WORD mode, LONG value);

void prepare_dir(DIRENTRY *dir, WORD maxentries, DIRENTRY *parent);
DIRENTRY *findfile(RAMDISK_FD *dd, const char *pathname, WORD spos,
	WORD s_or_e, WORD maybe_dir);
#define FF_SEARCH	0
#define FF_EXIST	1
RAMDISK_FD *findfd(DIRENTRY *fname);
DIRENTRY *new_file(RAMDISK_FD *curr, const char *name);
WORD dir_is_open(DIRENTRY *dir);
WORD check_name(const char *name);
LONG check_dd(RAMDISK_FD *dd);
LONG check_fd(RAMDISK_FD *fd);
LONG work_entry(RAMDISK_FD *dd, const char *name, void **symlink,
	WORD writeflag, LONG par1, LONG par2,
	LONG (*action)(DIRENTRY *entry, LONG par1, LONG par2));
LONG set_amtime(DIRENTRY *entry, LONG set_atime, LONG unused);
void tostrunc(char *dest, const char *src, WORD wildcards);
void fill_tosname(char *dest, char *src);
WORD match_tosname(char *to_check, char *sample);
WORD has_xext(const char *name);
void *Kmalloc(LONG len);
void *Krealloc(void *ptr, LONG old_len, LONG new_len);
LONG Pdomain_gemdos(WORD domain);
LONG Pdomain_kernel(WORD ignore);
void *Mxalloc_kernel(LONG amount, WORD mode);
WORD Mfree_kernel(void *block);
#ifdef DEBUG
void trace(const char *format, ...);
#define TRACE(x) trace x
#else
#define TRACE(x)
#endif
WORD get_cookie(ULONG cookie, ULONG *value);

/*
 * Globale Variablen, die entweder "extern" oder direkt deklariert
 * bzw. definiert werden.
 */
extern THE_MX_KERNEL *kernel;
extern THE_MGX_XFS ramdisk_xfs;
extern THE_MGX_DEV ramdisk_dev;
#ifdef ONLY_EXTERN
#define _GLOBAL	extern
#else
#define _GLOBAL
#endif
_GLOBAL	WORD			ramdisk_drive,
						starttime,
						startdate;
_GLOBAL	MX_DMD			*ramdisk_dmd;
_GLOBAL	RAMDISK_FD		fd[MAX_FD];
_GLOBAL	RAMDISK_DHD		dhd[MAX_DHD];
_GLOBAL	DIRENTRY		root[ROOTSIZE],
						root_de;
_GLOBAL	LONG			leave_free;
_GLOBAL	WORD			ram_type,
						eight_bit;
_GLOBAL char			volume_label[34];
_GLOBAL LONG			(*p_Pdomain)(WORD ignore);
_GLOBAL void			*(*_Mxalloc)(LONG amount, WORD mode);
_GLOBAL WORD			(*_Mfree)(void *block);
#ifdef DEBUG
_GLOBAL	WORD			debug_to_screen;
#endif

#endif /* _RAMDISK_PROTO_H */

/* EOF */
