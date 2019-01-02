#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <tos.h>
#include "cdfs.h"
#include "libcdfs.h"
#include "metados.h"
#include "mint/cdromio.h"


/* set to # of open files supported by the kernel if not unlimited */
long DKMaxOpenFiles = 0x7fffffffL;


static long get_root(LOGICAL_DEV *ldp, long (*p_get_root)(LOGICAL_DEV *ldp, unsigned long lba, int))
{
	struct cdrom_tocentry tocentry;
	unsigned long root_offset;
	struct cdrom_tochdr tochdr;
	long err;
	int trk;
	int count;
	
	root_offset = 0;
	count = 1;
	err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADOFFSET, &root_offset);
	if (err == 0)
	{
		return p_get_root(ldp, root_offset, 8);
	}
	err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCHDR, &tochdr);
	if (err == 0)
	{
		for (;;)
		{
			for (trk = tochdr.cdth_trk1; trk >= tochdr.cdth_trk0; trk--)
			{
				tocentry.cdte_track = trk;
				tocentry.cdte_format = CDROM_LBA;
				err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCENTRY, &tocentry);
				if (err == 0)
				{
					/* is it a data track? */
					if (tocentry.cdte_ctrl & CDROM_DATA_TRACK)
					{
						if (trk == 1 && 16 > tocentry.cdte_addr.lba)
							tocentry.cdte_addr.lba = 0;
						err = p_get_root(ldp, tocentry.cdte_addr.lba, count);
						if (err == 0)
							return err;
					}
				}
			}
			if (count != 1)
				break;
			count = 8;
		}
	}
	return p_get_root(ldp, 0, 8);
}


/* initialize the device */
int DKInitVolume(LOGICAL_DEV *ldp)
{
	long status;
	int flag;
	const char *sccsid;
	
	sccsid = "@(#)libcdfs.lib, Copyright (c) Julian F. Reschke, May 30 1997";
	flag = 0;
	
	if (get_hz() > ldp->mediatime)
	{
		status = Metastatus(ldp->metadevice, NULL);
		ldp->mediatime = get_hz() + MEDIADELAY;
		/* error or timeout? */
		if (status & 0xffff0008l)
		{
			memset(&ldp->fs, 0, sizeof(ldp->fs));
			flag |= 2;
			DCClear(ldp);
		}
	}
	(void)sccsid;

	if ((ldp->fs.get_root == isofs.get_root && ldp->fspreference == FSPREFERENCE_ISO) ||
		(ldp->fs.get_root == hfs.get_root && ldp->fspreference == FSPREFERENCE_HFS) ||
		(ldp->fs.get_root == tocfs.get_root && ldp->fspreference == FSPREFERENCE_TOC))
	{
		if (ldp->fs.get_root)
			return 1;
	}
	ldp->mount_date = Tgetdate();
	ldp->mount_time = Tgettime();
	ldp->lastde.inuse = ldp->lastde.name[0] = 0; /* FIXME */
	
	if (ldp->fspreference == FSPREFERENCE_HFS && get_root(ldp, hfs.get_root) == 0)
	{
		ldp->fs = hfs;
		return flag | 1;
	}
	
	if (ldp->fspreference == FSPREFERENCE_TOC || ldp->fspreference == FSPREFERENCE_HFS)
	{
		if (get_root(ldp, tocfs.get_root) == 0)
		{
			ldp->fs = tocfs;
			if (ldp->rootdirsize != 0)
				ldp->fspreference = FSPREFERENCE_TOC;
			return flag | 1;
		}
	}

	if (get_root(ldp, isofs.get_root) == 0)
	{
		ldp->fs = isofs;
		ldp->fspreference = FSPREFERENCE_ISO;
		return flag | 1;
	}

	if (get_root(ldp, hfs.get_root) == 0)
	{
		ldp->fs = hfs;
		ldp->fspreference = FSPREFERENCE_HFS;
		return flag | 1;
	}
	
	if (get_root(ldp, tocfs.get_root) == 0)
	{
		ldp->fs = tocfs;
		if (ldp->rootdirsize != 0)
			ldp->fspreference = FSPREFERENCE_TOC;
		return flag | 1;
	}
	
	return flag;
}


/* convert DIRENTRY structure to XATTR structure */
void DKDirentry2Xattr(LOGICAL_DEV *ldp, DIRENTRY *de, int drive, XATTR *xap)
{
	memset(xap, 0, sizeof(*xap));
	xap->st_attr = de->tosattr;
	xap->st_mode = de->mode;
	xap->st_ino = de->pri.start;
	xap->st_dev = drive;
	xap->st_rdev = drive;
	xap->st_uid = de->uid;
	xap->st_gid = de->gid;
	xap->st_nlink = de->nlink;
	xap->st_size = de->pri.length;
	xap->st_blksize = ldp->blocksize;
	xap->st_blocks = (de->pri.length + ldp->blocksize - 1) / ldp->blocksize;
	xap->st_blocks += (de->ass.length + ldp->blocksize - 1) / ldp->blocksize;
	xap->st_atim.u.d.time = de->atime;
	xap->st_ctim.u.d.time = de->ctime;
	xap->st_mtim.u.d.time = de->mtime;
	xap->st_atim.u.d.date = de->adate;
	xap->st_ctim.u.d.date = de->cdate;
	xap->st_mtim.u.d.date = de->mdate;
}


/* convert filename to 8+3 format */
void DKTosify(char *dst, const char *src)
{
	const char *dot;
	size_t len;
	int i;
	
	if (strcmp(src, ".") == 0 || strcmp(src, "..") == 0)
	{
		strcpy(dst, src);
		return;
	}
	dot = strrchr(src, '.');
	if (dot != NULL && strlen(dot) > 4)
		dot = NULL;
	if (dot == src)
		dot = NULL;
	len = strlen(src);
	if (dot != NULL)
		len = dot - src;
	if (dot != NULL)
		++dot;
	*dst = '\0'; /* FIXME */
	for (i = 0; i < 8 && i < (int)len; i++)
	{
		*dst = src[i];
		if (*dst == '.' || *dst <= ' ')
			*dst = '_';
		*dst = toupper(*dst);
		dst++;
	}
	if (dot == NULL)
		dot = &src[i];
	if (strlen(dot) != 0) /* FIXME */
		*dst++ = '.';
	for (i = 0; i < 3 && i < strlen(dot); i++)
	{
		*dst = dot[i];
		if (*dst == '.' || *dst <= ' ')
			*dst = '_';
		*dst = toupper(*dst);
		dst++;
	}
	*dst = '\0';
}


/* flip filesystem type preference */
void DKFlipPreferred(LOGICAL_DEV *ldp)
{
	++ldp->fspreference;
	ldp->fspreference = ldp->fspreference % 3;
}
