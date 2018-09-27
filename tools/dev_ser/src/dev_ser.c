/********************************************************************
*
* MagiC Device Driver Development Kit
* ===================================
*
* Beispieltreiber fr Drucker-Hintergrundbetrieb
*
*
* Dieses Programm realisiert einen interruptgesteuerten
* Ger„tetreiber.
* Einige der Ger„tefunktionen sind in Assembler ausgefhrt,
* was einen schnellen und kompakten Code erm”glicht.
*
*
* (C) Andreas Kromke, 1994
*
********************************************************************/


#include <string.h>
#include <tos.h>

typedef void APPL;
typedef void PD;

#include "mgx_xfs.h"

typedef struct _mx_ddev
{
     LONG (*ddev_open)   (struct _mx_dosfd *f);
     LONG (*ddev_close)(struct _mx_dosfd *f);
     LONG (*ddev_read)(struct _mx_dosfd *f, void *buf,  long len);
     LONG (*ddev_write)(struct _mx_dosfd *f, void *buf,  long len);
     LONG (*ddev_stat)(struct _mx_dosfd *f, int  rwflag, void *unsel, void *appl);
     LONG (*ddev_seek)(struct _mx_dosfd *f, long where, int mode);
     LONG (*ddev_datime)(struct _mx_dosfd *f, int  *buf,  int rwflag);
     LONG (*ddev_ioctl)(struct _mx_dosfd *f, int  cmd, void *buf);
     LONG (*ddev_delete)(struct _mx_dosfd *parent, struct _mx_dosdir *dir);
     LONG (*ddev_getc)();
     LONG (*ddev_getline)();
     LONG (*ddev_putc)();
} MX_DDEV;

typedef struct _mx_dosfd {
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
} MX_DOSFD;

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


typedef struct _mx_dosdir {
     char      dir_name[11];
     char      dir_attr;
     WORD      dir_usr1;
     ULONG     dir_usr2;
     ULONG     dir_usr3;
     WORD      dir_time;
     WORD      dir_date;
     WORD      dir_stcl;
     ULONG     dir_flen;
} MX_DOSDIR;

typedef struct _mx_dfs {
     char      dfs_name[8];
     struct _mx_dfs   *dfs_next;
     long      (*dfs_init)();
     long      (*dfs_sync)();
     long      (*dfs_drv_open)();
     long      (*dfs_drv_close)();
     long      (*dfs_dfree)();
     long      (*dfs_sfirst)();
     long      (*dfs_snext)();
     long      (*dfs_ext_fd)();
     long      (*dfs_fcreate)();
     long      (*dfs_fxattr)();
     long      (*dfs_dir2index)();
     long      (*dfs_readlink)();
     long      (*dfs_dir2FD)();
     long      (*dfs_fdelete)();
     long      (*dfs_pathconf)();
} MX_DFS;

/* untersttzte Dcntl- Modi */
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00

/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;

struct MgMxCookieData{	long	mgmx_magic;		/* ist "MgMx" */	long	mgmx_version;		/* Versionsnummer */	long	mgmx_len;			/* Strukturl„nge */	long	mgmx_xcmd;		/* PPC-Bibliotheken laden und verwalten */	long mgmx_xcmd_exec;	/* PPC-Aufruf aus PPC-Bibliothek */
	void *mgmx_sysx;};

/******************************************************************
*
* ger„tespezifische Variablen
*
******************************************************************/

void *ser_dev_owner = NULL;
MX_KERNEL *kernel;
void *pSysX;



/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}


#pragma warn -par

/******************************************************************
*
* Ger„t ”ffnen:
*  Ich merke mir den aktuellen Proze, damit das Ger„t nicht
*  mehrmals ge”ffnet wird.
*
******************************************************************/

extern long _ser_dev_open(void);

long ser_dev_open(MX_DOSFD *f)
{
	long ret;

     if   (ser_dev_owner)
          return(EACCDN);          /* schon ge”ffnet */

	ret = _ser_dev_open();
	if	(ret)
		return(ret);

	ser_dev_owner = kernel->act_pd;
	return(E_OK);
}


/******************************************************************
*
* Ger„t schlieen:
*  Ich gebe das Ger„t frei.
*
******************************************************************/

extern long _ser_dev_close(void);

long ser_dev_close(MX_DOSFD *f)
{
	long ret;

	ret = _ser_dev_close();
	if	(ret)
		return(ret);

	ser_dev_owner = NULL;
     return(E_OK);
}


/******************************************************************
*
* lesen:
*
******************************************************************/

extern long ser_dev_read(MX_DOSFD *f, void *buf, long len);


/******************************************************************
*
* schreiben:
*  -> Assemblermodul
*
******************************************************************/

extern long ser_dev_write(MX_DOSFD *f, void *buf, long len);


/******************************************************************
*
* Status:
*  -> Assemblermodul
*
******************************************************************/

extern long ser_dev_stat(MX_DOSFD *f, int rwflag, void *unsel, void *appl);


/******************************************************************
*
* Dateizeiger positionieren
*
******************************************************************/

long ser_dev_lseek(MX_DOSFD *f, long where, int mode)
{
     return(EACCDN);
}


/******************************************************************
*
* Uhrzeit/Datum der ge”ffneten Datei
*
******************************************************************/

/*

erledigt das DOS

long lpt_dev_datime (MX_DOSFD *f, int  *buf,  int rwflag)
{
}

*/

/******************************************************************
*
* Ger„tespezifische Befehle
*  -> Assemblermodul
*
******************************************************************/

extern long ser_dev_ioctl(MX_DOSFD *f, int  cmd, void *buf);

/******************************************************************
*
* Ger„t wird gel”scht:
*  Ger„tetreiber aufwecken und damit beenden.
*
******************************************************************/

long ser_dev_delete ( MX_DOSFD *parent, MX_DOSDIR *dir )
{
     kernel->Pfree(_BasPag);
     return(E_OK);
}

#pragma warn +par

MX_DDEV drvr =
{
	ser_dev_open,
	ser_dev_close,
	ser_dev_read,
	ser_dev_write,
	ser_dev_stat,
	ser_dev_lseek,
	NULL,		/* datime erledigt XFS_DOS */
	ser_dev_ioctl,
	ser_dev_delete,
	NULL,		/* kein getc */
	NULL,		/* kein getline */
	NULL			/* kein putc */
};

int main()
{
	long errcode;
	COOKIE *pMMXCookie;
	struct MgMxCookieData *pMMXCookieData;

	/* Cookie ermitteln */

	pMMXCookie = getcookie('MgMx');
	if	(!pMMXCookie)
	{
		Cconws("MgMx-Cookie nicht gefunden");
		return(-1);
	}

	pMMXCookieData = (struct MgMxCookieData *) pMMXCookie->value;
	if	(pMMXCookieData->mgmx_magic != 'MgMx')
		return(-2);

	pSysX = pMMXCookieData->mgmx_sysx;

	errcode = Dcntl(DEV_M_INSTALL, "u:\\dev\\serial", (long) &drvr);
	if   (errcode < 0L)
	{
		Cconws("Anmelden verweigert");
		return((int) errcode);
	}

	kernel = (MX_KERNEL *) Dcntl(KER_GETINFO, NULL, 0L);
	Ptermres(-1L, 0);        /* allen Speicher behalten */
	return(0);
}
