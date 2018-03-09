/*
	@(#)hs-iso/dosmain.c
	
	Julian F. Reschke, 1. Mai 1997
*/

#include <assert.h>
#include <ctype.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <mint/mintbind.h>
#include <tos/sysvars.h>

#include <dosix/errno.h>
#include <dosix/sys/macfs.h>
#include <dosix/sys/metados.h>

#include "cdromio.h"

#include "cdda.h"
#include "cdfs.h"

typedef struct          /* used by Fsetdta, Fgetdta */
{
	unsigned long	ds_dirindex;
    unsigned long	ds_dirend;
	char			ds_attrib;
    char            ds_name[12];
    unsigned char   d_attrib;
    unsigned int    d_time;
    unsigned int    d_date;
    unsigned long   d_length;
    char            d_fname[14];
} myDTA;

#if sizeof(myDTA) != sizeof(DTA)
#error
#endif

extern char startoftext;

char DriverName[] = "CD-Tool ISO9660 FS";

/* Hier steht, wie grož der Cache angelegt werden soll. Nachdem
   er einmal angelegt worden *ist*, wird diese Variable gel”scht
   (weil der Cache nun gemeinsam von allen Treibern benutzt wird) */

int cacheblocks = DEFAULTCACHESIZE;

char *
sccsid (void)
{
	return "@(#)hs-iso.dos "VERSIONSTRING", Copyright (c) Julian F. Reschke, "__DATE__;
}

/* Diverse Utility-Funktionen */

static int
Bconws (char *str)
{
	int cnt = 0;
	
	while (*str)
	{
		cnt++;
		
		if (*str == '\n') {
			Bconout (2, '\r');
			cnt++;
		}
		
		Bconout (2, *str++);
	}
	
	return cnt;
}

/* Lowlevel-FS-Funktionen */


static char *
tune_pn (char *pathname, int *drive)
{
	if (drive) *drive = toupper(pathname[0]) - 'A';
	
	pathname += 2; /* skip : */
	if (pathname[0] == '\\') pathname += 1;

	return pathname;
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


static long
_get_direntry_by_name (LOGICAL_DEV *ldp, char *path, DIRENTRY *dp,
	unsigned long startindex, unsigned long dirend,
	unsigned long *parentstart, int *fn_index)
{
	long ret;
	char *was_path = path;
	
	*parentstart = startindex;
		
	while (1)
	{
		DIRENTRY de;
		size_t tlen, len;

		ret = ldp->fs.get_direntry (ldp, &startindex, dirend, &de);
		if (ret == ENMFIL) goto error;
		else if (ret) return ret;

		tlen = strlen (de.truncname);
		len = strlen (de.longname);
		*fn_index = (int)((long)path - (long)was_path);

		/* Stimmt der Name soweit berein? */
		
#if 0
		if	((0 == ldp->fs.pathconf (ldp, 6) && !strnicmp (path, de.longname, len))
			|| !strncmp (path, de.longname, len))
#else
		if	((0 == ldp->fs.pathconf (ldp, 6) && !strncmp (path, de.longname, len))
			|| !strnicmp (path, de.longname, len))
#endif
		{
			/* Wenn das schon das letzte Zeichen war... */
			if (path[len] == '\0')
			{
				*dp = de;
				return E_OK;
			}

			if (path[len] == '\\' && (de.tosattr & FA_SUBDIR))
			{
				path += len + 1;
				if (! *path)	/* wenn \ das letzte Zeichen war */
				{
					*dp = de;
					return E_OK;
				}
				*parentstart = startindex = de.pri.start;
				dirend = de.pri.length + de.pri.start;
			}
		}
		else if (!strnicmp (path, de.truncname, tlen))
		{
			/* Wenn das schon das letzte Zeichen war... */
			if (path[tlen] == '\0')
			{
				*dp = de;
				return E_OK;
			}
			
			if (path[tlen] == '\\' && (de.tosattr & FA_SUBDIR))
			{
				path += tlen + 1;
				if (! *path)
				{
					*dp = de;
					return E_OK;
				}
				*parentstart = startindex = de.pri.start;
				dirend = de.pri.length + de.pri.start;
			}
		}
	}
	
error:
	/* Wenn noch ein PATHSEP im Pfad steht, gibt es `path not found'. Sonst
	`file not found' */
	
	return strchr (path, '\\') ? EPTHNF : EFILNF;
}

static long
get_direntry_by_name (LOGICAL_DEV *ldp, char *path, DIRENTRY *de)
{
	unsigned long parent_start;
	int fn_index;
	long ret;
	
/* fprintf (stderr, "get_direntry_by_name: `%s'\n", path); */

	memset (de, 0, sizeof (DIRENTRY));

	/* Root directory */

	if (path[0] == '\0')
	{
		de->iindex = de->pri.start = ldp->rootdir;
		de->pri.length = ldp->rootdirsize;
		de->tosattr = FA_SUBDIR;
		de->adate = de->cdate = de->mdate = ldp->mount_date;
		de->atime = de->ctime = de->mtime = ldp->mount_time;
		de->mode = S_IFDIR|DEFAULT_DIRMODE;
		de->nlink = 1;

/* fprintf (stderr, "gdbn: root: %ld %ld\n", ldp->rootdir, ldp->rootdirsize); */

		return E_OK;
	}

	/* Identisch mit gemerktem? */
	
	if (!strcmp (path, ldp->lastde.name))
	{
		*de = ldp->lastde.de;
		return E_OK;
	}
/* printf ("%s %s \n", path, ldp->lastde.name); */

	ret = _get_direntry_by_name (ldp, path, de, ldp->rootdir,
		ldp->rootdir + ldp->rootdirsize, &parent_start, &fn_index);
	if (ret) return ret;
	
	strcpy (ldp->lastde.name, path);
	ldp->lastde.tail = ldp->lastde.name + fn_index;
	ldp->lastde.parentstart = parent_start;
	ldp->lastde.de = *de;
	
	return E_OK;
}


/* Funktionen */

long cdecl
DiskFree (LOGICAL_DEV *ldp, void *drp,
	long ret, int opcode, DISKINFO *buf, int drive)
{
	int vret = DKInitVolume (ldp);

	(void) drive,opcode,drp,ret;

	if (! (vret & 1)) return EPTHNF;

	buf->b_free = 0;
	buf->b_total = ldp->totalsize;
	buf->b_secsiz = ldp->blocksize;
	buf->b_clsiz = 1;

	return E_OK;
}

long cdecl
SetPath (LOGICAL_DEV *ldp, char *pathname, void *drp,
	long ret, int opcode, char *path)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);

	(void)drp,ret,opcode,path;

	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, NULL);
	ret = get_direntry_by_name (ldp, pathname, &de);

	if (ret == EFILNF || ret == ENMFIL) return EPTHNF;
	if (ret) return ret;

	return de.tosattr & FA_SUBDIR ? E_OK : EPTHNF;
}

long cdecl
OpenFile (LOGICAL_DEV *ldp, char *pathname, MYFILE *fp,
	long ret, int opcode, char *pn, int mode)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);
	int drive;
	
	(void)opcode,pn,mode;

	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, &drive);

	/* Dieser Hack ist fr die kaputte Media-Change-Routine im
	Desktop von TOS 1.04 n”tig -- anderenfalls wird der in
	hdv_getbpb installierte Handler nie wieder deinstalliert */

	if (pathname[0] == '\\' && pathname[1] == 'X' && pathname[2] == '\0')
		Getbpb (drive);

	ret = get_direntry_by_name (ldp, pathname, &de);
	if (ret) return ret;

	/* In der Betaversion kann man auch Verzeichnisse direkt
	einlesen */

#ifndef BETA
	if (de.tosattr & FA_SUBDIR) return EFILNF;
#endif

	fp->start = de.pri.start;	
	fp->size = de.pri.length;
	fp->iindex = de.iindex;
	fp->offset = 0;
	fp->dev = drive;

	return E_OK;
}

long cdecl
CloseFile (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode,
	int handle)
{
	(void)ret,opcode,handle,fp,ldp;

	return E_OK;
}

long cdecl
ReadFile (LOGICAL_DEV *ldp, MYFILE *fp,
	long ret, int opcode, int handle, long count, void *buffer)
{
	long cnt = count;
	int vret = DKInitVolume (ldp);

	(void)opcode,handle;

	if (vret & 2) return E_CHNG; if (! (vret & 1)) return EIHNDL;

/* printf ("read %ld count curroff: %ld\n", count, fp->offset); */

	if (fp->offset + cnt > fp->size) cnt = fp->size - fp->offset;

	/* xxx: muž hier die Fehlererkennung noch verbessert werden? */

	ret = ldp->fs.readfile (ldp, fp->start, fp->offset, fp->size,
		fp->iindex, cnt, buffer);
	if (ret) return ret;
	
	fp->offset += cnt;
	return cnt;
}

long cdecl
SeekFile (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode,
	long offset, int handle, int seekmode)
{
	long newoff;	
	int vret = DKInitVolume (ldp);

	(void)ldp,ret,opcode,handle;

	if (vret & 2) return E_CHNG; if (! (vret & 1)) return EIHNDL;

/* printf ("seek %ld mode %d\n", offset, seekmode); */

	switch (seekmode)
	{
		case 0:
			newoff = offset;
			break;
					
		case 1:
			newoff = fp->offset + offset;
			break;
			
		case 2:
			newoff = fp->size + offset;
			break;

		default:
			return EINVFN;
	}
	
	if (newoff < 0 || newoff > fp->size)
		return ERANGE;
	
	return fp->offset = newoff;
}

long cdecl
FileAttributes (LOGICAL_DEV *ldp, char *pathname,
	long ret, int opcode, char *pn, int wflag, int attr)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);

	(void)opcode,attr,pn,wflag;
	
	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, NULL);
	ret = get_direntry_by_name (ldp, pathname, &de);
	if (ret) return ret;

	if (wflag) return EWRPRO;
	
	return de.tosattr;
}

long cdecl
FileXAttributes (LOGICAL_DEV *ldp, char *pathname,
	long ret, int opcode, int flag, char *pn, XATTR *xap)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);
	int drive;
	
	(void)opcode,flag,pn;
	
	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, &drive);
	ret = get_direntry_by_name (ldp, pathname, &de);
	if (ret) return ret;

	DKDirentry2Xattr (ldp, &de, drive, xap);
	
	return E_OK;
}

long cdecl
PathConf (LOGICAL_DEV *ldp, long ret, int opcode, char *name, int mode)
{
	int vret = DKInitVolume (ldp);
	
	(void)ret,opcode,name;

	/* get maxhandles from metados */
	
	if (mode == 0)
	{
		META_INFO_1 mi;

		DKMaxOpenFiles = 100; /* alte Metad”sse */

		mi.mi_info = 0;
		Metainit (&mi);
		if (mi.mi_info && mi.mi_info->mi_version >= 0x271)
		{
			DKMaxOpenFiles = mi.mi_info->mi_handles;
			if (!DKMaxOpenFiles) DKMaxOpenFiles = 0x7fffffffL;
		}
	}
	
	if (! (vret & 1)) return EPTHNF;

	return ldp->fs.pathconf (ldp, mode);
}

long cdecl
ReadLabel (LOGICAL_DEV *ldp, long ret, int opcode,
	const char *path, char *name, int size)
{
	int vret = DKInitVolume (ldp);
	
	(void)ret,opcode,path,name;
	
	if (! (vret & 1)) return EPTHNF;

	return ldp->fs.label (ldp, name, size, 0);
}

long cdecl
WriteLabel (LOGICAL_DEV *ldp, long ret, int opcode,
	const char *path, char *name)
{
	int vret = DKInitVolume (ldp);
	
	(void)ret,opcode,path,name;
	
	if (! (vret & 1)) return EPTHNF;

	return ldp->fs.label (ldp, name, (int) strlen (name), 1);
}

long cdecl
DLock (LOGICAL_DEV *ldp, long ret, int opcode, int mode)
{
	(void)ret,opcode;
	
	if ((mode & 1) == 0) /* unlock */
	{
		DKFlipPreferred (ldp);
		DKInitVolume (ldp);
	}
	
	return E_OK;
}


/*
 * void copy8_3(dest, src): convert a file name (src) into DOS 8.3 format
 * (in dest). Note the following things:
 * if a field has less than the required number of characters, it is
 * padded with blanks
 * a '*' means to pad the rest of the field with '?' characters
 * special things to watch for:
 *	"." and ".." are more or less left alone
 *	"*.*" is recognized as a special pattern, for which dest is set
 *	to just "*"
 * Long names are truncated. Any extensions after the first one are
 * ignored, i.e. foo.bar.c -> foo.bar, foo.c.bar->foo.c.
 */

void
copy8_3 (char *dest, const char *src)
{
	char fill = ' ', c;
	int i;

	if (src[0] == '.') {
		if (src[1] == 0) {
			strcpy(dest, ".       .   ");
			return;
		}
		if (src[1] == '.' && src[2] == 0) {
			strcpy(dest, "..      .   ");
			return;
		}
	}

	if (src[0] == '*' && src[1] == '.' && src[2] == '*' && src[3] == 0) {
		dest[0] = '*';
		dest[1] = 0;
		return;
	}

	for (i = 0; i < 8; i++) {
		c = *src++;
		if (!c || c == '.') break;
		if (c == '*') {
			fill = c = '?';
		}
		*dest++ = toupper(c);
	}
	while (i++ < 8) {
		*dest++ = fill;
	}
	*dest++ = '.';
	i = 0;
	fill = ' ';
	while (c && c != '.')
		c = *src++;

	if (c) {
		for( ;i < 3; i++) {
			c = *src++;
			if (!c || c == '.') break;
			if (c == '*')
				c = fill = '?';
			*dest++ = toupper(c);
		}
	}
	while (i++ < 3)
		*dest++ = fill;
	*dest = 0;
}

/*
 * int pat_match(name, patrn): returns 1 if "name" matches the template in
 * "patrn", 0 if not. "patrn" is assumed to have been expanded in 8.3
 * format by copy8_3; "name" need not be. Any '?' characters in patrn
 * will match any character in name. Note that if "patrn" has a '*' as
 * the first character, it will always match; this will happen only if
 * the original pattern (before copy8_3 was applied) was "*.*".
 *
 * BUGS: acts a lot like the silly TOS pattern matcher.
 */

int
pat_match (const char *name, char *template)
{
	char *s, c;
	char expname[14];

	if (*template == '*') return 1;
	copy8_3 (expname, name);

	s = expname;
	while ((c = *template++) != 0)
	{
		if (c != *s && c != '?')
			return 0;

		s++;
	}

	return 1;
}

static long
search (LOGICAL_DEV *ldp, myDTA *dta, int first)
{
	DIRENTRY de;

	/* Special case for volume name */
	
	if (first && (dta->ds_attrib & FA_VOLUME) &&
		dta->ds_dirindex == ldp->rootdir)
	{
		long ret;
		
		ret = ldp->fs.label (ldp, dta->d_fname, 8+3+1+1, 0);

/* printf ("%ld %s\n", ret, dta->d_fname); */

		dta->d_date = ldp->mount_date;
		dta->d_time = ldp->mount_time;
		dta->d_length = 0;
		dta->d_attrib = FA_VOLUME;
		
		if (pat_match (dta->d_fname, dta->ds_name))
		{
			if (ret == E_OK) return E_OK;

			/* Im Fehlerfall nur dann zurckkehren, wenn auch wirklich
			nur das Label gesucht wurde */

			if (dta->ds_attrib == FA_VOLUME) return ret;
		}
	}

	while (1)
	{
		long ret;

		ret = ldp->fs.get_direntry (ldp, &dta->ds_dirindex, dta->ds_dirend, &de);
		if (ret == ENMFIL && first) ret = EFILNF;
		if (ret) return ret;

		if (de.tosattr != 0 && ! (de.tosattr & dta->ds_attrib))
			continue;

		if (! pat_match (de.truncname, dta->ds_name))
			continue;

		break;
	}

	dta->d_time = de.mtime;
	dta->d_date = de.mdate;
	dta->d_length = de.pri.length;

/* printf ("%ld %s\n", strlen (de.truncname), de.truncname); */

	strcpy (dta->d_fname, de.truncname);

	dta->d_attrib = de.tosattr; 	/* wg DTA-Struktur */

	return E_OK;
}

long cdecl
SearchFirst (LOGICAL_DEV *ldp, char *pathname, myDTA *dta,
	long ret, int opcode, char *pn, int attribs)
{
	char *name, *path;
	DIRENTRY de;
	int vret = DKInitVolume (ldp);

	(void)opcode,pn;
	
	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, NULL);

	/* Pfad und Rest trennen */
	path = "";
	name = strrchr (pathname, '\\');
	if (name)
	{
		*name = '\0';
		path = pathname;
		name += 1;
	}
	else
		name = pathname;
	
	ret = get_direntry_by_name (ldp, path, &de);
	if (ret) return ret;
	
	if (strlen (name) > 12) return ERANGE;

	if (!strlen (name)) name = ".";
	copy8_3 (dta->ds_name, name);
	dta->ds_dirindex = de.pri.start;
	dta->ds_dirend = de.pri.start + de.pri.length;
	dta->ds_attrib = attribs;

	return search (ldp, dta, 1);
}

long cdecl
SearchNext (LOGICAL_DEV *ldp, myDTA *dta, long ret, int opcode)
{
	(void)ret,opcode;

	return search (ldp, dta, 0);
}

long cdecl
DateAndTime (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode,
	DOSTIME *timeptr, int handle, int wflag)
{
	DIRENTRY de;
	unsigned long offs;
	int vret = DKInitVolume (ldp);

	(void)opcode,handle;

	if (! (vret & 1)) return EPTHNF;
	if (wflag) return EWRPRO;

	offs = fp->iindex;
	ret = ldp->fs.get_direntry (ldp, &offs, fp->de_end, &de);
	if (ret) return ret;

	timeptr->date = de.mdate;
	timeptr->time = de.mtime;

	return E_OK;
}


long cdecl
FCntl (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode,
	int handle, long arg, int command)
{
	DIRENTRY de;
	unsigned long offs;
	int vret = DKInitVolume (ldp);

	(void)opcode,handle;

	if (! (vret & 1)) return EPTHNF;

	offs = fp->iindex;
	ret = ldp->fs.get_direntry (ldp, &offs, fp->de_end, &de);
	if (ret) return ret;
	
	switch (command)
	{
		case FSTAT:
			{
				XATTR *xp = (XATTR *) arg;
				
				DKDirentry2Xattr (ldp, &de, fp->dev, xp);
				
				return E_OK;			
			}

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
			
		case FMACOPENRES:
			{
				if (de.ass.start == 0) return EFILNF;
	
				fp->start = de.ass.start;
				fp->size = de.ass.length;
				fp->offset = 0;
	
				return E_OK;
			}
	}

	return EINVFN;
}

static long
get_mac_info (LOGICAL_DEV *ldp, char *pathname, MacFinderInfo *M)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);
	int drive;
	long ret;
	
	memset (M, 0, sizeof (MacFinderInfo));

	if (! (vret & 1)) return EPTHNF;

	pathname = tune_pn (pathname, &drive);
	ret = get_direntry_by_name (ldp, pathname, &de);
	if (ret) return ret;

	M->fdType = de.type;
	M->fdCreator = de.creator;
	
	return de.type != 0 && de.creator != 0 ? E_OK : EINVFN;
}


long cdecl
DCntl (LOGICAL_DEV *ldp, char *pathname, long ret, int opcode,
	int dop, char *name, long arg)
{
/*	int vret = DKInitVolume (ldp); */

	(void) ret,opcode,name;

/* 	if (! (vret & 1)) return EPTHNF; */

/* printf ("Dcntl: %x %s %lx\n", dop, name, arg); */

	if ((dop >> 8) == 'C')
		return Metaioctl (ldp->metadevice, 'FCTL', dop, (void *)arg);

	switch (dop)
	{
		case FMACGETTYCR:
			return get_mac_info (ldp, pathname, (MacFinderInfo *) arg);

		case FMACSETTYCR:
			return EWRPRO;
	}
	
	return EINVFN;
}

long cdecl
OpenDir (LOGICAL_DEV *ldp, char *pathname, MYFILE *fp,
	long ret, int opcode, char *name, int flg)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);
	int drive;
	
	(void)opcode,name;

	if (! (vret & 1)) return EPTHNF;

/* fprintf (stderr, "opendir: `%s'\n", pathname); */

	pathname = tune_pn (pathname, &drive);
	ret = get_direntry_by_name (ldp, pathname, &de);
	if (ret) return ret;

	if (!(de.tosattr & FA_SUBDIR)) return EPTHNF;

	fp->offset = fp->start = de.pri.start;	
	fp->size = de.pri.length;
	fp->dev = drive;
	fp->dirflg = flg;

	return E_OK;
}



long cdecl
XReadDir (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode, int len,
	long dirhandle, long *buf, XATTR *xap, long *xret)
{
	DIRENTRY de;
	int vret = DKInitVolume (ldp);
	int reclen = 12;

	(void) opcode,dirhandle;

	if (! (vret & 1)) return EPTHNF;

	ret = ldp->fs.get_direntry (ldp, &fp->offset, fp->start + fp->size, &de);
	if (ret) return ret;

	/* Namen und DIRENTRY merken */
	if ((fp->start == ldp->lastde.parentstart) && ldp->lastde.tail) {
		strcpy (ldp->lastde.tail, de.longname);
		ldp->lastde.de = de;
	}
	
	if (!fp->dirflg) reclen += (int) sizeof (long);
	if (reclen > len) return ERANGE;
	
	/* Insert file index if needed */
	if (!fp->dirflg) *buf++ = de.pri.start;
	
	strcpy ((char *)buf, fp->dirflg ? de.truncname : de.longname);

	if (xap)
	{	
		DKDirentry2Xattr (ldp, &de, fp->dev, xap);
		*xret = E_OK;
	}
	
	return E_OK;
}

long cdecl
ReadDir (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode, int len,
	long dirhandle, long *buf)
{
	return XReadDir (ldp, fp, ret, opcode, len, dirhandle, buf, NULL, NULL);
}

long cdecl
RewindDir (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode, long dirhandle)
{
	(void) ldp,ret,opcode,dirhandle;

	fp->offset = fp->start;
	
	return E_OK;
}

long cdecl
CloseDir (LOGICAL_DEV *ldp, MYFILE *fp, long ret, int opcode,
	long dirhandle)
{
	(void) fp,ret,opcode,dirhandle;

	ldp->lastde.tail = NULL;
	ldp->lastde.parentstart = 0;

	return E_OK;
}



long wrpro (void) { return EWRPRO; }

extern initfun ();
extern wrapdfree (), wrapfsfirst (), wrapfsnext ();
extern wrapfopen (), wrapfclose (), wrapfdatime ();
extern wrapfread (), wrapfattrib (), wrapfseek ();
extern wrapdsetpath (), wrapdcntl (), wrapfxattr ();
extern wrapdopendir (), wrapdreaddir (), wrapdrewinddir ();
extern wrapdclosedir (), wrapdpathconf (), wrapdxreaddir ();
extern wrapdreadlabel (), wrapdwritelabel (), wrapfcntl ();
extern wrapdlock ();

long FunctionTable[] =
{
	'MAGI', 'CMET', 349,
	(long) initfun,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, -1L, -1L, /* 49 */
	-1L, -1L, -1L, -1L, (long) wrapdfree,
	-1L, -1L, (long) wrpro, (long) wrpro, (long) wrapdsetpath, /* 59 */
	(long) wrpro, (long) wrapfopen, (long) wrapfclose,
	(long) wrapfread, (long) wrpro,
	(long) wrpro, (long) wrapfseek, (long) wrapfattrib, -1L, -1L, /* 69 */
	-1L, -1L, -1L, -1L, -1L,
	-1L, -1L, -1L, (long) wrapfsfirst, (long) wrapfsnext,
	-1L, -1L, -1L, -1L, -1L,
	-1L, (long) wrpro, (long) wrapfdatime, -1L, -1L, /* 89 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 99 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 109 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 119 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 129 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 139 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 149 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 159 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 169 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 179 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 189 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 199 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 209 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 219 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 229 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 239 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 249 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 259 */
	(long) wrapfcntl, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 269 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 279 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 289 */
	-1L, -1L, (long) wrapdpathconf, -1L, -1L, -1L, (long) wrapdopendir,
	(long) wrapdreaddir, (long) wrapdrewinddir, (long) wrapdclosedir, /* 299 */
	(long) wrapfxattr, -1L, -1L, -1L, (long) wrapdcntl,
	-1L, -1L, -1L, -1L, (long) wrapdlock, /* 309 */
	-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, /* 319 */
	-1L, -1L, (long) wrapdxreaddir, -1L, -1L,	/* 324 */
	-1L, -1L, -1L, -1L, -1L,  /* 329 */
	-1L, -1L, -1L, -1L, -1L,  /* 334 */
	-1L, -1L, -1L, (long) wrapdreadlabel, (long) wrapdwritelabel,  /* 339 */
	-1L, -1L, -1L, -1L, -1L,  /* 344 */
	-1L, -1L, -1L, -1L, -1L,  /* 349 */
};


/* Geraetestring erzeugen */

static
char *dev_str (int dev)
{
	static char str[] = " MetaDOS device #: ";

	str[16] = dev;
	
	return str;
}

void * cdecl
InitDevice (int deviceid)
{
	LOGICAL_DEV *ldp;
	META_DRVINFO md;
	
	Bconws (dev_str (deviceid));

	if (E_OK != Metaopen (deviceid, &md)) {
		Bconws ("Device not responding.\n");
		return (void *)-1L;
	}

	Metaclose (deviceid);

again:	
	ldp = Mxalloc (sizeof (LOGICAL_DEV) + cacheblocks * sizeof (CACHEENTRY), 0);
	if (ldp == (LOGICAL_DEV *) -32L)
		ldp = Malloc (sizeof (LOGICAL_DEV) + cacheblocks * sizeof (CACHEENTRY));
	
	if (!ldp) {
		if (cacheblocks > DEFAULTCACHESIZE) {
			Bconws ("Not enough memory for buffers, trying only 16K...\n");
			cacheblocks = DEFAULTCACHESIZE;
			goto again;
		}

		Bconws ("Not enough memory for buffers\n");
		return (void *)-1L;
	}

	memset (ldp, 0, sizeof (LOGICAL_DEV));

	ldp->mediatime = *_hz_200 + MEDIADELAY;
	ldp->metadevice = deviceid;

	Bconws (md.mdr_name);


	/* Cachegr”že ausgeben */
	
	if (cacheblocks)
	{
		char str[] = "\n (0000 Kbytes of sector cache)";
		long cachesize = 2L * cacheblocks;
		
		str[6] = '0' + cachesize % 10; cachesize /= 10;
		str[5] = '0' + cachesize % 10; cachesize /= 10;
		str[4] = '0' + cachesize % 10; cachesize /= 10;
		str[3] = '0' + cachesize % 10;
		
		Bconws (str);

		/* In doslow.c eintragen */
		
		DCSize = cacheblocks;
		DCCache = (CACHEENTRY *)(ldp + 1);	/* zeigt dahinter */

		DCClear (ldp);
		cacheblocks = 0;
	}
	
	Bconws ("\n");
	
	return ldp;
}

void
ShowBanner (void)
{
	char *cmds = &startoftext - 128;
	int len = *cmds++;

	Bconws ("\033p CD-Tool ISO9660 Filesystem "VERSIONSTRING" \033q\r\n");

	cmds[len] = '\0';
	if (cmds[0] == '-' && cmds[1] == 'c') {
		long cachesize = 0;
		char *c = cmds + 2;
		
		while (*c == ' ') c += 1;
		while (isdigit (*c)) {
			cachesize *= 10;
			cachesize += *c - '0';
			c += 1;
		}

		cachesize /= 2;
		if (cachesize > DEFAULTCACHESIZE && cachesize < 500)
			cacheblocks = (int) cachesize;
	}
}
