/*********************************************************************
*
* Dieses Modul enth„lt die Bearbeitung aller Dateioperationen, also
* Info Anzeigen und Umbenennen.
*
*********************************************************************/

#include <tos.h>
#include <toserror.h>
#include "k.h"
#include <string.h>
#include <stdlib.h>
#include <mint/dcntl.h>
#include <sys/stat.h>

#define MAX_PATHLEN		256
#define MAX_PATHDEPTH	12
#define MAX_NAMELEN		64


/*********************************************************************
*
* Wirft ein Medium aus
*
*********************************************************************/

long eject_medium(char *path)
{
	long ret;

	ret = Dcntl(CDROMEJECT, path, 0L);
	if	(!ret)
		auto_close_windows();
	return(err_alert(ret));
}


/*********************************************************************
*
* Ermittelt das tats„chliche Laufwerk eines Pfads
*
*********************************************************************/

long get_real_drive(char *path)
{
	int drv;
	long ret;
	char *p;
	char buf[128];


	p = get_name(path);
	if	(*p)				/* Dateiname muž abgespalten werden */
		{
		drv = (int) (p-path);
		memcpy(buf, path, drv);
		buf[drv] = EOS;
		path = buf;
		}

	drv = drive_from_letter(path[0]);
	Dsetdrv(drv);
	ret = Dsetpath(path);
	if	(ret)
		return(ret);		/* Fehler bei Dsetpath */

	ret = Dgetdrv();
	if	(ret >= 0)
		drv = (int) ret;

	if	(drv == 'U'-'A')
		{

		ret = Dgetpath(buf, 0);	/* Pfad von U: */
		if	(!ret &&
			 buf[0] == '\\' &&
			 drive_from_letter(buf[1]) >= 0 &&
			 (buf[2] == '\\' || !buf[2]))
			drv = drive_from_letter(buf[1]);
		}

	return((int) drv);
}


/*********************************************************************
*
* Fragt, ob abgebrochen werden soll.
*
*********************************************************************/

static int qbreak( void )
{
	if	((Kbshift(-1) & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT))
		{
		if	(1 == Rform_alert(1, ALRT_STOP_PROC))
			return(TRUE);
		}
	return(FALSE);
}


/*********************************************************************
*
* Setzt das Dirty- Flag von Laufwerk <drv> bzw., wenn <path>
* angegeben wurde, das von path[]
*
*********************************************************************/

void set_dirty(long err, char *path, int drv, char val)
{
	if	(err != EWRPRO && err != EDRIVE && err != EFILNF &&
	 	 err != EPTHNF && err != EACCDN)
	 	{

	 	if	(drv < 0)
	 		{
	 		err = get_real_drive(path);
	 		if	(err < 0L)
	 			return;		/* Fehler bei Dsetpath */
	 		drv = (int) err;
	 		}

	 	if	(dirty_drives[drv] == 1)
	 		return;		/* schon "dirty" */
		dirty_drives[drv] = val;
		}
}


/*********************************************************************
*
* Durchl„uft einen Pfad und fhrt bei jeder gefundenen Datei
* vorher ein Programm <before>, hinterher <after> aus.
* Sind <before> und <after> == NULL, werden nur Informationen gesammelt.
* gibt ggf. DOS- Fehlercode zurck.
*
*********************************************************************/

static long _nbytes,_hbytes;
static int  _nfiles,_hfiles,_folders;
static int  depth;
static char *_path;


static long _walk_path( void )
{
	long	dir;
	int	dirlen;			/* Anzahl Eintr„ge in diesem Verzeichnis */
	long errcode;
	char *endp;
	char name[MAX_NAMELEN+1+4];
	XATTR xa;
	long err_xr;


	errcode = strlen(_path);
	endp = _path + errcode;
	depth++;
	if	(depth > MAX_PATHDEPTH || errcode > MAX_PATHLEN-MAX_NAMELEN-1)
		{
		err_alert(EPTHOV);
		depth--;
		return(E_OK);
		}
	if	(qbreak())
		return(EBREAK);
	dirlen = 0;

	errcode = Dopendir(_path, 0);
	if	(errcode < E_OK)
		goto err2;

	dir = errcode;
	do	{
		errcode = Dxreaddir(MAX_NAMELEN+1+4, dir,
						name,
						&xa, &err_xr);
		if	(qbreak())
			{
			ebreak:
			Dclosedir(dir);
			return(EBREAK);
			}
		if	(errcode)
			break;
		if	(err_xr)
			{
			errcode = err_xr;
			break;
			}

		if	(name[4] == '.')
			{
			if	(name[5] == '.' || name[5] == EOS)
				goto next;
			}

		if	((xa.st_mode & S_IFMT) == S_IFDIR)
			{
			_folders++;
			strcpy(endp, name+4);
			strcat(endp, "\\");
			errcode = _walk_path();	/* REKURSION */
			*endp = EOS;
			if	(errcode)
				{
				Dclosedir(dir);
				return(errcode);
				}
			}
		else {
			if	(xa.st_attr & (FA_HIDDEN | FA_SYSTEM))
				{
				_hfiles++;
				_hbytes += xa.st_size;
				}
			else {
				_nfiles++;
				_nbytes += xa.st_size;
				}
			}

		next:
		dirlen++;
		if	(qbreak())
			goto ebreak;
		}
	while(!errcode);

	Dclosedir(dir);
	depth--;
	if	(errcode == EFILNF || errcode == ENMFIL)
		errcode = E_OK;
	err2:
	return(err_alert(errcode));
}

long walk_path(char *path, long *nbytes,
			long *hbytes, int *folders,
			int *nfiles, int *hfiles)
{
	long errcode;


	_nbytes = _hbytes = _nfiles = _hfiles = _folders = depth = 0;
	_path = path;
	errcode = _walk_path();
	*nbytes   = _nbytes;		/* Bytes in normalen Dateien */
	*hbytes   = _hbytes;		/* Bytes in versteckten Dateien */
	*folders  = _folders;		/* Anzahl Ordner */
	*nfiles   = _nfiles;		/* Anzahl normale Dateien */
	*hfiles   = _hfiles;		/* Anzahl versteckte Dateien */
	return(errcode);
}
