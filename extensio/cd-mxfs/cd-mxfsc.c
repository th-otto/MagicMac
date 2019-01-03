/*
**
** Dies ist das Hauptmodul des CD-XFS fuer MagiX
** Entwickelt mit PureC und Pasm.
**
** basiert auf Julian Reschkes XFS fÅr MiNT+Metados
** und verwendet dessen Bibliothek libcdfs.lib
**
** (C) Andreas Kromke 1997
**
*/

#include <string.h>
#include <ctype.h>
#include <sys/stat.h>
#include "cd-mxfs.h"
#include "cdfs.h"
#include "metados.h"
#include "macfs.h"

#include "version.h"

/*
* Das sind alle cdecl-Pendants der XFS-Funktionen:
*/

static void cdecl	xfs_sync( MX_DMD *dmd );
static void cdecl	xfs_pterm( MX_DMD *dmd, PD *pd );
static LONG cdecl	xfs_garbcoll( MX_DMD *dmd );
static void cdecl	xfs_freeDD( MX_DD *dd );
static LONG cdecl   xfs_drv_open( MX_DMD *dmd );
static LONG cdecl   xfs_drv_close( MX_DMD *dmd, WORD mode );
static LONG cdecl xfs_path2DD( MX_DD *dd, const char *path, WORD mode,
     						const char **restp, MX_DD **symlink_dd,
     						void **symlink );
static LONG cdecl	xfs_sfirst( MX_DD *dd, const char *name, DTA *dta,
     						WORD attrib, void **symlink );
static LONG cdecl	xfs_snext( DTA *dta, MX_DMD *dmd, void **symlink );
static LONG cdecl	xfs_fopen( MX_DD *dd, const char *name, WORD omode,
     						WORD attrib, void **symlink );
static LONG cdecl	xfs_fdelete( MX_DD *dd, const char *name );
static LONG cdecl	xfs_link( MX_DD *altdd, MX_DD *neudd,
							const char *altname, const char *neuname,
							WORD flag );
static LONG cdecl	xfs_xattr( MX_DD *dd, const char *name, XATTR *xa,
							WORD mode, void **symlink );
static LONG cdecl	xfs_attrib( MX_DD *dd, const char *name, WORD mode,
							WORD attrib, void **symlink );
static LONG cdecl   xfs_chown( MX_DD *dd, const char *name, UWORD uid,
							UWORD gid, void **symlink );
static LONG cdecl   xfs_chmod( MX_DD *dd, const char *name, UWORD mode, void **symlink );
static LONG cdecl   xfs_dcreate( MX_DD *dd , const char *name, UWORD mode );
static LONG cdecl   xfs_ddelete( MX_DD *dd );
static LONG cdecl   xfs_DD2name( MX_DD *dd, char *buf, WORD buflen );
static LONG cdecl   xfs_dopendir( MX_DD *d, WORD tosflag );
static LONG cdecl   xfs_dreaddir( MX_DHD *dh, WORD len, char *buf,
							XATTR *xattr, LONG *xr );
static LONG cdecl   xfs_drewinddir( MX_DHD *dhd );
static LONG cdecl   xfs_dclosedir( MX_DHD *dhd );
static LONG cdecl   xfs_dpathconf( MX_DD *dd, WORD which );
static LONG cdecl   xfs_dfree( MX_DD *dd, DISKINFO *buf );
static LONG cdecl   xfs_wlabel( MX_DD *dd, const char *name );
static LONG cdecl   xfs_rlabel( MX_DD *dd, const char *name, char *buf,
     						WORD buflen );
static LONG cdecl   xfs_symlink( MX_DD *dd, const char *name, const char *to);
static LONG cdecl   xfs_readlink( MX_DD *dd, const char *name, char *buf,
     						WORD buflen );
static LONG cdecl   xfs_dcntl( MX_DD *dd, const char *name, WORD cmd,
     						LONG arg, void **symlink );

/*
* Das sind alle cdecl-Pendants der Device-Funktionen:
*/

static LONG cdecl	dev_close( MX_FD *f );
static LONG cdecl	dev_read( MX_FD *f, LONG count, void *buf );
static LONG cdecl	dev_write( MX_FD *f, LONG count, void *buf );
static LONG cdecl	dev_stat( MX_FD *f, MAGX_UNSEL *unselect,
							WORD rwflag, LONG apcode );
static LONG cdecl	dev_seek( MX_FD *f, LONG where, WORD mode );
static LONG cdecl	dev_datime( MX_FD *f, WORD d[2], WORD set);
static LONG cdecl	dev_ioctl( MX_FD *f, WORD cmd, void *buf );
static LONG cdecl	dev_getc( MX_FD *f, WORD mode );
static LONG cdecl	dev_getline( MX_FD *f, char *buf, WORD mode, LONG size );
static LONG cdecl	dev_putc( MX_FD *f, WORD mode, LONG val );


/*
* hier fÅr das Blockdevice
*/

static LONG cdecl	blkdev_open( MX_DOSFD *f );
static LONG cdecl	blkdev_close( MX_DOSFD *f );
static LONG cdecl	blkdev_read( MX_DOSFD *f, LONG count, void *buf );
static LONG cdecl	blkdev_write( MX_DOSFD *f, LONG count, void *buf );
static LONG cdecl	blkdev_stat( MX_DOSFD *f, LONG *unselect,
							WORD rwflag, LONG apcode );
static LONG cdecl	blkdev_seek( MX_DOSFD *f, LONG where, WORD mode );
static LONG cdecl	blkdev_datime( MX_DOSFD *f, WORD d[2], WORD set);
static LONG cdecl	blkdev_ioctl( MX_DOSFD *f, WORD cmd, void *buf );
static LONG cdecl	blkdev_delete( MX_DOSFD *dir_f, MX_DOSDIR *dir );

static int firstdrive = -1;

/*
* Die cdecl-XFS-Struktur fÅr den Assembler-Umsetzer:
*/

CDECL_MX_XFS const cdecl_cdxfs = {
	"CDROM",
	NULL,
	0,
	NULL,
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

/*
* Die cdecl-Device-Struktur fÅr den Assembler-Umsetzer:
*/

CDECL_MX_DEV const cdecl_cddev = {
	dev_close,
	dev_read,
	dev_write,
	dev_stat,
	dev_seek,
	dev_datime,
	dev_ioctl,
	dev_getc,
	dev_getline,
	dev_putc
	};

/*
* Die cdecl-BlockDevice-Struktur fÅr den Assembler-Umsetzer:
*/

CDECL_MX_DDEV const cdecl_cdblkdev = {
	blkdev_open,
	blkdev_close,
	blkdev_read,
	blkdev_write,
	blkdev_stat,
	blkdev_seek,
	NULL,
	blkdev_ioctl,
	blkdev_delete,
	NULL,
	NULL,
	NULL
	};

/*
* Die Strukturen MX_DD und MX_FD sind im Sinne eines
* objektorientierten Ansatzes lediglich Basisobjekte
* der eigentlichen Deskriptoren. Diese eigentlichen
* Deskriptoren werden erst durch HinzufÅgen weiterer Felder
* (XFS-spezifisch) definiert:
*/

typedef struct cdxfs_dd {
	MX_DD dd;
	ULONG index;	/* Deskriptor laut CDFS.H */
	ULONG start,length;	/* DIRENTRY aus CDFS.H */
} CDXFS_DD;

typedef struct cdxfs_fd {
	MX_FD fd;
	ULONG index;	/* Deskriptor laut CDFS.H */
	ULONG pri_start,pri_length;	/* DIRENTRY aus CDFS.H */
	ULONG ass_start,ass_length;	/* DIRENTRY aus CDFS.H */
	long type,creator;
	unsigned int mtime,mdate;	/* DIRENTRY aus CDFS.H */
	char ass;	/* Flag "associated file" (resource fork) */
	ULONG pos;	/* Dateizeiger-Position */
} CDXFS_FD;

typedef struct cdxfs_dhd {
	MX_DHD dhd;
	ULONG index;
	WORD flags;
	MYFILE fp;	/* Deskriptor laut CDFS.H */
} CDXFS_DHD;

typedef struct cdxfs_dta {
/*   char      dta_res1[20];	20 Bytes fÅr Benutzerdaten */
	char		dta_sname[12];
	ULONG	dta_dirindex;
	ULONG	dta_dirend;
     char      dta_drive;		/* ab hier in MagiX festgelegt */
     char      dta_attrib;
     WORD      dta_time;
     WORD      dta_date;
     ULONG     dta_len;
     char      dta_name[14];
} CDXFS_DTA;

#if sizeof(CDXFS_DTA) != sizeof(DTA)
#error
#endif

MX_KERNEL *kernel;
MX_DFSKERNEL *dfskernel;
LOGICAL_DEV *mydrives[32];

/* CFG read: define OS macros and #include CFG reader */

#include "cfgread.c"


static char
to_digit (unsigned int num)
{
	if (num < 10) return '0' + num;
	
	return (num - 10) + 'a';
}


/********************** MAIN ***********************/

/* Konfigurationsdatei lesen */

int main (void)
{
	void * oldssp;
	LONG ret;
	int i;
	META_INFO_1 mi1;
	int first = 1;
	META_DEVINFO mdi;
	char buff[20];
	LOGICAL_DEV *ldp;
	
	Cconws ("\033p SPIN! CD filesystem "VERSIONSTRING" \033q\r\n");
	Cconws (     " Copyright (c) 1997   Julian F. Reschke\r\n");
	Cconws (     " MagiC-Umsetzung (c) 1997   Andreas Kromke\r\n");

	ret = Dcntl (KER_GETINFO, NULL, 0L);
	if (ret < E_OK) return ((WORD) ret);		/* Fehler */

	kernel = (MX_KERNEL *) ret;

	ret = Dcntl (DFS_GETINFO, "U:\\", 0L);
	if (ret < E_OK) return((WORD) ret);		/* Fehler */

	dfskernel = (MX_DFSKERNEL *) ret;

	if (sizeof(CDXFS_FD) > kernel->int_msize)
	{
		Cconws ("SPIN: internal error\n");
		return 1;
	}

	if (!read_config ())
		return 1;

	memset (&mi1, 0, sizeof (mi1));
	Metainit (&mi1);

	if (!mi1.mi_info)
	{
		ret = Pexec(0, "\\auto\\metaxbs.prg","",NULL);
		Metainit(&mi1);
	}
	if (!mi1.mi_info)
	{
		ret = Pexec(0, "\\auto\\metaxbs.prx","",NULL);
		Metainit(&mi1);
	}
	if (!mi1.mi_info)
	{
		ret = Pexec(0, "\\gemsys\\magic\\xtension\\metaxbs.sys","",NULL);
		Metainit(&mi1);
	}
	if	(!mi1.mi_info)
		{
		Cconws ("\007\033pMetaXBS not installed. "
				"No drives installed!\033q\r\n");
		return 1;
		}

	/* set up the drive bits */

	for (i = 0; i < 32; i++)
	{
		ldp = mydrives[i];
		if (ldp)
		{
			if (firstdrive < 0)
				firstdrive = i;	/* KrÅcke fÅr BlockDevice */

			oldssp = (void *) Super(0L);
			*(long *) 0x4c2L |= (1L << i);
			Super (oldssp);

			if (mi1.mi_info->mi_magic == '_MET' &&
				mi1.mi_info->mi_version >= 0x270)
			{
				/* WTF: messing with MetaDOS memory */
				char *log2phys = (char *)mi1.mi_info->mi_log2phys;
				log2phys[i] = ldp->metadevice;
			}
			
			sprintf(buff, "u:\\dev\\cmt%c.dsk", tolower (ldp->metadevice));
			
			mdi.mdi_magic = 'INFO';
			mdi.mdi_length = sizeof (mdi);

			if (0 == Metaioctl (ldp->metadevice, METADOS_IOCTL_MAGIC,
				METAGETDEVINFO, &mdi))
			{
				strcpy (buff, "u:\\dev\\cxtxdxs0.dsk");
				buff[8] = '0' + (mdi.mdi_major / 8);
				buff[10] = '0' + (mdi.mdi_major & 7);
				buff[12] = '0' + (mdi.mdi_minor & 7);
				
				if (mdi.mdi_length >= offsetof (META_DEVINFO, mdi_lun))
				{
					buff[8] = to_digit (mdi.mdi_controller);
					buff[10] = to_digit (mdi.mdi_target);
					buff[12] = to_digit (mdi.mdi_lun);
				}
			}
			
			ldp->ddev = cdblkdev;
#if 0
			memset (&hld, (int) sizeof (hld), 0);
			hld.drvsize = sizeof (blk_device);
			hld.driver = &blk_device;
			hld.dinfo = i;
			hld.fmode = 00060444;
#endif

			/* Das erste CD-ROM bekommt einen "default"-Eintrag */
			if	(first)
				{
				Dcntl(DEV_M_INSTALL, "u:\\dev\\cdrom",
							(long) &ldp->ddev);
				first = 0;
				}
#if 1
			Dcntl (DEV_M_INSTALL, buff, (long) &ldp->ddev);
#endif
		}
	}

	ret = Dcntl(KER_INSTXFS, NULL, (LONG) &cdxfs);
	if	(ret < E_OK)
		return((WORD) ret);		/* Fehler */

	Ptermres(_PgmSize, E_OK);
	return 1;
}

/* convert a Unix time into a DOS time. The longword returned contains
   the time word first, then the date word.
   BUG: we completely ignore any time zone information.
*/

#define SECS_PER_MIN    (60L)
#define SECS_PER_HOUR   (3600L)
#define SECS_PER_DAY    (86400L)
#define SECS_PER_YEAR   (31536000L)
#define SECS_PER_LEAPYEAR (SECS_PER_DAY + SECS_PER_YEAR)

static int
days_per_mth[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

unsigned long
DMDosTime (unsigned long t)
{
    unsigned long time, date;
	int tm_hour, tm_min, tm_sec;
	int tm_year, tm_mon, tm_mday;
	int i;

	if (t <= 0) return 0;

	tm_year = 70;
	while (t >= SECS_PER_YEAR) {
		if ((tm_year & 0x3) == 0) {
			if (t < SECS_PER_LEAPYEAR)
				break;
			t -= SECS_PER_LEAPYEAR;
		} else {
			t -= SECS_PER_YEAR;
		}
		tm_year++;
	}
	tm_mday = (int)(t/SECS_PER_DAY);
        days_per_mth[1] = (tm_year & 0x3) ? 28 : 29;
        for (i = 0; tm_mday >= days_per_mth[i]; i++)
                tm_mday -= days_per_mth[i];
        tm_mon = i+1;
	tm_mday++;
        t = t % SECS_PER_DAY;
        tm_hour = (int)(t/SECS_PER_HOUR);
        t = t % SECS_PER_HOUR;
        tm_min = (int)(t/SECS_PER_MIN);
        tm_sec = (int)(t % SECS_PER_MIN);

	if (tm_year < 80) {
		tm_year = 80;
		tm_mon = tm_mday = 1;
		tm_hour = tm_min = tm_sec = 0;
	}

	time = (tm_hour << 11) | (tm_min << 5) | (tm_sec >> 1);
	date = ((tm_year - 80) & 0x7f) << 9;
	date |= ((tm_mon) << 5) | (tm_mday);
	return (time << 16) | date;
}


/*******************************************************************
*
* Dies ist ein Treiber, den MagiC verwendet, um Medien
* auszuwerfen. Es wird der <devcode> Åbergeben, der beim
* xfs_drv_open() im DMD eingetragen worden war.
*
* Im Gegensatz zu MiNT, das diese FunktionalitÑt Åberhaupt nicht
* unterstÅtzt, muû MagiC sicherstellen, daû alle Volumes auf
* einem Medium "unmounted" werden, bevor das Medium ausgeworfen
* wird. Ein Medium wird per d_driver und d_devcode eindeutig
* beschrieben.
*
*******************************************************************/

LONG cdecl cdecl_eject( WORD fn, LOGICAL_DEV *ldp )
{
	if	(fn == 0)
		{
		if	(ldp)
			{
			DKFlipPreferredReversed(ldp);
			return (Metaioctl (ldp->metadevice, METADOS_IOCTL_MAGIC,
						CDROMEJECT,(void *)0L));
			}
		return(EDRIVE);
		}
	else	return(EINVFN);
}


/*******************************************************************
*
* Frontend fÅr init_vol, das Medienwechsel abfragt und ggf. den
* Kernel informiert.
*
* Der RÅckgabewert von DKInitVolume() ist unverstÑndlich:
*
*	1	OK
*	3	keine CD eingelegt oder Medienwechsel (??!!??)
*
* RÅckgabewert von init_vol()
*
* E_OK		OK
* E_CHNG		Medienwechsel
* EDRIVE		Laufwerk ungÅltig
*
*******************************************************************/

static LONG init_vol (WORD drv)
{
	LOGICAL_DEV *ldp = mydrives[drv];
	int ret;


	ret = DKInitVolume (ldp);	/* nix eingelegt: 3 */

	if	(ret & 2)
		{

		/* diskchange liefert:

			EDRIVE  Laufwerk ungÅltig
               E_CHNG  Laufwerk mit neuer Disk gÅltig
          */
        DKFlipPreferredReversed(ldp);
#if 0
		DKFlipPreferred (ldp);		/* ???!!!??? */
		DKInitVolume (ldp);			/* ???!!!??? */
#endif
		return(kernel_diskchange (drv));
		}
	return (ret & 1) ? E_OK : EDRIVE;
}


/*******************************************************************
*
* Durchsucht ein Verzeichnis <dd> nach einer Datei mit dem
* Namen <name>.
*
* Im MiNT-XFS wird diese XFS-Funktion vom Kernel ausgefÅhrt,
* bevor die eigentliche XFS-Funktion ausgefÅhrt wird. MiNT benîtigt
* daher einen "fcookie", um die notwendigen Informationen zur
* XFS-Funktion weitergeben zu kînnen. Durch die begrenzte Grîûe
* dieses "fcookie" kînnen dabei aber nur wenige Daten aufgenommen
* werden, weshalb fÅr weiterere Dateioperationen wiederholt
* Zugriffe auf das Verzeichnis notwendig sind. Dieses Konzept ist
* einer der GrÅnde geringere Geschwindigkeit eines MiNT-XFS
* gegenÅber der MagiC-Version.
*
* Ein MagiC-XFS muû selbst den Namen im Verzeichnis suchen und
* hat so gleich alle erforderlichen Daten parat. Es wird gleich das
* komplette DIRENTRY statt nur eines "index" geliefert.
*
*******************************************************************/

static LONG lookup ( CDXFS_DD *dd, const char *name, ULONG *index,
				DIRENTRY *de )
{
	LOGICAL_DEV *ldp;
	unsigned long adr, dirend;
	LONG ret;
	

	ldp = mydrives[dd->dd.dd_dmd->d_drive];
	if	(E_OK != (ret = init_vol(dd->dd.dd_dmd->d_drive)))
		return( ret );

	/* ".." im Wurzelverzeichnis ? */
	/* --------------------------- */

	if	((dd->index == ldp->rootdir) && (!strcmp (name, "..")))
		return( ELINK );


	/* get directory entry for the directory */
	adr = dd->index;
	ret = ldp->fs.get_direntry (ldp, &adr, 0, de);
	if	(ret != E_OK)
		return( ret );

	/* Das Verzeichnis selbst ? */
	/* ------------------------ */

	if	(!*name || !strcmp (name, "."))
		{
		*index = dd->index;
		return( E_OK );
		}

	adr = de->pri.start; dirend = de->pri.start + de->pri.length;

	while(E_OK == ldp->fs.get_direntry (ldp, &adr, dirend, de))
		{
		int show_it = 0 == strcmp (name, de->longname);

		if	(!show_it && 0 != ldp->fs.pathconf (ldp, 6))
			show_it = 0 == stricmp (name, de->longname);

		if	(!show_it && (kernel->version >= 2) &&
				(0 == kernel_proc_info (1, *(kernel->act_pd))))
			show_it = 0 == stricmp (name, de->truncname);

		if	(show_it)
			{
			*index = de->tosattr & FA_SUBDIR ? de->pri.start
											: de->iindex;
/*
			ldp->lastde.inuse = 1;
			ldp->lastde.index = *index;
			ldp->lastde.de = *de;
*/
			return( E_OK );
			}
		}

	return( EFILNF );
}


/***************** hier die Funktionen des XFS ****************/

#pragma warn -par

/*******************************************************************
*
* Dateisystem synchronisieren.
* Wir brauchen hier nichts zu tun, weil wir keine
* Schreibpuffer haben.
*
*******************************************************************/

static void cdecl	xfs_sync( MX_DMD *dmd )
{
}


/*******************************************************************
*
* Wir kînnten hier die DHDs freigeben, hoffen aber, daû
* ein neuerer MagiC-Kernel diesen unkritischen Ausnahmefall
* irgendwann einmal fÅr uns erledigen wird.
*
*******************************************************************/

static void cdecl	xfs_pterm( MX_DMD *dmd, PD *pd )
{
}


/*******************************************************************
*
* Wir haben keine garbage collection
*
*******************************************************************/

static LONG cdecl	xfs_garbcoll( MX_DMD *dmd )
{
	return(0L);
}


/*******************************************************************
*
* Wir geben den DD einfach frei, weil die Dinger nicht
* verkettet sind.
*
*******************************************************************/

static void cdecl	xfs_freeDD( MX_DD *dd )
{
	kernel_int_mfree( dd );
}


/*******************************************************************
*
* Entspricht der Funktion "root" des MiNT-XFS.
*
* Wird beim ersten Zugriff auf das Laufwerk sowie zur Nachfrage
* eines Diskwechsels aufgerufen. Beim ersten Zugriff ist der
* Zeiger dmd->d_xfs noch NULL.
*
*******************************************************************/

static LONG cdecl   xfs_drv_open( MX_DMD *dmd )
{
	DIRENTRY de;
	LOGICAL_DEV *ldp;
	CDXFS_DD *root;
	long ret;
	ULONG adr;
	WORD drive;

	drive = dmd->d_drive;
	ldp = mydrives[drive];
	if	(!ldp)
		return( EDRIVE );

	if	(dmd->d_xfs)		/* Diskwechsel erfragen */
		return( init_vol(drive) );

	ret = DKInitVolume (ldp);	/* nix eingelegt: 3 */
#if 0
	if	( ret != 1 )
		return( EDRIVE );
#endif

	/* Daten fÅr das Wurzelverzeichnis ermitteln */

	adr = ldp->rootdir;
	ret = ldp->fs.get_direntry (ldp, &adr, 0, &de);
	if	(ret != E_OK)
		return( EDRIVE );

	/* DD fÅr Wurzelverzeichnis allozieren und eintragen */
	/* xfs-Treiberadresse eintragen */

	root = kernel_int_malloc();
	root->dd.dd_dmd = dmd;
	root->dd.dd_refcnt = 1;

	root->index = ldp->rootdir;
	root->start = de.pri.start;
	root->length = de.pri.length;

	dmd->d_root = &(root->dd);
	dmd->d_xfs = &cdxfs;
	dmd->d_devcode = (LONG) ldp;
	dmd->d_driver = (LONG) eject;
	return(E_OK);
}


/*******************************************************************
*
* Ein Laufwerk wird geschlossen.
* Ist <mode> == 1, kann sich das XFS nicht weigern und kann nur
* noch ggf. Strukturen freigeben.
* Ist <mode> == 0, kann ggf. EACCDN geliefert werden.
*
*******************************************************************/

static LONG cdecl   xfs_drv_close( MX_DMD *dmd, WORD mode )
{
	LOGICAL_DEV *ldp = mydrives[dmd->d_drive];

#if 0
	if	(mode)
		{
		kernel_int_mfree(dmd->d_root);
		dmd->d_root = NULL;
		return(E_OK);	/* Anfragemodus: immer OK */
		}
#endif
	kernel_int_mfree(dmd->d_root);
	dmd->d_root = NULL;
	DKFlipPreferred (ldp);
	return(E_OK);
}


/*******************************************************************
*
* Hier wird die gesamte Pfadverwaltung erledigt. Im Gegensatz
* zu MiNT mÅssen wir alles selbst erledigen. Symbolische Links
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
*                 fÅhrendes '\'.
*
*
* Ausgabeparameter:
*
*  1. Fall: Es ist ein Fehler aufgetreten
*
*  <d0>           enthÑlt den Fehlercode
*
*  2. Fall: Ein Verzeichnisdeskriptor (DD) konnte ermittelt werden
*
*  <d0>           Zeiger auf den DD. Der ReferenzzÑhler des DD wurde
*                 vom XFS um 1 erhîht.
*
*  <d1>           Zeiger auf den restlichen Dateinamen ohne
*                 beginnenden '\' bzw. '/'. Wenn das Ende des Pfades
*                 erreicht wurde, zeigt dieser Zeiger auf das
*                 abschlieûende Nullbyte.
*
*  3. Fall: Das XFS ist bei der Pfadauswertung auf einen symbolischen
*           Link gestoûen
*
*  <d0>           enthÑlt den internen Mag!X- Fehlercode ELINK
*
*  <d1>           Zeiger auf den restlichen Pfad ohne
*                 beginnenden '\' bzw. '/'
*
*  <a0>           enthÑlt den DD des Pfades, in dem der symbolische
*                 Link liegt. Der ReferenzzÑhler des DD wurde vom XFS
*                 um 1 erhîht.
*
*  <a1>           ist der Zeiger auf den Link selbst. Ein Link beginnt
*                 mit einem Wort (16 Bit) fÅr die LÑnge des Pfads,
*                 gefolgt vom Pfad selbst.
*
*                 Achtung: Die LÑnge muû INKLUSIVE abschlieûendes
*                          Nullbyte und auûerdem gerade sein. Der Link
*                          muû auf einer geraden Speicheradresse
*                          liegen.
*
*                 Der Puffer fÅr den Link kann statisch oder auch
*                 flÅchtig sein, da der Kernel die Daten sofort
*                 umkopiert, ohne daû zwischendurch ein Kontextwechsel
*                 stattfinden kann.
*
*                 Wird a1 == NULL Åbergeben, wird dem Kernel
*                 signalisiert, daû der Parent des
*                 Wurzelverzeichnisses angewÑhlt wurde. Befindet sich
*                 der Pfad etwa auf U:\A, kann der Kernel auf U:\
*                 zurÅckgehen. Der Wert des RÅckgabewert des Registers
*                 a0 wird vom Kernel ignoriert, es darf daher kein
*                 RerenzzÑhler erhîht werden.
*
*******************************************************************/

static LONG cdecl xfs_path2DD( MX_DD *dd, const char *path, WORD mode,
							const char **restp, MX_DD **symlink_dd,
							void **symlink )
{
	DIRENTRY de;
	char *nextelem;
	const char *s;
	CDXFS_DD *current;
	char pathelem[128];		/* Puffer fÅr ein Pfad-Element */
	LONG ret;
	ULONG index;
	size_t l;


	current = kernel_int_malloc();
	*current = *((CDXFS_DD *) dd);
	current->dd.dd_refcnt = 1;
	*symlink = NULL;		/* sicherheitshalber */
	*symlink_dd = NULL;

	while((NULL != (nextelem = strchr(path, '\\'))) ||
				((*path) && mode))
		{

		/* s hinter das Ende des Pfadelements */
		/* ---------------------------------- */

		s = (nextelem) ? nextelem : (path+strlen(path));
		l = s-path;

		/* öberlauf eines Pfadelements abfangen */
		/* ------------------------------------ */

		if	(l > 127)
			{
			kernel_int_mfree(current);
			return EPTHNF;
			}

		/* Pfadelement umkopieren -> pathelem[] */
		/* path schon weiterschalten		     */
		/* ------------------------------------ */	

		memcpy(pathelem, path, l);
		pathelem[l] = '\0';
		path = (nextelem) ? nextelem+1 : s;

		/* Sonderfall "." und ".." und ".." der root */
		/* werden von lookup() abgefangen...		*/
		/* Nur Verzeichnisse zÑhlen!				*/
		/* ----------------------------------------- */

		ret = lookup ( current, pathelem, &index, &de );
		if	((!ret) && !(de.mode & S_IFDIR))
			ret = EPTHNF;

		if	(ret)
			{
			if	(ret == EFILNF)
				ret = EPTHNF;
			kernel_int_mfree(current);
			return ret;
			}

		current->index = index;
		current->start = de.pri.start;
		current->length = de.pri.length;
		}

	*restp = path;
	return (LONG)&(current->dd);
}


/*******************************************************************
*
* Die eigentliche Suchroutine fÅr Fsfirst/next().
* Der Sonderfall fÅr den Mediennamen wird schon vom Kernel
* abgefangen und in Dreadlabel() umgesetzt.
*
*******************************************************************/

static LONG search ( WORD drive, CDXFS_DTA *dta, WORD first)
{
	LOGICAL_DEV *ldp;
	DIRENTRY de;
	LONG ret;
	char truncname[12];


	ldp = mydrives[drive];

	for	(;;)
		{

		/* Wir lesen einen Verzeichniseintrag
		   und brechen bei einem Fehler sofort ab */

		ret = ldp->fs.get_direntry (ldp, &dta->dta_dirindex,
								dta->dta_dirend, &de);
		if	(ret)
			break;

		/* Wir wandeln den Dateinamen ins interne Format */

		kernel_conv_8_3(de.truncname, truncname);
		truncname[11] = (char) de.tosattr;

		/* Wir rufen die Pattern-Match-Funktion des Kernels */

		if	(kernel_match_8_3(dta->dta_sname, truncname))
			break;
		}

	if	(ret)
		{
		if	((first) && (ret == ENMFIL))
			ret = EFILNF;
		dta->dta_drive = -1;	/* DTA sicherheitsh. ungÅltig! */
		}
	else	{
		dta->dta_time = de.mtime;
		dta->dta_date = de.mdate;
		dta->dta_len = de.pri.length;

		strcpy (dta->dta_name, de.truncname);

		dta->dta_attrib = de.tosattr;
		}

	return( ret );
}


/*******************************************************************
*
* Im Gegensatz zu MiNT mÅssen Fsfirst() und Fsnext() im XFS
* erledigt werden, was einen ziemlichen Aufwand bedeutet.
*
* öbrigens funktioniert das XFS auch ohne Fsfirst/-next(),
* da alle MagiX-Dienstprogramme sowie alle modernen Programme
* ausschlieûlich Dopendir/readdir/closedir verwenden.
*
*******************************************************************/

static LONG cdecl	xfs_sfirst( MX_DD *dd, const char *name, DTA *dta,
     						WORD attrib, void **symlink )
{
	LONG ret;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol(drive)))
		return( ret );

	/* Das Suchmuster wird in 8+3 gewandelt und zusammen
	   mit dem Suchattribut in die DTA kopiert */

	kernel_conv_8_3(name, ((CDXFS_DTA *) dta)->dta_sname);
	((CDXFS_DTA *) dta)->dta_sname[11] = (char) attrib;

	/* Informationen Åber das Verzeichnis werden in
	   die DTA kopiert. Daû dta_drive vom XFS initialisiert
	   werden muû, ist leider notwendig */

	((CDXFS_DTA *) dta)->dta_drive = drive;
	((CDXFS_DTA *) dta)->dta_dirindex = ((CDXFS_DD *)dd)->start;
	((CDXFS_DTA *) dta)->dta_dirend = ((CDXFS_DD *)dd)->start +
								((CDXFS_DD *)dd)->length;

	/* Jetzt die Suche */

	return( search ( drive, (CDXFS_DTA *) dta, 1) );
}


/*******************************************************************
*
* Bei Fsnext() ist die DTA schon initialisiert.
*
*******************************************************************/

static LONG cdecl	xfs_snext( DTA *dta, MX_DMD *dmd, void **symlink )
{
	return( search ( dmd->d_drive, (CDXFS_DTA *) dta, 0) );
}


/*******************************************************************
*
* Datei îffnen. Im Gegensatz zu MiNT ist dies eine XFS-Funktion.
* Wir mÅssen selber die Open-Modi und Zugriffsberechtigungen
* prÅfen.
*
* Im Gegensatz zum MiNT-Konzept merken wir uns hier bereits
* index,start,length. Die brauchen wir nÑmlich bei jedem
* Lesezugriff und sparen damit Zeit.
*
*******************************************************************/

static LONG cdecl	xfs_fopen( MX_DD *dd, const char *name, WORD omode,
     						WORD attrib, void **symlink )
{
	LONG ret;
	DIRENTRY de;
	ULONG index;
	CDXFS_FD *fd;


	/* erstmal suchen wir die Datei */
	/* ---------------------------- */

	if	(E_OK != (ret = init_vol (dd->dd_dmd->d_drive)))
		return ret;

	ret = lookup( (CDXFS_DD *) dd, name, &index, &de );
	if	((ret != E_OK) && (ret != EFILNF))
		return ret;

	/* Dann prÅfen wir alle Datei- und ôffnungsmodi */
	/* -------------------------------------------- */

	if	(ret)	/* Datei ex. noch nicht */
		{
		if	(omode & O_CREAT)
			return EWRPRO;
		return ret;
		}
	else	{
		if	(omode & (O_TRUNC /* +OM_WPERM */))
			return EWRPRO;
		if	(omode & O_EXCL)
			return EACCDN;

		fd = kernel_int_malloc();
		fd->fd.fd_dmd = dd->dd_dmd;
		fd->fd.fd_refcnt = 1;
		fd->fd.fd_mode = omode;
		fd->fd.fd_dev = &cddev;
		fd->pos = 0L;
		fd->pri_start = de.pri.start;
		fd->pri_length = de.pri.length;
		fd->ass_start = de.ass.start;
		fd->ass_length = de.ass.length;
		fd->type = de.type;
		fd->creator = de.creator;
		fd->mtime = de.mtime;
		fd->mdate = de.mdate;
		fd->index = index;
		fd->ass = 0;	/* "primary file", d.h. data fork */
		return (LONG)&(fd->fd);
		}
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Dateien kînnen nicht gelîscht werden.
*
*******************************************************************/

static LONG cdecl	xfs_fdelete( MX_DD *dd, const char *name )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Dateien kînnen weder umbenannt noch verschoben oder neue
* Links erstellt werden.
*
*******************************************************************/

static LONG cdecl	xfs_link( MX_DD *altdd, MX_DD *neudd,
						const char *altname, const char *neuname,
						WORD flag )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Das MiNT-XFS muû erst mit lookup() aus dem Dateinamen den Index
* und dann mit get_direntry_for_index() wieder den DIRENTRY
* berechnen, was natÅrlich Rechenzeit kostet.
*
* In MagiC wird direkt aus dem Namen der Verzeichniseintrag und
* daraus die Informationen ermittelt.
*
*******************************************************************/

static LONG cdecl	xfs_xattr( MX_DD *dd, const char *name, XATTR *xa,
							WORD mode, void **symlink )
{
	LONG ret;
	DIRENTRY de;
	ULONG index;
	LOGICAL_DEV *ldp;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol (drive)))
		return( ret );

	ldp = mydrives[drive];
	ret = lookup( (CDXFS_DD *) dd, name, &index, &de );
	if	(ret)
		return(ret);

	DKDirentry2Xattr (ldp, &de, drive, xa);

	return( E_OK );
}


/*******************************************************************
*
* Im Gegensatz zu MiNT fÅhrt der MagiX-Kernel diese Funktion
* nicht auf Fxattr() zurÅck. Wir machen das aber hier, weil Zeit
* beim Fattrib()-Aufruf keine groûe Rolle spielt.
*
*******************************************************************/

static LONG cdecl	xfs_attrib( MX_DD *dd, const char *name, WORD mode,
							WORD attrib, void **symlink )
{
	XATTR xa;
	long ret;

	if	(mode)
		return(EWRPRO);

	ret = xfs_xattr( dd, name, &xa, 0, symlink);
	if	(ret)
		return(ret);
	return(xa.st_attr & 0xff);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Dateien kînnen nicht ihren Eigner wechseln
*
*******************************************************************/

static LONG cdecl   xfs_chown( MX_DD *dd, const char *name, UWORD uid,
							UWORD gid, void **symlink )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Dateien kînnen nicht ihren Modus wechseln
*
*******************************************************************/

static LONG cdecl   xfs_chmod( MX_DD *dd, const char *name, UWORD mode, void **symlink )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Es kînnen keine Ordner erstellt werden.
*
*******************************************************************/

static LONG cdecl   xfs_dcreate( MX_DD *dd , const char *name, UWORD mode )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Es kînnen keine Ordner gelîscht werden.
*
*******************************************************************/

static LONG cdecl   xfs_ddelete( MX_DD *dd )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Berechnet aus einem DD einen Pfadnamen.
*
* Im Prinzip wie beim MiNT-XFS. Nur wird statt des fcookie
* ein DD verwendet.
*
*******************************************************************/

/* Gehe solange von fcookie dir bis zum fcookie relto zurÅck,
   bis relto erreicht ist. Dann gehe die Hierarchie zurÅck und
   baue den Pfadnamen zusammen */
   
static LONG getname (LOGICAL_DEV *ldp, ULONG relto,
				CDXFS_DD *current,
				char *pathname, int size, DIRENTRY *de )
{
	long ret;
	unsigned long adr, dirend;
	CDXFS_DD fret;


	fret.dd = current->dd;
	ret = lookup (current, "..", &(fret.index), de);
	if	(ret)
		return( ret );

	/* Wenn wir relto noch nicht erreicht haben... */
	if	(fret.index != relto)
		{
		ret = getname (ldp, relto, &fret, pathname, size, de);
		if	(ret)
			return ret;
		}
	
	/* Suche im Parent des aktuellen Verzeichnis nach dem
	aktuellen Verzeichnis und hÑnge seinen Namen hinten an
	den Pfad */
	
	adr = fret.index;
	ret = ldp->fs.get_direntry (ldp, &adr, 0, de);
	if	(ret)
		return( ret );

	adr = de->pri.start; dirend = de->pri.start + de->pri.length;

	while (E_OK == ldp->fs.get_direntry (ldp, &adr, dirend, de))
		{
		if	(de->pri.start == current->index)
			{
			if	(2 + strlen (pathname) + strlen (de->longname) >
						size)
				return( ERANGE );

			strcat (pathname, "\\");
			strcat (pathname, de->longname);

			return( E_OK );
			}
		}

	return( EFILNF );
}
	
static LONG cdecl   xfs_DD2name( MX_DD *dd, char *buf, WORD buflen )
{
	LOGICAL_DEV *ldp;
	DIRENTRY de;
	long ret;


	if	(E_OK != (ret = init_vol (dd->dd_dmd->d_drive)))
		return( ret );

	ldp = mydrives[dd->dd_dmd->d_drive];
	*buf = '\0';
	if	(((CDXFS_DD *) dd)->index == ldp->rootdir)
		return( E_OK );
	else
		return( getname (ldp, ldp->rootdir,
						(CDXFS_DD *) dd,
						buf, buflen, &de));
}


/*******************************************************************
*
* Das Verzeichnis <dd> wird fÅr den Dopendir/readdir- Mechanismus
* geîffnet.
* Da hier der Suchvorgang des Åbergeordneten Verzeichnisses schon
* durchgefÅhrt wurde, brauchen lediglich die relevanten Daten vom
* dd in den dhd kopiert zu werden. Weiterhin muû der Dateizeiger
* auf den ersten Verzeichniseintrag gesetzt werden und das
* tosflag eingetragen werden.
*
*******************************************************************/

static LONG cdecl xfs_dopendir( MX_DD *dd, WORD tosflag )
{
	CDXFS_DHD *dhd;
	LONG ret;


	if	(E_OK != (ret = init_vol (dd->dd_dmd->d_drive)))
		return ret;

	dhd = kernel_int_malloc();

	dhd->dhd.dhd_dmd = dd->dd_dmd;
	dhd->fp.offset = dhd->fp.start = ((CDXFS_DD *) dd)->start;	
	dhd->fp.size = ((CDXFS_DD *) dd)->length;
	dhd->fp.dev = dd->dd_dmd->d_drive;
	dhd->fp.dirflg = tosflag;

	return (LONG)&(dhd->dhd);
}


/*******************************************************************
*
* FÅr D(x)readdir().
* Ist im Prinzip wie beim MiNT-XFS. Es gibt jedoch keinen
* fcookie, alle Informationen liegen im DHD.
*
* Weiterhin ist Dxreaddir() hier gleich drin. Kein Wunder, daû
* MagiC hier um Klassen schneller ist als MiNT.
*
*******************************************************************/

static LONG cdecl   xfs_dreaddir( MX_DHD *dhd, WORD buflen, char *buf,
							XATTR *xattr, LONG *xr )
{
	LOGICAL_DEV *ldp;
	DIRENTRY de;
	long ret;
	int reclen = 12;
	CDXFS_DHD *mydhd = (CDXFS_DHD *) dhd;
	MYFILE *fp = &(mydhd->fp);
	WORD drive;


	drive = dhd->dhd_dmd->d_drive;
	if	(E_OK != (ret = init_vol(drive)))
		return( ret );

 	ldp = mydrives[drive];
 	ret = ldp->fs.get_direntry (ldp, &fp->offset, fp->start + fp->size, &de);
	if	(ret)
		return( ret );
	
	if	(!fp->dirflg)
		reclen += (int) sizeof (long);
	if	(reclen > buflen)
		return( ERANGE );

	mydhd->index = de.tosattr & FA_SUBDIR ? de.pri.start : de.iindex;

	/* Insert file index if needed */
	if	(!fp->dirflg)
		{
		*((long *)buf) = de.pri.start;
		buf += 4;
		}

	strcpy ((char *)buf, fp->dirflg == 1 ? de.truncname : de.longname);

	/* DIRENTRY merken, der getxattr-Aufruf kommt bestimmt */
/*
	son' Hackzeugs brauchen wir in MagiX nicht...

	ldp->lastde.inuse = 1;
	ldp->lastde.index = mydhd->index;
	ldp->lastde.de = de;
*/
	if	(xattr)
		{
		DKDirentry2Xattr (ldp, &de, drive, xattr);
		*xr = E_OK;
		}

	return(E_OK);
}


/*******************************************************************
*
* FÅr Drewinddir().
* Im Prinzip wie beim MiNT-XFS.
*
*******************************************************************/

static LONG cdecl   xfs_drewinddir( MX_DHD *dhd )
{
	((CDXFS_DHD *) dhd)->index = 0;
	return(E_OK);
}


/*******************************************************************
*
* FÅr Dclosedir().
* Die Struktur fÅr den DHD wird einfach freigegeben.
*
*******************************************************************/

static LONG cdecl   xfs_dclosedir( MX_DHD *dhd )
{
	kernel_int_mfree( dhd );
	return(E_OK);
}


/*******************************************************************
*
* FÅr Dpathconf().
* Im Prinzip wie beim MiNT-XFS.
*
*******************************************************************/

static LONG cdecl   xfs_dpathconf( MX_DD *dd, WORD which )
{
	LOGICAL_DEV *ldp;
	LONG ret;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol (drive)))
		return( ret );
	ldp = mydrives[drive];

	return(ldp->fs.pathconf (ldp, which));
}


/*******************************************************************
*
* FÅr Dfree().
* Im Prinzip wie beim MiNT-XFS.
*
*******************************************************************/

static LONG cdecl   xfs_dfree( MX_DD *dd, DISKINFO *buf )
{
	LOGICAL_DEV *ldp;
	LONG ret;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol (drive)))
		return( ret );

	ldp = mydrives[drive];

	buf->b_free = 0;
	buf->b_total = ldp->totalsize;
	buf->b_secsiz = ldp->blocksize;
	buf->b_clsiz = 1;

	return(E_OK);
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Es kînnen keine Medien umbenannt werden.
*
*******************************************************************/

static LONG cdecl   xfs_wlabel( MX_DD *dd, const char *name )
{
	LOGICAL_DEV *ldp;
	LONG ret;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol (drive)))
		return( ret );

	ldp = mydrives[drive];
	return( ldp->fs.label (ldp, (char *)name, (int)strlen(name), 1));
}


/*******************************************************************
*
* Wie bei MiNT
*
*******************************************************************/

static LONG cdecl   xfs_rlabel( MX_DD *dd, const char *name, char *buf,
     						WORD buflen )
{
	LOGICAL_DEV *ldp;
	LONG ret;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol (drive)))
		return( ret );

	ldp = mydrives[drive];
	return( ldp->fs.label (ldp, buf, buflen, 0));
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Es kînnen keine Symlinks erstellt werden.
*
*******************************************************************/

static LONG cdecl   xfs_symlink( MX_DD *dd, const char *name, const char *to)
{
	return(EWRPRO);
}


/*******************************************************************
*
* Das CDROM hat keine Symlinks.
*
*******************************************************************/

static LONG cdecl   xfs_readlink( MX_DD *dd, const char *name, char *buf,
     						WORD buflen )
{
	return(EINVFN);
}


/*******************************************************************
*
* FÅr Dcntl(). Auch hier im Gegensatz zu MiNT kein Umweg Åber
* fcookies, sondern direkt der Zugriff Åber _eine_ XFS-Funktion.
*
*******************************************************************/

static LONG cdecl   xfs_dcntl( MX_DD *dd, const char *name, WORD cmd,
     						LONG arg, void **symlink )
{
	LOGICAL_DEV *ldp;
	long ret;
	ULONG index;
	DIRENTRY de;
	WORD drive;


	drive = dd->dd_dmd->d_drive;
	if	(E_OK != (ret = init_vol( drive )))
		return( ret );

	ldp = mydrives[drive];
	if	((cmd >> 8) == 'C')
		return Metaioctl (ldp->metadevice, METADOS_IOCTL_MAGIC, cmd, (void *)arg);

	ret = lookup ((CDXFS_DD *) dd, name, &index, &de);
	if	(ret)
		return( ret );

	switch (cmd)
	{
		case FMACGETTYCR:
			{
				MacFinderInfo *M = (MacFinderInfo *) arg;
				
				memset (M, 0, sizeof (MacFinderInfo));
				M->fdType = de.type;
				M->fdCreator = de.creator;				
				return de.type != 0 && de.creator != 0 ? E_OK : EINVFN;
			}
		
		case FMACSETTYCR:
			return EWRPRO;
	}

	return(EINVFN);
}



/***************** GERéTETREIBER ***************/


/*******************************************************************
*
* Wir bekommen hier die Gelegenheit, evtl. Schreibpuffer o.Ñ.
* zurÅckzuschreiben, bevor die Datei geschlossen wird.
* Auf dem CD-ROM brauchen wir nur den Deskriptor freizugeben.
*
*******************************************************************/

static LONG cdecl	dev_close( MX_FD *fd )
{
	if	(fd->fd_refcnt)
		fd->fd_refcnt--;
	if	(!fd->fd_refcnt)
		kernel_int_mfree( fd );
	return(E_OK);
}


/*******************************************************************
*
* éhnlich wie bei MiNT. Jedoch haben wir uns schon beim ôffnen
* der Datei index,start,length gemerkt und kînnen jeden Lesezugriff
* daher wesentlich schneller als ein MiNT-XFS durchfÅhren.
*
*******************************************************************/

static LONG cdecl	dev_read( MX_FD *f, LONG count, void *buf )
{
	LOGICAL_DEV *ldp = mydrives[f->fd_dmd->d_drive];
	CDXFS_FD *fd = (CDXFS_FD *) f;
	long start, datalen;
	long ret;


	if	(!fd->ass)	/* data fork */
		{
		start = fd->pri_start;
		datalen = fd->pri_length;
		}
	else	{			/* resource fork */
		start = fd->ass_start;
		datalen = fd->ass_length;
		}

	if	(fd->pos + count > datalen)
		count = datalen - fd->pos;

	ret = ldp->fs.readfile (ldp, start, fd->pos, datalen, fd->index,
			count, buf);
	if	(ret)
		return( ret );
	
	fd->pos += count;
	return( count );
}


/*******************************************************************
*
* Dies ist ein CD-ROM
*
* Es wird nicht geschrieben.
*
*******************************************************************/

static LONG cdecl	dev_write( MX_FD *f, LONG count, void *buf )
{
	return(EWRPRO);
}


/*******************************************************************
*
* Hier ist sowohl Polling als auch Interruptbetrieb mîglich.
*
*******************************************************************/

static LONG cdecl	dev_stat( MX_FD *f, MAGX_UNSEL *unselect,
							WORD rwflag, LONG apcode )
{
	if	(apcode)			/* komplizierter Fall */
		{
		unselect->unsel.status = 1;
		return(1);		/* GerÑt bereit */
		}
	else	{				/* polling */
		if	(unselect)
			unselect->unsel.status = 1;
		return(1);
		}
}


/*******************************************************************
*
* éhnlich wie bei MiNT. Nur sparen wir uns get_direntry() und damit
* viel Rechenzeit.
*
*******************************************************************/

static LONG cdecl	dev_seek( MX_FD *f, LONG offset, WORD whence )
{
	CDXFS_FD *fd = (CDXFS_FD *) f;
	long datalen;
	long newoff;


	datalen = fd->ass ? fd->ass_length : fd->pri_length;

	switch (whence)
	{
		case 0:
			newoff = offset;
			break;
					
		case 1:
			newoff = fd->pos + offset;
			break;
			
		case 2:
			newoff = datalen + offset;
			break;

		default:
			return EINVFN;
	}
	
	if (newoff < 0 || newoff > datalen) return ERANGE;
	
	return fd->pos = newoff;
}


/*******************************************************************
*
* Viel einfacher als bei MiNT, weil wir uns schon beim ôffnen
* die Daten gemerkt haben.
*
*******************************************************************/

static LONG cdecl	dev_datime( MX_FD *f, WORD d[2], WORD set)
{
	CDXFS_FD *fd = (CDXFS_FD *) f;

	if	(set)
		return( EWRPRO );

	*d++ = fd->mtime;
	*d = fd->mdate;
	return(E_OK);
}


/*******************************************************************
*
* Auch hier einfacher als bei MiNT, weil wir alle Informationen
* schon gepuffert haben.
*
*******************************************************************/

static LONG cdecl	dev_ioctl( MX_FD *f, WORD cmd, void *buf )
{
	DIRENTRY de;
	CDXFS_FD *fd = (CDXFS_FD *) f;
	LOGICAL_DEV *ldp;
	ULONG adr;
	long ret;


	switch (cmd)
	{
		case FSTAT:
			{
				ldp = mydrives[f->fd_dmd->d_drive];
				adr = fd->index;
				ret = ldp->fs.get_direntry (ldp, &adr, 0, &de);
				if	(ret != E_OK)
					return( ret );
				DKDirentry2Xattr (ldp, &de,
							f->fd_dmd->d_drive, buf);
				return( E_OK );
			}

		case FMACGETTYCR:
			{
				MacFinderInfo *M = (MacFinderInfo *) buf;
				
				memset (M, 0, sizeof (MacFinderInfo));
				M->fdType = fd->type;
				M->fdCreator = fd->creator;				
				return fd->type != 0 && fd->creator != 0 ? E_OK : EINVFN;
			}
		
		case FMACSETTYCR:
			return EWRPRO;

		case FMACOPENRES:
			{
				if (fd->ass_start == 0) return EFILNF;
	
				fd->ass = 1;
				fd->pos = 0;
	
				return E_OK;
			}
	}
	
	return EINVFN;
}


/*******************************************************************
*
* Standardprozedur, um auf Nicht-Terminals dev_getc() auf
* dev_read() zurÅckzufÅhren.
*
* Geschickter wÑre es hier, wenn der Kernel selbstÑndig diese
* Prozedur ausfÅhren kînnte, falls das XFS kein dev_getc() hat.
*
*******************************************************************/

static LONG cdecl	dev_getc( MX_FD *f, WORD mode )
{
	unsigned char c;
	LONG ret;

	ret = dev_read(f, 1L, (void *) &c);
	if	(ret < 0L)
		return(ret);			/* Fehler	*/
	if	(!ret)
		return(0x0000ff1a);		/* EOF */
	return(c & 0x000000ff);
}


/*******************************************************************
*
* Standardprozedur, um auf Nicht-Terminals dev_getline() auf
* dev_read() zurÅckzufÅhren.
*
*******************************************************************/

static LONG cdecl	dev_getline( MX_FD *f, char *buf, WORD mode, LONG size )
{
	unsigned char c;
	LONG gelesen,ret;

	for	(gelesen = 0L; gelesen < size;)
		{
		ret = dev_read(f, 1L, (void *) &c);
		if	(ret < 0L)
			return(ret);		/* Fehler */
		if	(ret == 0L)
			break;			/* EOF	*/
		if	(c == 0x0d)
			continue;
		if	(c == 0x0a)
			break;
		gelesen++;
		*buf++ = c;
		}
	return(gelesen);
}


/*******************************************************************
*
* Standardprozedur, um auf Nicht-Terminals dev_putc() auf
* dev_write() zurÅckzufÅhren.
*
*******************************************************************/

static LONG cdecl	dev_putc( MX_FD *f, WORD mode, LONG val )
{
	unsigned char c;

	c = (unsigned char) val;
	return(dev_write(f, 1L, (void *) &c));
}


/***************** BLOCK- GERéTETREIBER ***************/


/*******************************************************************
*
*******************************************************************/

static LONG cdecl	blkdev_open( MX_DOSFD *fd )
{
	int i;
	
	for (i = 0; i < 32; i++)
	{
		if (mydrives[i] && &mydrives[i]->ddev == fd->fd_ddev)
		{
			fd->fd_user1 = i;
			return E_OK;
		}
	}
	return EINTRN;
}


/*******************************************************************
*
*******************************************************************/

static LONG cdecl	blkdev_close( MX_DOSFD *fd )
{
	return( E_OK );
}


/*******************************************************************
*
*
*******************************************************************/

static LONG cdecl	blkdev_read( MX_DOSFD *f, LONG count, void *buf )
{
	LOGICAL_DEV *ldp = mydrives[(int)f->fd_user1];
	long ret;

	ret = DCRead (ldp, f->fd_fpos, count, buf);
	
	if	(ret != E_OK)
		return( ret );
	
	f->fd_fpos += count;
	return( count );
}


/*******************************************************************
*
*
*******************************************************************/

static LONG cdecl	blkdev_write( MX_DOSFD *f, LONG count, void *buf )
{
	return( EWRPRO );
}


/*******************************************************************
*
* Hier ist sowohl Polling als auch Interruptbetrieb mîglich.
*
*******************************************************************/

static LONG cdecl	blkdev_stat( MX_DOSFD *f, LONG *unselect,
							WORD rwflag, LONG apcode )
{
	if	(apcode)			/* komplizierter Fall */
		{
		*unselect = 1;
		return(1);		/* GerÑt bereit */
		}
	else	{				/* polling */
		if	(unselect)
			*unselect = 1;
		return(1);
		}
}


/*******************************************************************
*
*
*******************************************************************/

static LONG cdecl	blkdev_seek( MX_DOSFD *f, LONG offset, WORD whence )
{
	long newoff;

	switch (whence)
	{
		case 0:
		case 2:
			newoff = offset;
			break;
					
		case 1:
			newoff = f->fd_fpos + offset;
			break;
			
		default:
			return EINVFN;
	}
	
	return( f->fd_fpos = newoff);
}


/*******************************************************************
*
* Auch hier einfacher als bei MiNT, weil wir alle Informationen
* schon gepuffert haben.
*
*******************************************************************/

static LONG cdecl	blkdev_ioctl( MX_DOSFD *f, WORD cmd, void *buf )
{
	LOGICAL_DEV *ldp = mydrives[(int)f->fd_user1];
	
	return Metaioctl (ldp->metadevice, METADOS_IOCTL_MAGIC, cmd, buf);
}


/*******************************************************************
*
* Viel einfacher als bei MiNT, weil wir uns schon beim ôffnen
* die Daten gemerkt haben.
*
*******************************************************************/

static LONG cdecl	blkdev_delete( MX_DOSFD *f, MX_DOSDIR *dir)
{
	return( EWRPRO );
}
