#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <tos.h>
#include <time.h>
#include <toserror.h>
#include "mint/cdromio.h"
#define PD BASEPAGE
typedef void APPL;
#include "mgx_xfs.h"
#include "mgx_devd.h"
#include "cdfs.h"
#include "libcdfs.h"
#include "metados.h"

#define CD_FRAMES            75 /* frames per second */
#define CD_MSF_OFFSET       150 /* MSF numbering offset of first frame */

#define CD_MAX_TRACKS 128
#define CD_FRAMESIZE_RAW   2352 /* bytes per frame, "raw" mode */

#define PROGFILE_OFFSET 200

#define FS_AUDIO 0x01
#define FS_EMPTY 0x02

/*
 * FIXME: using static data here makes the XFS non-reentrant
 */
typedef struct _wavheader {
	char ChunkID[4];
	unsigned long ChunkSize;
	char Format[4];
	char SubChunk1ID[4];
	unsigned long SubChunk1Size;
	unsigned short AudioFormat;
	unsigned short NumChannels;
	unsigned long SampleRate;
	unsigned long ByteRate;
	unsigned short BlockAlign;
	unsigned short BitsPerSample;
	char SubChunk2ID[4];
	unsigned long SubChunk2Size;
} WAVHEADER;
static WAVHEADER wavheader = {
	{ 'R', 'I', 'F', 'F' },
	0,
	{ 'W', 'A', 'V', 'E' },
	{ 'f', 'm', 't', ' ' },
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	{ 'd', 'a', 't', 'a' },
	0
};
	
	
static unsigned long il2ml(unsigned long val)
{
	union {
		unsigned long l;
		unsigned char c[4];
	} v, r;
	unsigned char *src;
	unsigned char *dst;
	
	v.l = val;
	dst = r.c;
	src = v.c;
	dst[0] = src[3];
	dst[1] = src[2];
	dst[2] = src[1];
	dst[3] = src[0];
	return r.l;
}


static unsigned short is2ms(unsigned short val)
{
	union {
		unsigned short l;
		unsigned char c[2];
	} v, r;
	unsigned char *src;
	unsigned char *dst;
	
	v.l = val;
	dst = r.c;
	src = v.c;
	dst[0] = src[1];
	dst[1] = src[0];
	return r.l;
}


static void setupheader(unsigned long size)
{
	wavheader.ChunkSize = il2ml(size + (sizeof(wavheader) - 8));
	wavheader.SubChunk1Size = il2ml(offsetof(WAVHEADER, SubChunk2ID) - offsetof(WAVHEADER, SubChunk1ID) - 8);
	wavheader.AudioFormat = is2ms(1);
	wavheader.NumChannels = is2ms(2);
	wavheader.SampleRate = il2ml(44100L);
	wavheader.ByteRate = il2ml(44100L * 2 * 2);
	wavheader.BitsPerSample = is2ms(16);
	wavheader.SubChunk2Size = il2ml(size);
	wavheader.BlockAlign = is2ms(4);
}


static unsigned short lba2time(unsigned long frame)
{
	unsigned long s;
	unsigned long h;
	unsigned long m;
	
	s = frame / CD_FRAMES;
	s += 1;
	h = s / 3600;
	s -= h * 3600;
	m = s / 60;
	s -= m * 60;
	return ((unsigned short)h << 11) | ((unsigned short)m << 5) | (unsigned short)(s >> 1);
}


static short addr2track(short addr)
{
	return (addr + 1) / 2;
}


static void bcd2bin3(unsigned char *str)
{
	int c, c2;
	
	c = c2 = str[0];
	c /= 16;
	c *= 10;
	str[0] = c + (c2 &= 0x0f);
	c = c2 = str[1];
	c /= 16;
	c *= 10;
	str[1] = c + (c2 &= 0x0f);
	c = c2 = str[2];
	c /= 16;
	c *= 10;
	str[2] = c + (c2 &= 0x0f);
}


static void bcd2bin(unsigned short *str)
{
	unsigned short c = str[0] >> 4;
	str[0] = (str[0] & 0x0f) + c * 10;
}


static long get_entries_m(LOGICAL_DEV *ldp, short track, struct cdrom_tocentry *curr, struct cdrom_tocentry *next, unsigned long *addr)
{
	CD_TOC_ENTRY *toc;
	long err;
	int i;
	unsigned short trackno;
	
	toc = (CD_TOC_ENTRY *)ldp->scratch;
	memset(toc, 0, CD_MAX_TRACKS * sizeof(*toc));
	
	err = Metagettoc(ldp->metadevice, 1, toc);
	if (err != 0)
		return err;
	for (i = 0; i < CD_MAX_TRACKS; i++)
	{
		trackno = toc[i].trackno;
		bcd2bin(&trackno);
		toc[i].trackno = trackno;
		bcd2bin3(&toc[i].minute);
	}

	for (i = 0; i < (CD_MAX_TRACKS - 1); i++)
	{
		if (toc[i].trackno < 1 || toc[i].trackno > 99)
			break;
		if (toc[i].trackno == track)
		{
			memset(curr, 0, sizeof(*curr));
			memset(next, 0, sizeof(*next));
			curr->cdte_track = toc[i].trackno;
			next->cdte_track = toc[i + 1].trackno;
			curr->cdte_addr.lba = ((long)toc[i].minute * 60 + toc[i].second) * CD_FRAMES + toc[i].frame - CD_MSF_OFFSET;
			next->cdte_addr.lba = ((long)toc[i + 1].minute * 60 + toc[i + 1].second) * CD_FRAMES + toc[i + 1].frame - CD_MSF_OFFSET;
			return 0;
		}
	}
	*addr = -1;
	return ENMFIL;
}


static long get_entries(LOGICAL_DEV *ldp, short track, struct cdrom_tocentry *curr, struct cdrom_tocentry *next, unsigned long *addr)
{
	long err;
	
	curr->cdte_track = track;
	next->cdte_track = track + 1;
	curr->cdte_format = next->cdte_format = CDROM_LBA;
	err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCENTRY, curr);
	if (err == EINVFN || err == EUNCMD)
	{
		return get_entries_m(ldp, track, curr, next, addr);
	}
	if (err != 0)
	{
		*addr = -1;
		if (err == EFILNF)
			err = ENMFIL;
		return err;
	}
	err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCENTRY, next);
	if (err == EFILNF)
	{
		next->cdte_track = CDROM_LEADOUT;
		err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCENTRY, next);
		if (err != 0)
		{
			*addr = -1;
			return err;
		}
	}
	return 0;
}


static long get_direntry(LOGICAL_DEV *ldp, unsigned long *addr, unsigned long dirend, DIRENTRY *de)
{
	struct cdrom_tocentry curr;
	struct cdrom_tocentry next;
	short track;
	long err;
	int isaudio;
	
	UNUSED(dirend);
	for (;;)
	{
		memset(de, 0, sizeof(*de));
		if (*addr == -1)
			return ENMFIL;
		if (*addr == 0)
		{
			*addr = ldp->fsprivate & FS_EMPTY ? -1L : 1L;
			de->pri.length = ldp->rootdirsize;
			if (ldp->fsprivate & FS_AUDIO)
			{
				de->pri.length *= 2;
			}
			de->mode = __S_IFDIR|S_IRUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH;
			de->adate = de->cdate = de->mdate = ldp->mount_date;
			de->atime = de->ctime = de->mtime = ldp->mount_time;
			de->nlink = 2;
			de->tosattr = FA_SUBDIR;
			strcpy(de->longname, ".");
			strcpy(de->truncname, ".");
			return 0;
		}
	
		track = (short)*addr;
		de->iindex = *addr;
		++(*addr);
		err = get_entries(ldp, addr2track(track), &curr, &next, addr);
		if (err != 0)
			return err;
		if (!(curr.cdte_ctrl & CDROM_DATA_TRACK))
			isaudio = TRUE;
		else
			isaudio = FALSE;
		if (track & 1)
		{
			if (isaudio)
				break;
			else
				continue;
		}
		if (!isaudio)
			break;
		else if (ldp->fsprivate & FS_AUDIO)
			break;
	}
	if (track & 1)
		strcpy(de->truncname, "TRACK00.PRG");
	else
		strcpy(de->truncname, !isaudio ? "TRACK00.DAT" : "TRACK00.WAV");
	de->truncname[5] += addr2track(track) / 10;
	de->truncname[6] += addr2track(track) % 10;
	strcpy(de->longname, de->truncname);

	de->adate = de->cdate = de->mdate = ldp->mount_date;
	de->mode = __S_IFREG|S_IRUSR|S_IRGRP|S_IROTH;
	if (track & 1)
		de->mode |= S_IXUSR|S_IXGRP|S_IXOTH;
	de->pri.start = track & 1 ? addr2track(track) : curr.cdte_addr.lba + PROGFILE_OFFSET;
	if (track & 1)
	{
		de->pri.length = proc_len;
		de->type = 0x2e505247L; /* '.PRG' */
	} else
	{
		de->pri.length = (next.cdte_addr.lba - curr.cdte_addr.lba) * CD_FRAMESIZE_RAW + sizeof(WAVHEADER);
		if (!isaudio)
			de->pri.length = (next.cdte_addr.lba - curr.cdte_addr.lba) * BLOCKSIZE;
		de->type = isaudio ? 0x57415645L : 0x44415441L; /* 'WAVE' / 'DATA' */
	}
	
	de->atime = de->mtime = lba2time(next.cdte_addr.lba - curr.cdte_addr.lba);
	de->ctime = lba2time(curr.cdte_addr.lba);
	de->nlink = 1;
	de->creator = 0x4344546cL; /* CDTl */
	return 0;
}


static long readfile(LOGICAL_DEV *ldp, long start, long offset,
	long size, long iindex, long cnt, char *buffer)
{
	unsigned long fileoffset;
	long recno;
	long err;
	struct cdrom_read cdread;
	long offset_in_rec;

	UNUSED(iindex);
	
	if (start < PROGFILE_OFFSET)
	{
		proc_device = ldp->metadevice;
		proc_track = (unsigned char)start;
		memcpy(buffer, proc_file + offset, cnt);
		return 0;
	}
	
	if (((size - sizeof(WAVHEADER)) % CD_FRAMESIZE_RAW) != 0)
	{
		return DCRead(ldp, (start - PROGFILE_OFFSET) * BLOCKSIZE + offset, cnt, buffer);
	}

	fileoffset = offset - sizeof(WAVHEADER);
	if (offset < sizeof(WAVHEADER))
	{
		long toread;
		const char *header = (const char *)&wavheader;
		
		toread = sizeof(WAVHEADER) - offset;
		setupheader(size - sizeof(WAVHEADER));
		memcpy(buffer, header + offset, toread);
		buffer += toread;
		cnt -= toread;
		fileoffset = 0;
		if (cnt == 0)
			return 0;
	}

	recno = fileoffset / CD_FRAMESIZE_RAW;
	offset_in_rec = fileoffset % CD_FRAMESIZE_RAW;
	if (offset_in_rec != 0 || cnt < CD_FRAMESIZE_RAW)
	{
		long toread = cnt;

		if ((offset_in_rec + toread) > CD_FRAMESIZE_RAW)
			toread = CD_FRAMESIZE_RAW - offset_in_rec;
		cdread.cdread_buflen = CD_FRAMESIZE_RAW;
		cdread.cdread_bufaddr = ldp->scratch;
		cdread.cdread_lba = start + recno - PROGFILE_OFFSET;
		err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADDA, &cdread);
		if (err != 0)
			return err;
		memcpy(buffer, &ldp->scratch[offset_in_rec], toread);
		buffer += toread;
		fileoffset += toread;
		cnt -= toread;
	}
	
	recno = fileoffset / CD_FRAMESIZE_RAW;
	offset_in_rec = fileoffset % CD_FRAMESIZE_RAW;
	
	while (cnt > CD_FRAMESIZE_RAW)
	{
		long sectors = cnt / CD_FRAMESIZE_RAW;
		if (sectors > 10000)
			sectors = 10000;
		cdread.cdread_buflen = sectors * CD_FRAMESIZE_RAW;
		cdread.cdread_bufaddr = buffer;
		cdread.cdread_lba = start + recno - PROGFILE_OFFSET;
		err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADDA, &cdread);
		if (err != 0)
			return err;
		
		buffer += cdread.cdread_buflen;
		fileoffset += cdread.cdread_buflen;
		cnt -= cdread.cdread_buflen;
		
		recno = fileoffset / CD_FRAMESIZE_RAW;
		offset_in_rec = fileoffset % CD_FRAMESIZE_RAW;
	}
	
	if (cnt != 0)
	{
		cdread.cdread_buflen = CD_FRAMESIZE_RAW;
		cdread.cdread_bufaddr = ldp->scratch;
		cdread.cdread_lba = start + recno - PROGFILE_OFFSET;
		err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADDA, &cdread);
		if (err != 0)
			return err;
		memcpy(buffer, ldp->scratch, cnt);
	}
	
	return 0;
}


static long get_root(LOGICAL_DEV *ldp, unsigned long lba, int count)
{
	CD_DISC_INFO *di = (CD_DISC_INFO *)ldp->scratch;
	struct cdrom_tocentry toc;
	struct cdrom_read cdread;
	unsigned short firsttrack;
	unsigned short lasttrack;
	unsigned int i;
	long err;
	
	UNUSED(lba);
	UNUSED(count);

	ldp->fsprivate = 0;
	memset(di, 0, sizeof(*di));
	firsttrack = 1;
	lasttrack = 0;
	if (Metadiscinfo(ldp->metadevice, di) == 0)
	{
		firsttrack = di->firsttrack;
		bcd2bin(&firsttrack);
		lasttrack = di->lasttrack;
		bcd2bin(&lasttrack);
	}
	memset(&toc, 0, sizeof(toc));
	for (i = firsttrack; i <= lasttrack; i++)
	{
		toc.cdte_track = i;
		toc.cdte_format = CDROM_MSF;
		err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADTOCENTRY, &toc);
		if (err == 0)
		{
			if ((toc.cdte_ctrl & CDROM_DATA_TRACK) == 0)
				break;
		}
	}
	
	cdread.cdread_buflen = CD_FRAMESIZE_RAW;
	cdread.cdread_bufaddr = ldp->scratch;
	cdread.cdread_lba = toc.cdte_addr.msf.minute * 60;
	cdread.cdread_lba += toc.cdte_addr.msf.second + CD_MSF_OFFSET / CD_FRAMES;
	cdread.cdread_lba *= CD_FRAMES;
	cdread.cdread_lba += toc.cdte_addr.msf.frame;
	err = Metaioctl(ldp->metadevice, METADOS_IOCTL_MAGIC, CDROMREADDA, &cdread);
	if (err == 0)
		ldp->fsprivate |= FS_AUDIO;
	ldp->rootdirsize = (lasttrack - firsttrack + 1);
	ldp->blocksize = 1;
	ldp->totalsize = ldp->rootdirsize * proc_len;
	if (ldp->rootdirsize == 0)
		ldp->fsprivate |= FS_EMPTY;
	ldp->rootdir = 0;
	strcpy(ldp->fslabel, ldp->fsprivate & FS_EMPTY ? "EMPTY" : "AUDIO-CD");
	return 0;
}


static long label(LOGICAL_DEV *ldp, char *str, int size, int rw)
{
	if (rw)
	{
		if (size >= sizeof(ldp->fslabel))
			return ERANGE;
		strcpy(ldp->fslabel, str);
		return 0;
	}
	strncpy(str, ldp->fslabel, size);
	str[size - 1] = '\0';
	if (strlen(ldp->fslabel) >= size)
		return ERANGE;
	return 0;
}


static long pathconf(LOGICAL_DEV *ldp, int mode)
{
	UNUSED(ldp);
	switch (mode)
	{
	case DP_MAXREQ:
		return DP_MODEATTR;
	case DP_IOPEN:
		return DKMaxOpenFiles;
	case DP_PATHMAX:
		return 96;
	case DP_NAMEMAX:
		return 12;
	case DP_CASE:
		return DP_CASECONV;
	case DP_ATOMIC:
		return 0;
	case DP_TRUNC:
		return DP_DOSTRUNC;
	case DP_MAXLINKS:
		return 1;
	case DP_MODEATTR:
		/* FA_VOLUME is handle by kernel */
		return DP_FT_REG|DP_FT_DIR|FA_VOLUME;
	}
	return EINVFN;
}


FILESYSTEM const tocfs = {
	get_root,
	get_direntry,
	readfile,
	label,
	pathconf
};
