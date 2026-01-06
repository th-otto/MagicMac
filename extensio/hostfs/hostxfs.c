/*
 *
 * Filesystem part for the hostfs.xfs for MagiC.
 *
 * (C) Thorsten Otto 2018
 *
 */

#include <string.h>
#include <ctype.h>

#include "hostfs.h"
#include "util.h"

#include <mint/cookie.h>
#include <mint/sysvars.h>



typedef struct hostxfs_dta
{
	char dta_sname[12];
	HOSTXFS_DHD *dta_dhd;
	WORD dta_srchdir;
	WORD dta_unused;
	signed char dta_drive;		/* ab hier in MagiX festgelegt */
	unsigned char dta_attrib;
	WORD dta_time;
	WORD dta_date;
	ULONG dta_len;
	char dta_name[14];
} HOSTXFS_DTA;


/* FIXME: must be allocated elsewhere when put in ROM */
unsigned long nf_hostfs_id;
HOSTXFS_DD *mydrives[MAX_DRIVES];

MX_KERNEL *p_kernel;
MX_DFSKERNEL *p_dfskernel;


#define NUM_SEARCH 10
static HOSTXFS_DHD *srchdir[NUM_SEARCH];



HOSTXFS_DD *get_root_dd(UWORD drv)
{
	HOSTXFS_DD *dd;
	
	if (drv >= MAX_DRIVES)
		return NULL;
	dd = mydrives[drv];
	if (dd == NULL || dd->fc.dev == 0)
		return NULL;
	return dd;
}


static unsigned long fs_drive_bits(void)
{
	return nf_call(HOSTFS(GET_DRIVE_BITS));
}


static long fs_native_init(int fs_devnum, char *mountpoint, const char *hostroot, int halfsensitive,
									  void *fs, void *fs_dev)
{
	return nf_call(HOSTFS(XFS_INIT), (long)fs_devnum, mountpoint, hostroot, (long)halfsensitive, fs, fs_dev);
}


/*
 * A fake MiNT FILESYS structure.
 * The HOSTFS interface expects this struct to be passed in the XFS_INIT call,
 * but actually needs only a few members (fsflags for example)
 */
#define hostfs_fs_root 0
#define hostfs_fs_lookup 0
#define hostfs_fs_creat 0
#define hostfs_fs_getdev 0
#define hostfs_fs_getxattr 0
#define hostfs_fs_chattr 0
#define hostfs_fs_chown 0
#define hostfs_fs_chmode 0
#define hostfs_fs_mkdir 0
#define hostfs_fs_rmdir 0
#define hostfs_fs_remove 0
#define hostfs_fs_getname 0
#define hostfs_fs_rename 0
#define hostfs_fs_opendir 0
#define hostfs_fs_readdir 0
#define hostfs_fs_rewinddir 0
#define hostfs_fs_closedir 0
#define hostfs_fs_pathconf 0
#define hostfs_fs_dfree 0
#define hostfs_fs_writelabel 0
#define hostfs_fs_readlabel 0
#define hostfs_fs_symlink 0
#define hostfs_fs_readlink 0
#define hostfs_fs_hardlink 0
#define hostfs_fs_fscntl 0
#define hostfs_fs_dskchng 0
#define hostfs_fs_release 0
#define hostfs_fs_dupcookie 0
#define hostfs_fs_sync 0
#define hostfs_fs_mknod 0
#define hostfs_fs_unmount 0
#define hostfs_fs_stat64 0

/*
 * Note: not const, because the emulator side might update some fields
 */
MINT_FILESYS mint_hostfs_filesys =
{
	(MINT_FILESYS *)0,    /* next */
	/*
	 * FS_KNOPARSE         kernel shouldn't do parsing
	 * FS_CASESENSITIVE    file names are case sensitive
	 * FS_NOXBIT           require only 'read' permission for execution
	 *                     (if a file can be read, it can be executed)
	 * FS_LONGPATH         file system understands "size" argument to "getname"
	 * FS_NO_C_CACHE       don't cache cookies for this filesystem
	 * FS_DO_SYNC          file system has a sync function
	 * FS_OWN_MEDIACHANGE  filesystem control self media change (dskchng)
	 * FS_REENTRANT_L1     fs is level 1 reentrant
	 * FS_REENTRANT_L2     fs is level 2 reentrant
	 * FS_EXT_1            extensions level 1 - mknod & unmount
	 * FS_EXT_2            extensions level 2 - additional place at the end
	 * FS_EXT_3            extensions level 3 - stat & native UTC timestamps
	 */
	FS_NOXBIT        |
	FS_CASESENSITIVE |
	/* FS_DO_SYNC       |  not used on the host side (would be
	 *                     called periodically -> commented out) */
	FS_OWN_MEDIACHANGE  |
	FS_LONGPATH      |
	FS_REENTRANT_L1  |
	FS_REENTRANT_L2  |
	FS_EXT_1         |
	FS_EXT_2         |
	FS_EXT_3         ,
	hostfs_fs_root, hostfs_fs_lookup, hostfs_fs_creat, hostfs_fs_getdev, hostfs_fs_getxattr,
	hostfs_fs_chattr, hostfs_fs_chown, hostfs_fs_chmode, hostfs_fs_mkdir, hostfs_fs_rmdir,
	hostfs_fs_remove, hostfs_fs_getname, hostfs_fs_rename, hostfs_fs_opendir,
	hostfs_fs_readdir, hostfs_fs_rewinddir, hostfs_fs_closedir, hostfs_fs_pathconf,
	hostfs_fs_dfree, hostfs_fs_writelabel, hostfs_fs_readlabel, hostfs_fs_symlink,
	hostfs_fs_readlink, hostfs_fs_hardlink, hostfs_fs_fscntl, hostfs_fs_dskchng,
	hostfs_fs_release, hostfs_fs_dupcookie,
	hostfs_fs_sync,
	/* FS_EXT_1 */
	hostfs_fs_mknod, hostfs_fs_unmount,
	/* FS_EXT_2 */
	/* FS_EXT_3 */
	hostfs_fs_stat64,
	0, 0, 0,          /* reserved 1,2,3 */
	0, 0,             /* lock, sleepers */
	0, 0              /* block(), deblock() */
};

/***************** hier die Funktionen des XFS ****************/

/*******************************************************************
 *
 * Synchronize the filesystem. 
 *
 *******************************************************************/

static void __CDECL xfs_sync(MX_DMD *dmd)
{
	DEBUGPRINTF(("xfs_sync drive=%d\n", dmd ? dmd->d_drive : -1));
	UNUSED(dmd);
	nf_call(HOSTFS(XFS_SYNC));
}


/*******************************************************************
 *
 * Notify a program termination. 
 *
 * Wir koennten hier die DHDs freigeben, hoffen aber, dass
 * ein neuerer MagiC-Kernel diesen unkritischen Ausnahmefall
 * irgendwann einmal fuer uns erledigen wird.
 *
 *******************************************************************/

static void __CDECL xfs_pterm(MX_DMD *dmd, PD *pd)
{
	DEBUGPRINTF(("xfs_pterm drive=%d\n", dmd ? dmd->d_drive : -1));
	UNUSED(dmd);
	UNUSED(pd);
}


/*******************************************************************
 *
 * Garbage collection, or NULL 
 *
 *******************************************************************/

static LONG __CDECL xfs_garbcoll(MX_DMD *dmd)
{
	DEBUGPRINTF(("xfs_garbcoll drive=%d\n", dmd ? dmd->d_drive : -1));
	UNUSED(dmd);
	return E_OK;
}


/*******************************************************************
 *
 * Release a DD.
 *
 * We can just free it; they are not linked
 *
 *******************************************************************/

static void free_dd(HOSTXFS_DD *dd, int release)
{
#if PARANOIA
	if (check_dd(dd) < 0)
		return;
	if (((char *)(dd))[-2] == 0) /* imb_used */
	{
		DEBUGPRINTF(("freeDD: DD %08lx is already free\n", (unsigned long)dd));
		return;
	}
	if (((signed char *)(dd))[-2] != -1)
	{
		DEBUGPRINTF(("freeDD: DD %08lx is not a DD\n", (unsigned long)dd));
		return;
	}
#endif
	if (release && dd->dd.dd_refcnt != 0)
		--dd->dd.dd_refcnt;
	if (dd->dd.dd_refcnt != 0)
		return;
	nf_debugprintf("free_dd %08lx\n", dd);
	kernel_int_mfree(dd);
}


static void __CDECL xfs_freeDD(MX_DD *_dd)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;

	DEBUGPRINTF(("xfs_freeDD dd=%08lx\n", dd));
	free_dd(dd, FALSE);
}


static long __CDECL xfs_dskchng(short drv, short mode)
{
	return nf_call(HOSTFS(XFS_DSKCHNG), (long)drv, (long)mode);
}


static void xfs_release(fcookie *fc)
{
	nf_debugprintf("xfs_release index=%08lx\n", fc->index);
	nf_call(HOSTFS(XFS_RELEASE), fc);
}


/*******************************************************************
 *
 * Tests/initializes DMD (Mediach) 
 *
 * Corresponds to the "root" function of a MiNT-XFS.
 *
 * Wird beim ersten Zugriff auf das Laufwerk sowie zur Nachfrage
 * eines Diskwechsels aufgerufen. Beim ersten Zugriff ist der
 * Zeiger dmd->d_xfs noch NULL.
 *
 *******************************************************************/

static LONG __CDECL xfs_drv_open(MX_DMD *dmd)
{
	WORD drive;
	HOSTXFS_DD *root_dd;
	long ret;
	
	DEBUGPRINTF(("xfs_drv_open dmd=%08lx drive=%d\n", dmd, dmd ? dmd->d_drive : -1));
#if PARANOIA
	if (dmd == 0)
	{
		DEBUGPRINTF(("xfs_drv_open: NULL dmd\n"));
		return EFAULT;
	}
#endif
	drive = dmd->d_drive;
	if ((root_dd = get_root_dd(drive)) == NULL)
		return EDRIVE;
	if (dmd->d_xfs)
	{
		if (dmd->d_xfs != &hostxfs)
			return EDRIVE;
		ret = xfs_dskchng(drive, 1);
		return ret;
	}
	if (dmd->d_root == NULL)
	{
		ret = nf_call(HOSTFS(XFS_ROOT), (long)drive, &root_dd->fc);
		if (ret != 0)
			return EDRIVE;
		
		/* DD fuer Wurzelverzeichnis allozieren und eintragen */
		/* xfs-Treiberadresse eintragen */
	
		root_dd->dd.dd_dmd = dmd;
		root_dd->dd.dd_refcnt = 1;

		root_dd->st_mode = S_IFDIR|S_IRWXU|S_IRWXG|S_IRWXO;
		
		dmd->d_root = &root_dd->dd;
#if PARANOIA
		root_dd->dd_magic = DD_MAGIC;
#endif
		nf_debugprintf("root %d = dd=%08lx dev=%d index=%08lx\n", drive, root_dd, root_dd->fc.dev, root_dd->fc.index);
	}
	dmd->d_xfs = &hostxfs;
	dmd->d_biosdev = -1;
	dmd->d_devcode = (LONG) root_dd;
	dmd->d_driver = 0;
	return E_OK;
}


/*******************************************************************
 *
 * Force a disk media change.
 *
 * Ein Laufwerk wird geschlossen.
 * Ist <mode> == 1, kann sich das XFS nicht weigern und kann nur
 * noch ggf. Strukturen freigeben.
 * Ist <mode> == 0, kann ggf. EACCES geliefert werden.
 *
 *******************************************************************/

static LONG __CDECL xfs_drv_close(MX_DMD *dmd, WORD mode)
{
	HOSTXFS_DD *dd;

	DEBUGPRINTF(("xfs_drv_close drive=%d\n", dmd ? dmd->d_drive : -1));

	UNUSED(mode);
#if PARANOIA
	if (dmd == 0)
	{
		DEBUGPRINTF(("xfs_drv_close: NULL dmd\n"));
		return EFAULT;
	}
#endif
	if (dmd->d_xfs != &hostxfs || (dd = get_root_dd(dmd->d_drive)) == NULL)
		return EDRIVE;

	if (dmd->d_root)
	{
		xfs_release(&dd->fc);
		kernel_int_mfree(dmd->d_root);
		dmd->d_root = NULL;
	}
	
	dd->dd.dd_dmd = 0;
	dd->dd.dd_refcnt = 0;
	
	return E_OK;
}


static void dd_readlink(HOSTXFS_DD *dd)
{
	(void) dd;
}


/*******************************************************************
 *
 * Hier wird die gesamte Pfadverwaltung erledigt. Im Gegensatz
 * zu MiNT muessen wir alles selbst erledigen. Symbolische Links
 * werden allerdings vom Kernel dereferenziert; wir brauchen sie
 * nur auszulesen.
 *
 * Eingabeparameter:
 *
 *  <mode>         Legt fest, ob das letzte Pfadelement selbst ein
 *                 Verzeichnis ist (mode == 1), oder ob der Pfad
 *                 ermittelt werden soll, in dem diese Datei liegt.
 *
 *  <reldir>       Das Verzeichnis, von dem aus gesucht werden soll.
 *
 *  <pathname>     Der Pfadname, ohne Laufwerkbuchstaben und ohne
 *                 fuehrendes '\'.
 *
 *
 * Ausgabeparameter:
 *
 *  1. Fall: Es ist ein Fehler aufgetreten
 *
 *  <d0>           enthaelt den Fehlercode
 *
 *  2. Fall: Ein Verzeichnisdeskriptor (DD) konnte ermittelt werden
 *
 *  <d0>           Zeiger auf den DD. Der Referenzzaehler des DD wurde
 *                 vom XFS um 1 erhoeht.
 *
 *  <d1>           Zeiger auf den restlichen Dateinamen ohne
 *                 beginnenden '\' bzw. '/'. Wenn das Ende des Pfades
 *                 erreicht wurde, zeigt dieser Zeiger auf das
 *                 abschliessende Nullbyte.
 *
 *  3. Fall: Das XFS ist bei der Pfadauswertung auf einen symbolischen
 *           Link gestossen
 *
 *  <d0>           enthaelt den internen Mag!X- Fehlercode ELINK
 *
 *  <d1>           Zeiger auf den restlichen Pfad ohne
 *                 beginnenden '\' bzw. '/'
 *
 *  <a0>           enthaelt den DD des Pfades, in dem der symbolische
 *                 Link liegt. Der Referenzzaehler des DD wurde vom XFS
 *                 um 1 erhoeht.
 *
 *  <a1>           ist der Zeiger auf den Link selbst. Ein Link beginnt
 *                 mit einem Wort (16 Bit) fuer die Laenge des Pfads,
 *                 gefolgt vom Pfad selbst.
 *
 *                 Achtung: Die Laenge muss INKLUSIVE abschliessendes
 *                          Nullbyte und ausserdem gerade sein. Der Link
 *                          muss auf einer geraden Speicheradresse
 *                          liegen.
 *
 *                 Der Puffer fuer den Link kann statisch oder auch
 *                 fluechtig sein, da der Kernel die Daten sofort
 *                 umkopiert, ohne dass zwischendurch ein Kontextwechsel
 *                 stattfinden kann.
 *
 *                 Wird a1 == NULL uebergeben, wird dem Kernel
 *                 signalisiert, dass der Parent des
 *                 Wurzelverzeichnisses angewaehlt wurde. Befindet sich
 *                 der Pfad etwa auf U:\A, kann der Kernel auf U:\
 *                 zurueckgehen. Der Wert des Rueckgabewert des Registers
 *                 a0 wird vom Kernel ignoriert, es darf daher kein
 *                 Rerenzzaehler erhoeht werden.
 *
 *******************************************************************/

static LONG __CDECL xfs_path2DD(MX_DD *reldir, const char *path, WORD mode, const char **lastpath, MX_DD **symlink_dd, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)reldir;
	LONG err;
	char temp[HOSTFS_NAMEMAX + 1];
	WORD dirlookup = mode;
	const char *nullbyte;
	const char *next;
	const char *current;
	HOSTXFS_DD *found;

	DEBUGPRINTF(("xfs_path2DD drive=%d path=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, path));
	*symlink = NULL;
	*symlink_dd = NULL;
	/* check the dd for validity */
	if ((err = check_dd(dd)) < 0)
		return err;
	/* check the path for validity */
	if (path == NULL)
		return dirlookup ? EPTHNF : ENOENT;
	/* remember the end of the path */
	nullbyte = strchr(path, '\0');
	
	next = path;
	for (;;)
	{
		/* skip leading slashes */
		while (*next == '\\' || *next == '/')
			next++;
		/*
		 * if we are not at the end, the dd must be a directory
		 */
		if (*next)
		{
			if (!S_ISDIR(dd->st_mode))
				return ENOTDIR;
			else if (!xaccess(dd->st_mode))
				return EACCES;
		}
		if (*next == '\0')
		{
			increase_refcnts(dd);
			*lastpath = path;
			return (LONG)dd;
		}
		
		path = current = next;
		next = strchr(path, '\\');
		if (next == NULL)
			next = strchr(path, '/');
		if (next != NULL)
		{
			size_t len = next - path;
			if (len > HOSTFS_NAMEMAX)
				len = HOSTFS_NAMEMAX;
			strncpy(temp, path, len);
			temp[len] = '\0';
			current = temp;
			/* skip slashes */
			while (*next == '\\' || *next == '/')
				next++;
		} else
		{
			/*
			 * we have the last component.
			 * when looking for a file, we are done
			 */
			if (!dirlookup)
			{
				increase_refcnts(dd);
				*lastpath = path;
				return (LONG)dd;
			}
			next = nullbyte;
		}
		
		if (is_dotdot(current))
		{
			if (&dd->dd == dd->dd.dd_dmd->d_root || dd->dd_parent == NULL)
			{
				*lastpath = next;
				*symlink_dd = &dd->dd;
				return ELINK;
			}
			dd = dd->dd_parent;
			continue;
		}
		
		if (is_dot(current))
			continue;
		
		if ((found = findfile(dd, current, FF_SEARCH, FALSE)) == NULL)
			return EPTHNF;
		
		if (S_ISLNK(found->st_mode))
		{
			dd_readlink(found);
			increase_refcnts(dd);
			*lastpath = next;
			*symlink_dd = &dd->dd;
			*symlink = found->dd_symlink;
			return ELINK;
		}
		
		if (!S_ISDIR(found->st_mode))
			return EPTHNF;
		
		found->dd_parent = dd;
		dd = found;
	}
}


static long xfs_closedir(HOSTXFS_DHD *dhd)
{
	long ret;

	ret = nf_call(HOSTFS(XFS_CLOSEDIR), &dhd->dir);
	if (ret == E_OK)
	{
		xfs_release(&dhd->dir.fc);
		kernel_int_mfree(dhd);
	}
	return ret;
}


static LONG search(HOSTXFS_DTA *dta)
{
	LONG ret;
	char truncname[8 + 3 + 1];
	char filename[256];
	HOSTXFS_DHD *dhd;
	fcookie entry;
	XATTR xattr;
	
	if (dta->dta_drive < 0)
		return ENMFIL;
	
	dhd = dta->dta_dhd;
	if ((ret = check_dhd(dhd)) < 0)
		return ret;
	
	for	(;;)
	{
		/* Wir lesen einen Verzeichniseintrag
		   und brechen bei einem Fehler sofort ab */

		ret = nf_call(HOSTFS(XFS_READDIR), &dhd->dir, filename, sizeof(filename), &entry);
		if (ret)
		{
			if (ret != ERANGE) /* name too long to fit in buffer */
				break;
			continue;
		}
		/* Wir wandeln den Dateinamen ins interne Format */
		kernel_conv_8_3(filename, truncname);

		xattr.st_attr = 0;
		nf_call(HOSTFS(XFS_GETXATTR), &entry, &xattr);
		xfs_release(&entry);
		
		truncname[11] = (char) xattr.st_attr;
		/* Wir rufen die Pattern-Match-Funktion des Kernels */
		if (kernel_match_8_3(dta->dta_sname, truncname))
			break;
	}

	if (ret)
	{
		dta->dta_drive = -1;	/* invalidate DTA */
		xfs_closedir(dhd);
		srchdir[dta->dta_srchdir] = 0;
		dta->dta_srchdir = -1;
		dta->dta_dhd = 0;
	} else
	{
		dta->dta_time = xattr.st_mtim.u.d.time;
		dta->dta_date = xattr.st_mtim.u.d.date;
		dta->dta_len = xattr.st_size;

		kernel_rcnv_8_3(truncname, dta->dta_name);
		dta->dta_attrib = truncname[11];
	}

	return ret;
}


/*******************************************************************
 *
 * Search for first matching file. 
 *
 * Im Gegensatz zu MiNT muessen Fsfirst() und Fsnext() im XFS
 * erledigt werden, was einen ziemlichen Aufwand bedeutet.
 *
 * Uebrigens funktioniert das XFS auch ohne Fsfirst/-next(),
 * da alle MagiX-Dienstprogramme sowie alle modernen Programme
 * ausschliesslich Dopendir/readdir/closedir verwenden.
 *
 *******************************************************************/

static LONG __CDECL xfs_sfirst(MX_DD *_dd, const char *name, DTA *dta, WORD attrib, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DTA *xdta = (HOSTXFS_DTA *)dta;
	int i;
	HOSTXFS_DHD *dhd;
	
	DEBUGPRINTF(("xfs_sfirst drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;

	/* Das Suchmuster wird in 8+3 gewandelt und zusammen
	   mit dem Suchattribut in die DTA kopiert */

	kernel_conv_8_3(name, xdta->dta_sname);
	xdta->dta_sname[11] = (char) attrib;

	/* Informationen ueber das Verzeichnis werden in
	   die DTA kopiert. Dass dta_drive vom XFS initialisiert
	   werden muss, ist leider notwendig */

	xdta->dta_drive = dd->dd.dd_dmd->d_drive;
	
	/* Now, see if we can find a DIR slot for the search. We use the
	 * following heuristics to try to avoid destroying a slot:
	 * (1) if the search doesn't use wildcards, don't bother with a slot
	 * (2) if an existing slot was for the same DTA address, re-use it
	 * (3) if there's a free slot, re-use it. Slots are freed when the
	 *     corresponding search is terminated.
	 */

	for (i = 0; i < NUM_SEARCH; i++)
	{
		if (srchdir[i] && srchdir[i]->dir.dta == dta)
		{
			dhd = srchdir[i];
			xfs_closedir(dhd);
			srchdir[i] = 0; /* slot is now free */
		}
	}

	/* Try to find a slot for an opendir/readdir search. */
	for (i = 0; i < NUM_SEARCH; i++)
	{
		if (srchdir[i] == 0)
			break;
	}
	if (i == NUM_SEARCH)
		return ENHNDL;
	
	dhd = kernel_int_malloc();
	dhd->dhd.dhd_dmd = dd->dd.dd_dmd;
	dhd->dir.fc = dd->fc;
	dhd->dir.flags = TOS_SEARCH;
#if PARANOIA
	dhd->dhd_magic = DHD_MAGIC;
#endif
	err = nf_call(HOSTFS(XFS_OPENDIR), &dhd->dir, (long)dhd->dir.flags);
	if (err != 0)
	{
		kernel_int_mfree(dhd);
		return err;
	}
	dhd->dir.dta = xdta;
	xdta->dta_dhd = dhd;
	xdta->dta_srchdir = i;
	srchdir[i] = dhd;
	
	/* Jetzt die Suche */
	err = search(xdta);
	if (err == ENMFIL)
		err = ENOENT;
	return err;
}


/*******************************************************************
 *
 * Search for the next matching file.
 * 
 * The DTA is already initialized.
 *
 *******************************************************************/

static LONG __CDECL xfs_snext(DTA *dta, MX_DMD *dmd, void **symlink)
{
	HOSTXFS_DTA *xdta = (HOSTXFS_DTA *)dta;

	DEBUGPRINTF(("xfs_snext drive=%d\n", dmd ? dmd->d_drive : -1));
	UNUSED(dmd);
	*symlink = NULL;
	return search(xdta);
}


/*******************************************************************
 *
 * Opens or creates a file.
 *
 * Note that in our case we don't have to bother with access permissions,
 * since that can also be done by the host.
 *
 *******************************************************************/

static LONG __CDECL xfs_fopen(MX_DD *_dd, const char *name, WORD omode, WORD attrib, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	LONG err;
	HOSTXFS_DD *found;
	HOSTXFS_FD *fd;
	
	DEBUGPRINTF(("xfs_fopen drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;
	/*
	 * This ceck ist not strictly needed, because findfile already
	 * does it, but we want to return EACCES
	 */
	if (!xaccess(dd->st_mode))
	{
		DEBUGPRINTF(("fopen: missing x-Bit\n"));
		return EACCES;
	}
	/*
	 * When O_CREATE or O_TRUNC are set, wee need also write access
	 */
	if (((omode & O_CREAT) || (omode & O_TRUNC)) &&
		(omode & OM_WPERM) != OM_WPERM)
	{
		DEBUGPRINTF(("fopen: O_CREAT without OW_PERM\n"));
		return EACCES;
	}
	/*
	 * Search for file, without 8+3-comparison when we create it,
	 * else with
	 */
	if ((omode & (OM_WPERM | O_CREAT | O_TRUNC)) == (OM_WPERM | O_CREAT | O_TRUNC))
	{
		found = findfile(dd, name, FF_EXIST, 0);
	} else
	{
		found = findfile(dd, name, FF_SEARCH, 0);
	}
	
	if (found != NULL)
	{
		/*
		 * If the file is found and it is a symbolic link, that must
		 * be signaled to the kernel
		 */
		if (S_ISLNK(found->st_mode))
		{
			DEBUGPRINTF(("fopen: following symlink to %s\n",
				found->dd_symlink ? found->dd_symlink->name : "(nil)"));
			*symlink = found->dd_symlink;
			free_dd(found, TRUE);
			return ELINK;
		}
		/* Directories can't be opened */
		if (S_ISDIR(found->st_mode))
		{
			free_dd(found, TRUE);
			return EISDIR;
		}
		/* writing to read-only files is not allowed either */
		if ((omode & OM_WPERM) && !waccess(found->st_mode))
		{
			DEBUGPRINTF(("fopen: OM_WPERM for read-only file\n"));
			free_dd(found, TRUE);
			return EACCES;
		}
		/*
		 * If the O_CREAT and O_EXCL modes are set,
		 * EACCES must be supplied because it was desired
		 * to create a new file that does not yet exist
		 */
		if ((omode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
		{
			DEBUGPRINTF(("fopen: file exists and O_CREAT und O_EXCL are requested!\n"));
			free_dd(found, TRUE);
			return EACCES;
		}
	}
	
	if (found == NULL)
	{
		/*
		 * The file did not exist yet, so it must be created.
		 * O_CREAT must be set for this, otherwise only one has been opened
		 * already existing file and we must return ENOENT
		 */
		if (!(omode & O_CREAT))
		{
			DEBUGPRINTF(("fopen: file not found and no O_CREAT!\n"));
			return ENOENT;
		}

		/* Don't allow "." oder "..", just in case */
		if (is_dot(name) || is_dotdot(name))
		{
			DEBUGPRINTF(("fopen: Name is \".\" or \"..\"!\n"));
			return EACCES;
		}
  		found = new_dd(dd, name, NULL);
  		if (found == NULL)
  			return EACCES;

		/* set x-Flag if needed */
		if ((omode & OM_EXEC) || has_xext(name))
			found->st_mode |= S_IXUSR | S_IXGRP | S_IXOTH;
		/* restrict access if needed */
		if (attrib & FA_RDONLY)
		{
			found->st_mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);
			attrib = FA_RDONLY | FA_CHANGED;
		} else
		{
			attrib = FA_CHANGED;
		}
	}

	/*
	 * create a FD and return it
	 */
	fd = new_fd(dd);
	if (fd == NULL)
	{
		xfs_release(&dd->fc);
		return ENOMEM;
	}
	fd->fd.fd_mode = omode;
	if (omode & O_CREAT)
		err = nf_call(HOSTFS(XFS_CREATE), &dd->fc, name, (long)found->st_mode, (long)attrib, &fd->fp.fc);
	else
		fd->fp.fc = found->fc;
	if (err == 0)
		err = nf_call(HOSTFS(DEV_OPEN), &fd->fp);
	fd->st_mode = found->st_mode;
	free_dd(found, TRUE);
	if (err < 0)
	{
		cdecl_hostdev.dev_close(&fd->fd);
		return err;
	}
	return (LONG)fd;
}


/*******************************************************************
 *
 * Deletes a file.
 *
 *******************************************************************/

static LONG __CDECL xfs_fdelete(MX_DD *_dd, const char *name)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD *found;

	DEBUGPRINTF(("xfs_fdelete drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	if ((err = check_dd(dd)) < 0)
		return err;

	/* Die Datei suchen; existiert sie nicht, Fehler melden */
	if ((found = findfile(dd, name, FF_SEARCH, 0)) == NULL)
		return ENOENT;

	err = nf_call(HOSTFS(XFS_REMOVE), &found->fc, name);
	xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * Required for Frename and Flink.
 *
 *******************************************************************/

static LONG __CDECL xfs_link(MX_DD *_olddd, MX_DD *_newdd, const char *oldname, const char *newname, WORD flag_link)
{
	HOSTXFS_DD *olddd = (HOSTXFS_DD *)_olddd;
	HOSTXFS_DD *newdd = (HOSTXFS_DD *)_newdd;
	long err;
	HOSTXFS_DD *oldfc, *newfc;
	char temp[HOSTFS_NAMEMAX + 1];
	
	DEBUGPRINTF(("xfs_link drive=%d name=%s -> drive=%d name=%s\n", olddd && olddd->dd.dd_dmd ? olddd->dd.dd_dmd->d_drive : -1, oldname, newdd && newdd->dd.dd_dmd ? newdd->dd.dd_dmd->d_drive : -1, newname));
	if ((err = check_dd(olddd)) < 0)
		return err;
	if ((err = check_dd(newdd)) < 0)
		return err;

	/* check name */
	if (!check_name(newname))
		return EACCES;

	/*
	 * Truncate the new name to maximum length,
	 * and convert it to lowercase if the process is running on the TOS domain.
	 */
	strcpy_name(temp, newname);
	if (p_Pdomain() == 0)
		strlwr(temp);
	newname = temp;

	/*
	 * the old file must exist
	 */
	if ((oldfc = findfile(olddd, oldname, FF_SEARCH, 0)) == NULL)
	{
		return ENOENT;
	}

	/*
	 * the new file must not exist
	 */
	if ((newfc = findfile(newdd, newname, FF_EXIST, 0)) != NULL)
	{
		xfs_release(&newfc->fc);
		free_dd(newfc, TRUE);
		xfs_release(&oldfc->fc);
		free_dd(oldfc, TRUE);
		return EACCES;
	}
	if (flag_link)
		err = nf_call(HOSTFS(XFS_HARDLINK), &olddd->fc, oldname, &newdd->fc, newname);
	else
		err = nf_call(HOSTFS(XFS_RENAME), &olddd->fc, oldname, &newdd->fc, newname);

	xfs_release(&oldfc->fc);
	free_dd(oldfc, TRUE);
	
	return err;
}


/*******************************************************************
 *
 * Required for Fxattr.
 *
 *******************************************************************/

static LONG __CDECL xfs_xattr(MX_DD *_dd, const char *name, XATTR *xattr, WORD mode, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD *found;

	DEBUGPRINTF(("xfs_xattr drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;

	/* lookup the file */
	if ((found = findfile(dd, name, FF_SEARCH, 1)) == NULL)
	{
		DEBUGPRINTF(("xattr: %s not found\n", name));
		return ENOENT;
	}

	/*
	 * If the file is a symlink, report it
	 */
	if (!mode && S_ISLNK(found->st_mode))
	{
		DEBUGPRINTF(("xattr: follow symlink to %s\n",
			found->dd_symlink ? found->dd_symlink->name : "(nil)"));
		*symlink = found->dd_symlink;
		err = ELINK;
	} else
	{
		err = nf_call(HOSTFS(XFS_GETXATTR), &found->fc, xattr);
	}
	if (found != dd && &found->dd != found->dd.dd_dmd->d_root)
		xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * Required for Fattrib
 *
 * Im Gegensatz zu MiNT fuehrt der MagiX-Kernel diese Funktion
 * nicht auf Fxattr() zurueck. Wir machen das aber hier, weil Zeit
 * beim Fattrib()-Aufruf keine grosse Rolle spielt.
 *
 *******************************************************************/

static LONG __CDECL xfs_attrib(MX_DD *_dd, const char *name, WORD mode, WORD attrib, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	XATTR xattr;
	long err;
	HOSTXFS_DD *found;
	
	DEBUGPRINTF(("xfs_attrib drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_SEARCH, 1)) == NULL)
		return ENOENT;
	if (mode)
	{
		err = nf_call(HOSTFS(XFS_CHATTR), &found->fc, (long)attrib);
	} else
	{
		err = nf_call(HOSTFS(XFS_GETXATTR), &found->fc, &xattr);
		if (err == 0)
			err = xattr.st_attr & 0xff;
	}
	if (found != dd)
		xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * xfs_chown alters the owner (user ID and group ID) of a file.
 * The parameters correspond to those of Fchown16.
 *
 *******************************************************************/

static LONG __CDECL xfs_chown16(MX_DD *_dd, const char *name, UWORD uid, UWORD gid, WORD follow_links, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD *found;
	
	DEBUGPRINTF(("xfs_chown drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_SEARCH, 1)) == NULL)
		return ENOENT;
	if (follow_links && S_ISLNK(found->st_mode))
	{
		DEBUGPRINTF(("chown: follow symlink to %s\n",
			found->dd_symlink ? found->dd_symlink->name : "(nil)"));
		*symlink = found->dd_symlink;
		err = ELINK;
	} else
	{
		err = nf_call(HOSTFS(XFS_CHOWN), &found->fc, (long)uid, (long)gid);
	}
	if (found != dd)
		xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * xfs_chown alters the owner (user ID and group ID) of a file.
 * The parameters correspond to those of Fchown.
 * Symbolic links are not followed, i.e. owner and group of the
 * symbolic link are modified. 
 *
 *******************************************************************/

static LONG __CDECL xfs_chown(MX_DD *dd, const char *name, UWORD uid, UWORD gid, void **symlink)
{
	return xfs_chown16(dd, name, uid, gid, 0, symlink);
}


/*******************************************************************
 *
 * xfs_chmod alters the access rights of a file.
 * The parameters correspond to those of Fchmod.
 * Note that symbolic links are always followed. 
 *
 *******************************************************************/

static LONG __CDECL xfs_chmod(MX_DD *_dd, const char *name, UWORD mode, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD *found;
	
	DEBUGPRINTF(("xfs_chmod drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	*symlink = 0;
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_SEARCH, 1)) == NULL)
		return ENOENT;
	if (S_ISLNK(found->st_mode))
	{
		DEBUGPRINTF(("chmod: follow symlink to %s\n",
			found->dd_symlink ? found->dd_symlink->name : "(nil)"));
		*symlink = found->dd_symlink;
		err = ELINK;
	} else
	{
		err = nf_call(HOSTFS(XFS_CHMOD), &found->fc, (long)mode);
	}
	if (found != dd)
		xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * Create a directory. 
 *
 *******************************************************************/

static LONG __CDECL xfs_dcreate(MX_DD *_dd, const char *name, UWORD mode)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	
	DEBUGPRINTF(("xfs_dcreate drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	if ((err = check_dd(dd)) < 0)
		return err;
	/* older kernels don't pass that along */
	if (KERNEL.version <= 4)
		mode = S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH;
	err = nf_call(HOSTFS(XFS_MKDIR), &dd->fc, name, (long)mode);
	return err;
}


/*******************************************************************
 *
 * Delete a directory.
 * WTF: this will delete the directory DD refers to...
 *
 *******************************************************************/

static LONG __CDECL xfs_ddelete(MX_DD *_dd)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD copy;
	
	DEBUGPRINTF(("xfs_ddelete drive=%d\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1));
	if ((err = check_dd(dd)) < 0)
		return err;
	/*
	 * the root directory cannot be removed
	 */
	if (&dd->dd == dd->dd.dd_dmd->d_root || dd->dd_parent == NULL)
		return EACCES;
	if (KERNEL.version < 3)
	{
		/*
		 * kernel versions before 3 require us to do a refcnt check.
		 * If it is still in use, we must not delete the directory.
		 */
		if (--dd->dd.dd_refcnt > 0)
		{
			DEBUGPRINTF(("ddelete: refcnt == %d!\n", dd->dd.dd_refcnt));
			return EACCES;
		}
	}
	copy = *dd;
	if (KERNEL.version < 3)
		free_dd(dd, FALSE);

	err = nf_call(HOSTFS(XFS_RMDIR), &copy.fc, ".");
	return err;
}


/*******************************************************************
 *
 * Berechnet aus einem DD einen Pfadnamen.
 *
 * Im Prinzipt wie beim MiNT-XFS. Nur wird statt des fcookie
 * ein DD verwendet.
 *
 *******************************************************************/

static LONG __CDECL xfs_DD2name(MX_DD *_dd, char *buf, WORD buflen)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	HOSTXFS_DD *relto;
	
	DEBUGPRINTF(("xfs_DD2name drive=%d\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1));
	if ((err = check_dd(dd)) < 0)
		return err;
	relto = get_root_dd(dd->dd.dd_dmd->d_drive);
	err = nf_call(HOSTFS(XFS_GETNAME), &relto->fc, &dd->fc, buf, (long)buflen);
	return err;
}


/*******************************************************************
 *
 * Open a directory.
 *
 * Das Verzeichnis <dd> wird fuer den Dopendir/readdir- Mechanismus
 * geoeffnet.
 * Da hier der Suchvorgang des uebergeordneten Verzeichnisses schon
 * durchgefuehrt wurde, brauchen lediglich die relevanten Daten vom
 * dd in den dhd kopiert zu werden. Weiterhin muss der Dateizeiger
 * auf den ersten Verzeichniseintrag gesetzt werden und das
 * tosflag eingetragen werden.
 *
 *******************************************************************/

static LONG __CDECL xfs_dopendir(MX_DD *_dd, WORD tosflag)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	HOSTXFS_DHD *dhd;
	long err;

	DEBUGPRINTF(("xfs_dopendir drive=%d\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1));
	
	if ((err = check_dd(dd)) < 0)
		return err;
	if (!S_ISDIR(dd->st_mode))
		return ENOTDIR;
	dhd = kernel_int_malloc();
	if (dhd == NULL)
		return ENOMEM;
	dhd->dhd.dhd_dmd = dd->dd.dd_dmd;
	dhd->dir.fc = dd->fc;
	dhd->dir.flags = tosflag ? TOS_SEARCH : 0;
#if PARANOIA
	dhd->dhd_magic = DHD_MAGIC;
#endif
	err = nf_call(HOSTFS(XFS_OPENDIR), &dhd->dir, (long)dhd->dir.flags);
	if (err != 0)
	{
		kernel_int_mfree(dhd);
		return err;
	}
	return (LONG)&dhd->dhd;
}


/*******************************************************************
 *
 * Read next directory entry.
 *
 * Fuer D(x)readdir().
 * Ist im Prinzip wie beim MiNT-XFS. Es gibt jedoch keinen
 * fcookie, alle Informationen liegen im DHD.
 *
 * Weiterhin ist Dxreaddir() hier gleich drin.
 *
 *******************************************************************/

static LONG __CDECL xfs_dreaddir(MX_DHD *dhd, WORD buflen, char *buf, XATTR *xattr, LONG *xr)
{
	HOSTXFS_DHD *xdhd = (HOSTXFS_DHD *)dhd;
	long ret;
	fcookie entry;
		
	DEBUGPRINTF(("xfs_dreaddir\n"));
	if ((ret = check_dhd(xdhd)) < 0)
		return ret;
	ret = nf_call(HOSTFS(XFS_READDIR), &xdhd->dir, buf, (long)buflen, &entry);
	if (ret)
		return ret;
	
	if (xattr)
	{
		ret = nf_call(HOSTFS(XFS_GETXATTR), &entry, xattr);
		if (xr)
			*xr = ret;
	}
	xfs_release(&entry);
	return E_OK;
}


/*******************************************************************
 *
 * Fuer Drewinddir().
 * Im Prinzip wie beim MiNT-XFS.
 *
 *******************************************************************/

static LONG __CDECL xfs_drewinddir(MX_DHD *dhd)
{
	HOSTXFS_DHD *xdhd = (HOSTXFS_DHD *)dhd;
	long ret;

	DEBUGPRINTF(("xfs_drewinddir\n"));
	if ((ret = check_dhd(xdhd)) < 0)
		return ret;
	ret = nf_call(HOSTFS(XFS_REWINDDIR), &xdhd->dir);
	return ret;
}


/*******************************************************************
 *
 * Fuer Dclosedir().
 * Die Struktur fuer den DHD wird einfach freigegeben.
 *
 *******************************************************************/

static LONG __CDECL xfs_dclosedir(MX_DHD *dhd)
{
	HOSTXFS_DHD *xdhd = (HOSTXFS_DHD *)dhd;
	long err;
	
	DEBUGPRINTF(("xfs_dclosedir\n"));
	if ((err = check_dhd(xdhd)) < 0)
		return err;
	return xfs_closedir(xdhd);
}


/*******************************************************************
 *
 * Fuer Dpathconf().
 * Im Prinzip wie beim MiNT-XFS.
 *
 *******************************************************************/

static LONG __CDECL xfs_dpathconf(MX_DD *_dd, WORD which)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	
	DEBUGPRINTF(("xfs_dpathconf drive=%d which=%d\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, which));
	if ((err = check_dd(dd)) < 0)
		return err;
	nf_debugprintf("pathconf which=%d dd=%08lx dev=%u index=%08lx\n", which, dd, dd->fc.dev, dd->fc.index);
	err = nf_call(HOSTFS(XFS_PATHCONF), &dd->fc, (long)which);
	return err;
}


/*******************************************************************
 *
 * Fuer Dfree().
 * Im Prinzip wie beim MiNT-XFS.
 *
 *******************************************************************/

static LONG __CDECL xfs_dfree(MX_DD *_dd, DISKINFO *buf)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	
	DEBUGPRINTF(("xfs_dfree dmd=%08lx drive=%d\n", dd ? dd->dd.dd_dmd : NULL, dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1));
	if ((err = check_dd(dd)) < 0)
		return err;
	err = nf_call(HOSTFS(XFS_DFREE), &dd->fc, buf);
	return err;
}


/*******************************************************************
 *
 * Writes the disk name
 *
 *******************************************************************/

static LONG __CDECL xfs_wlabel(MX_DD *_dd, const char *name)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	
	DEBUGPRINTF(("xfs_wlabel drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	if ((err = check_dd(dd)) < 0)
		return err;
	err = nf_call(HOSTFS(XFS_WRITELABEL), &dd->fc, name);
	return err;
}


/*******************************************************************
 *
 * Reads the disk name
 *
 *******************************************************************/

static LONG __CDECL xfs_rlabel(MX_DD *_dd, const char *name, char *buf, WORD buflen)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	long err;
	
	DEBUGPRINTF(("xfs_rlabel drive=%d\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1));
	UNUSED(name); /* what is that for? */
	if ((err = check_dd(dd)) < 0)
		return err;
	err = nf_call(HOSTFS(XFS_READLABEL), &dd->fc, buf, (LONG)buflen);
	return err;
}


/*******************************************************************
 *
 * Create a symbolic link.
 *
 *******************************************************************/

static LONG __CDECL xfs_symlink(MX_DD *_dd, const char *name, const char *to)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	HOSTXFS_DD *found;
	long err;
	
	DEBUGPRINTF(("xfs_symlink drive=%d from=%s to=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name, to));
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_EXIST, 0)) != NULL)
	{
		xfs_release(&found->fc);
		free_dd(found, TRUE);
		return EACCES;
	}
	err = nf_call(HOSTFS(XFS_SYMLINK), &dd->fc, name, to);
	return err;
}


/*******************************************************************
 *
 * Read a symbolic link.
 *
 *******************************************************************/

static LONG __CDECL xfs_readlink(MX_DD *_dd, const char *name, char *buf, WORD buflen)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	HOSTXFS_DD *found;
	long err;
	
	DEBUGPRINTF(("xfs_readlink drive=%d name=%s\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name));
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_SEARCH, 0)) == NULL)
	{
		return ENOENT;
	}
	err = nf_call(HOSTFS(XFS_READLINK), &found->fc, buf, (long)buflen);
	xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}


/*******************************************************************
 *
 * Fuer Dcntl(). Auch hier im Gegensatz zu MiNT kein Umweg ueber
 * fcookies, sondern direkt der Zugriff ueber _eine_ XFS-Funktion.
 *
 *******************************************************************/

static LONG __CDECL xfs_dcntl(MX_DD *_dd, const char *name, WORD cmd, LONG arg, void **symlink)
{
	HOSTXFS_DD *dd = (HOSTXFS_DD *)_dd;
	HOSTXFS_DD *found;
	long err;
	
	DEBUGPRINTF(("xfs_dcntl drive=%d name=%s cmd=$%04x\n", dd && dd->dd.dd_dmd ? dd->dd.dd_dmd->d_drive : -1, name, cmd));
	*symlink = NULL;
	if ((err = check_dd(dd)) < 0)
		return err;
	if ((found = findfile(dd, name, FF_SEARCH, 1)) == NULL)
		return ENOENT;
	err = nf_call(HOSTFS(XFS_FSCNTL), &dd->fc, name, (long)cmd, arg);
	if (found != dd)
		xfs_release(&found->fc);
	free_dd(found, TRUE);
	return err;
}



static long __CDECL xfs_mknod(fcookie *dir, const char *name, unsigned long mode)
{
	return nf_call(HOSTFS(XFS_MKNOD), dir, name, mode);
}


static long hostfs_mount_drives(void)
{
	long r;
	int keep = 0;
	char mount_point[5];
	unsigned long drv_mask;
	unsigned short drv_number = 0;
	unsigned short devno;
	
	/* compare the version */
	if (nf_call(HOSTFS(GET_VERSION)) != HOSTFS_NFAPI_VERSION)
	{
		Cconws(MSG_PFAILURE("hostfs",
					"\r\nHOSTFS NFAPI version mismatch\n\r"));
		return ERROR;
	}
	drv_mask = fs_drive_bits();
	
	strcpy(mount_point, "U:\\X");
	
	Cconws("\r\nMounts: ");

	while (drv_mask)
	{
		/* search the 1st log 1 bit position -> drv_number */
		while (!(drv_mask & 1))
		{
			drv_number++;
			drv_mask >>= 1;
		}

		/* ready */
		if (drv_number >= 26)
			mount_point[3] = drv_number - 26 + '1';
		else
			mount_point[3] = drv_number + 'A';

		Cconws(mount_point);
		Cconws(" ");

		{
			/* init */
			
			devno = drv_number + 50;
			r = fs_native_init(devno, mount_point, "/", 0 /*caseSensitive*/,
									   &mint_hostfs_filesys, NULL);
			if (r < 0)
			{
				DEBUGPRINTF(("hostfs: return value was %ld\n", r));
			} else
			{
				HOSTXFS_DD *dd;
				
				dd = kernel_int_malloc();
				if (dd == NULL)
					break;
				
				keep = 1; /* at least one is mounted */
				/* set the drive bit */
				*((long *) 0x4c2L) |= 1UL << drv_number;

				mydrives[drv_number] = dd;
				dd->fc.fs = &mint_hostfs_filesys;
				dd->fc.dev = devno;
				dd->fc.aux = 0;
				dd->fc.index = 0;
				dd->dd.dd_dmd = 0;
				dd->dd.dd_refcnt = 0;
				dd->dd_parent = 0;
#if PARANOIA
				dd->dd_magic = DD_MAGIC;
#endif
			}
		}
	
		drv_number++;
		drv_mask >>= 1;
	}
	
	Cconws("\r\n");

	/* everything OK */
	if (keep)
		return E_OK; /* We where successfull */

    /* Nothing installed, so nothing to stay resident */
	return ERROR;
}


#if DEBUG
static long get_syshdr(void)
{
	return *((long *)0x4f2);
}
#endif


static LONG __CDECL xfs_init(void)
{
	LONG ret;

	DEBUGPRINTF(("xfs_init\n"));
	(void) Cconws("\033p HostFS Filesystem driver version " MSG_VERSION " \033q\r\n");
	(void) Cconws("\275 " MSG_BUILDDATE " Thorsten Otto\r\n");

	if (!get_cookie(C_MagX, NULL))
	{
		Cconws("The Host-XFS only works with MagiC 3 or better!\r\n");
		return ERROR;
	}
	
	nf_hostfs_id = nf_get_id("HOSTFS"); /* NF_ID_HOSTFS */
	if (nf_hostfs_id == 0)
	{
		if (nf_call == 0)
			Cconws("Native Features not present on this system\r\n");
		else
			Cconws(MSG_PFAILURE("hostfs",
					"\r\nThe HOSTFS NatFeat not found\r\n"));
		return EUNDEV;
	}
	
#if CALL_MAGIC_KERNEL
	p_kernel = &kernel;
	p_dfskernel = &dosxfs_kernel;
#else
	ret = Dcntl(MX_KER_GETINFO, NULL, 0);
	if (ret <= 0)
	{
		Cconws("Cannot get kernel info\r\n");
		return ERROR;					/* Error */
	}
	p_kernel = (MX_KERNEL *) ret;

	ret = Dcntl(MX_DFS_GETINFO, "U:\\", 0);
	if (ret <= 0)
	{
		Cconws("Cannot get dfs-kernel info\r\n");
		return ERROR;					/* Error */
	}
	p_dfskernel = (MX_DFSKERNEL *) ret;
#endif

#if CALL_MAGIC_KERNEL
	ret = hostfs_mount_drives();
#else
	ret = Supexec(hostfs_mount_drives);
#endif
	if (ret < 0)
		return ret;					/* Error */

#if DEBUG
	{
		SYSHDR *syshdr;
		AESVARS *aesvars;
		
		DEBUGPRINTF(("MagiC-Kernelversion %d\n", KERNEL.version));
#if CALL_MAGIC_KERNEL
		syshdr = *((syshdr **)0x4f2);
#else
		syshdr = (SYSHDR *)Supexec(get_syshdr);
#endif
		if (syshdr->os_magic)
		{
			aesvars = (AESVARS *)(syshdr->os_magic);
			if (aesvars &&
				aesvars->magic == 0x87654321L &&
				aesvars->magic2 == 0x4D414758L)
			{
				DEBUGPRINTF(("MagiC Version %04x %08lx\n", aesvars->version, aesvars->date));
			}
		}
	}
#endif

	/*
	 * check whether Pdomain is provided by kernel
	 */
	p_Pdomain = Pdomain_gemdos;
	if (KERNEL.version >= 2 && kernel_proc_info(0, _BasPag) >= 2)
	{
		p_Pdomain = Pdomain_kernel;
	}

	ret = Dcntl(MX_KER_INSTXFS, NULL, (LONG) &hostxfs);
	if (ret < 0)
		return ret;					/* Error */

	return E_OK;
}


#if 0 /* not needed by MagiC */
static MINT_DEVDRV *__CDECL xfs_getdev(fcookie *fc, long *devspecial)
{
	return (MINT_DEVDRV *) nf_call(HOSTFS(XFS_GETDEV), fc, devspecial);
}
#endif


#if 0 /* not needed by MagiC */
static long __CDECL xfs_dupcookie(fcookie *new, fcookie *old)
{
	return nf_call(HOSTFS(XFS_DUPCOOKIE), new, old);
}
#endif



#if 0 /* NYI by MagiC */
static long __CDECL xfs_stat64(fcookie *file, struct stat *xattr)
{
	return nf_call(HOSTFS(XFS_STAT64), file, xattr);
}
#endif


#if 0 /* handled by xfs_fopen */
static long __CDECL xfs_creat(fcookie *dir, const char *name, unsigned short mode, short attrib, fcookie *fc)
{
	return nf_call(HOSTFS(XFS_CREATE), dir, name, (long)mode, (long)attrib, fc);
}
#endif


#if 0 /* NYI by MagiC */
static long __CDECL xfs_unmount(short drv)
{
	return nf_call(HOSTFS(XFS_UNMOUNT), (long)drv);
}
#endif




/*
 * Die cdecl-XFS-Struktur fuer den Assembler-Umsetzer:
 */
CDECL_MX_XFS const cdecl_hostxfs = {
	"HOSTFS",
	NULL,
	0,
	xfs_init,
	xfs_sync,
	xfs_pterm,
	xfs_garbcoll,
	xfs_freeDD,
	xfs_drv_open,
	xfs_drv_close,
	xfs_path2DD,
	xfs_sfirst,
	xfs_snext,
	xfs_fopen,
	xfs_fdelete,
	xfs_link,
	xfs_xattr,
	xfs_attrib,
	xfs_chown,
	xfs_chmod,
	xfs_dcreate,
	xfs_ddelete,
	xfs_DD2name,
	xfs_dopendir,
	xfs_dreaddir,
	xfs_drewinddir,
	xfs_dclosedir,
	xfs_dpathconf,
	xfs_dfree,
	xfs_wlabel,
	xfs_rlabel,
	xfs_symlink,
	xfs_readlink,
	xfs_dcntl
};
