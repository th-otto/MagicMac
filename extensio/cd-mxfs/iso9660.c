#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <tos.h>
#include <time.h>
#include <toserror.h>
#define PD BASEPAGE
typedef void APPL;
#include "mgx_xfs.h"
#include "mgx_devd.h"
#include "cdfs.h"
#include "libcdfs.h"
#include "metados.h"
#include "rock.h"
#include "iso_fs.h"


#define ISOFS_HIGHSIERRA 0x01
#define ISOFS_ROCKRIDGE  0x02
#define ISOFS_JOLIET     0x04

#define RR_BUFSIZE 512

/*
 * 16-bit value encoded as both little-/big-endian
 * FIXME: prefer little-endian value, as linux kernel does
 */
#define isonum_721(p) (p[3] + (p[2] << 8))
#define isonum_733(p) (*((unsigned long *)(p + 4)))
/* truncate 32bit to 16bit */
#define isonum_733_16(p) (p[7] + (p[6] << 8))

static unsigned short const uni_tab[] = {
	0x00c7, 0x00fc, 0x00e9, 0x00e2, 0x00e4, 0x00e0, 0x00e5, 0x00e7,
	0x00ea, 0x00eb, 0x00e8, 0x00ef, 0x00ee, 0x00ec, 0x00c4, 0x00c5,
	0x00c9, 0x00e6, 0x00c6, 0x00f4, 0x00f6, 0x00f2, 0x00fb, 0x00f9,
	0x00ff, 0x00d6, 0x00dc, 0x00a2, 0x00a3, 0x00a5, 0x00df, 0x0192,
	0x00e1, 0x00ed, 0x00f3, 0x00fa, 0x00f1, 0x00d1, 0x00aa, 0x00ba,
	0x00bf, 0x2310, 0x00ac, 0x00bd, 0x00bc, 0x00a1, 0x00ab, 0x00bb,
	0x00e3, 0x00f5, 0x00d8, 0x00f8, 0x0153, 0x0152, 0x00c0, 0x00c3,
	0x00d5, 0x00a8, 0x00b4, 0x2020, 0x00b6, 0x00a9, 0x00ae, 0x2122,
	0x00c2, 0x00c1, 0x00ca, 0x00cb, 0x00c8, 0x00ce, 0x00cf, 0x00cc, /* BUG: these are ISO8859-1 encodings, not AtariST */
	0x00cd, 0x00d4, 0x00d2, 0x00d3, 0x00db, 0x00d9, 0x00da, 0x201e,
	0x201c, 0x201d, 0x201a, 0x2018, 0x2039, 0x203a, 0x2013, 0x2014,
	0x2019, 0x2191, 0x2193, 0x2192, 0x2190, 0x00a7, 0x2030, 0x221e,
	0x03b1, 0x03b2, 0x0393, 0x03c0, 0x2211, 0x03c3, 0x00b5, 0x03c4,
	0x03a6, 0x0398, 0x2126, 0x03b4, 0x222b, 0x03c6, 0x2208, 0x220f,
	0x2261, 0x00b1, 0x2265, 0x2264, 0x2320, 0x2321, 0x00f7, 0x2248,
	0x00b0, 0x2022, 0x00b7, 0x221a, 0x207f, 0x00b2, 0x00b3, 0x00af
};


static void remove_trailing_blanks(char *str)
{
	char *start;
	
	if (*str == '\0')
		return;
	start = str;
	while (*str != '\0')
		str++;
	--str;
	while (str >= start && *str == ' ')
	{
		*str = '\0';
		str--;
	}
}


static int get_susp_field(LOGICAL_DEV *ldp, struct iso_directory_record *dir, const char *tag, void *buf, int bufsize, int entryno)
{
	int len;
	int offset;
	unsigned char *p;
	int entrylen;
	
	UNUSED(ldp);
	len = dir->length;
	p = (unsigned char *)dir;
	offset = dir->name_len + (int)offsetof(struct iso_directory_record, name);
	if (offset & 1)
		offset++;
	while ((offset + 3) < len)
	{
		struct rock_ridge *rr = (struct rock_ridge *)(p + offset);
		if (rr->len == 0)
			return FALSE;
		if (rr->signature[0] == tag[0] && rr->signature[1] == tag[1])
		{
			if (entryno)
			{
				entryno--;
			} else
			{
				entrylen = rr->len;
				if (entrylen > bufsize)
					entrylen = bufsize;
				memcpy(buf, rr, entrylen);
				return TRUE;
			}
		}
		/* System Use Sharing Protocol Terminator */
		if (rr->signature[0] == 'S' && rr->signature[1] == 'T')
			return FALSE;
		offset += rr->len;
	}
	return FALSE;
}


static void uni_tune(char *name, unsigned char *namelen)
{
	int i, j;
	unsigned int c;
	
	if (*namelen == 1)
		return;
	*namelen = *namelen / 2;
	for (i = 0; i < *namelen; i++)
	{
		c = ((unsigned char)name[i * 2] << 8) | (unsigned char)name[i * 2 + 1];
		if (c >= 0x80)
		{
			for (j = 0; j < 128; j++)
			{
				if (uni_tab[j] == c)
				{
					c = j;
					break;
				}
			}
			/* BUG: should use some substitution if not found */
		}
		name[i] = c;
	}
}


static void copyfn(const char *src, int len, char *dst)
{
	if (len == 1 && (*src == 0 || *src == 1))
	{
		strcpy(dst, *src != 0 ? ".." : ".");
	} else
	{
		char *p;
		const char *end;
		int namelen;
		int extflag;
		
		namelen = extflag = 0;
		p = dst;
		end = &src[len];
		*p = '\0';
		while (src != end && *src != '\0' && *src != ';')
		{
			if (extflag == 0 && *src == '.')
			{
				*p++ = *src++;
				extflag = 1;
				namelen = 0;
			} else if ((extflag == 0 && namelen < 8) || (extflag != 0 && namelen < 3 && *src != '.'))
			{
				*p++ = *src++;
				namelen++;
			} else
			{
				src++;
			}
		}
		if (*dst != '\0' && p[-1] == '.')
			--p;
		*p = '\0';
	}
}


static void copyfn_long(const char *src, int len, char *dst)
{
	if (len == 1 && (*src == 0 || *src == 1))
	{
		strcpy(dst, *src != 0 ? ".." : ".");
	} else
	{
		char *p;
		const char *end;
		
		end = &src[len];
		p = dst;
		*dst = '\0';
		while (src != end && *src != '\0' && *src != ';')
		{
			*dst++ = *src++;
		}
		if (*p != '\0' && dst[-1] == '.')
			--dst;
		*dst = '\0';
	}
}


static long get_direntry(LOGICAL_DEV *ldp, unsigned long *addr, unsigned long dirend, DIRENTRY *de)
{
	struct iso_directory_record *rec = (struct iso_directory_record *)ldp->scratch;
	int cont = TRUE;
	int name_len;
	int year;
	int month;
	int day;
	int hour;
	int minute;
	int second;
	int have_px = FALSE;
	char sname[256];
	long iindex;
	unsigned long extent;
	unsigned long size;
	int flags;
	long err;
	
	iindex = 0;
	sname[0] = '\0';
	memset(de, 0, sizeof(*de));
	while (cont)
	{
		if (*addr == -1)
			return ENMFIL;
		de->iindex = *addr;
		err = DCRead(ldp, *addr, RR_BUFSIZE, ldp->scratch);
		if (err != 0)
			return err;
		if (rec->length == 0)
		{
			*addr &= ~(ISOFS_BLOCK_SIZE - 1);
			*addr += ISOFS_BLOCK_SIZE;
			if (*addr >= dirend)
				*addr = -1;
		} else
		{
			*addr += rec->length;
			cont = FALSE;
		}
		if (ldp->fsprivate & ISOFS_HIGHSIERRA)
			flags = rec->date[6];
		else
			flags = rec->flags;
		if (flags & DE_FILE)
		{
			iindex = de->iindex;
			copyfn_long(rec->name, rec->name_len, sname);
			extent = isonum_733(rec->extent) * ldp->blocksize;
			size = isonum_733(rec->size);
			cont = TRUE;
		}
		if (ldp->rootdir == (de->iindex & ~(ISOFS_BLOCK_SIZE - 1)) &&
			rec->name_len == 1 &&
			rec->name[0] == 1)
		{
			cont = TRUE;
		}
	}

	de->fsprivate = 0;
	de->type = 0x54455854L; /* 'TEXT' */
	de->creator = 0x68635354L; /* 'hscd' */
	de->pri.start = isonum_733(rec->extent) * ldp->blocksize;
	de->pri.length = isonum_733(rec->size);
	year = rec->date[0];
	month = rec->date[1];
	day = rec->date[2];
	hour = rec->date[3];
	minute = rec->date[4];
	second = rec->date[5];
	/* BUG: GMT offset not handled */
	if (!(ldp->fsprivate & ISOFS_HIGHSIERRA))
	{
		struct rock_ridge *rr;
		
		flags = rec->flags;
		if (ldp->fsprivate & ISOFS_JOLIET)
			uni_tune(rec->name, &rec->name_len);
		copyfn_long(rec->name, rec->name_len, de->longname);
		copyfn(rec->name, rec->name_len, de->truncname);
		
		rr = (struct rock_ridge *)(ldp->scratch + RR_BUFSIZE);

		if (get_susp_field(ldp, rec, "NM", rr, RR_BUFSIZE, 0) &&
			!(rr->u.NM.flags & (NM_CURRENT|NM_PARENT)))
		{
			name_len = rr->len - (int)offsetof(struct rock_ridge, u.NM.name);
			/* BUG: no filename conversion here */
			strncpy(de->longname, rr->u.NM.name, name_len);
			de->longname[name_len] = '\0';
		}
		
		if (get_susp_field(ldp, rec, "SP", rr, RR_BUFSIZE, 0) &&
			rr->len == 7 &&
			rr->version == 1 &&
			rr->u.SP.magic[0] == 0xBE &&
			rr->u.SP.magic[1] == 0xEF)
		{
			de->fsprivate = 1;
		}
		
		if (get_susp_field(ldp, rec, "AA", rr, RR_BUFSIZE, 0) &&
			rr->len == 14 &&
			(rr->version == 2 || rr->version == 6))
		{
			de->type = *((unsigned long *)rr->u.AA.hfs.fileType + 0);
			de->creator = *((unsigned long *)rr->u.AA.hfs.fileType + 4);
		}

		if (get_susp_field(ldp, rec, "PX", rr, RR_BUFSIZE, 0) &&
			rr->version == 1)
		{
			have_px = TRUE;
			de->nlink = isonum_733_16(rr->u.PX.n_links);
			de->uid = isonum_733_16(rr->u.PX.uid);
			de->gid = isonum_733_16(rr->u.PX.gid);
			/* BUG: must translate mode types for special files */
			de->mode = isonum_733_16(rr->u.PX.mode);
		}
	} else
	{
		flags = rec->date[6];
		copyfn_long(rec->name, rec->name_len, de->longname);
		copyfn(rec->name, rec->name_len, de->truncname);
	}
	
	/*
	 * since we convert the time to dos style,
	 * years < 1980 can't be represented
	 */
	if (year < 80)
	{
		de->adate = de->cdate = de->mdate = (1 << 5) + 1;
		de->atime = de->ctime = de->mtime = 0;
	} else
	{
		de->adate = de->cdate = de->mdate = (((year - 80) & 0x7f) << 9) | (month << 5) | day;
		de->atime = de->ctime = de->mtime = (hour << 11) | (minute << 5) | (second >> 1);
	}
	
	if (!have_px)
	{
		de->nlink = flags & DE_DIRECTORY ? 2 : 1;
		de->uid = de->gid = 0;
		de->mode = flags & DE_DIRECTORY ? __S_IFDIR|S_IRUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH : __S_IFREG|S_IRUSR|S_IRGRP|S_IROTH;
	}
	de->tosattr = flags & DE_DIRECTORY ? FA_SUBDIR : 0;
	if (flags & DE_EXISTENCE)
		de->tosattr |= FA_HIDDEN;
	
	if (strcmp(sname, de->truncname) == 0)
	{
		de->iindex = iindex;
		de->ass.start = extent;
		de->ass.length = size;
	}
	
	return 0;
}


static int is_rr(LOGICAL_DEV *ldp)
{
	DIRENTRY de;
	unsigned long rootdir;
	
	rootdir = ldp->rootdir;
	if (get_direntry(ldp, &rootdir, ldp->rootdir + ldp->rootdirsize, &de) == 0)
		return de.fsprivate;
	return 0;
}


static long readfile(LOGICAL_DEV *ldp, long start, long offset,
	long size, long iindex, long cnt, char *buffer)
{
	UNUSED(size);
	UNUSED(iindex);
	return DCRead(ldp, start + offset, cnt, buffer);
}


static long __get_root(LOGICAL_DEV *ldp, unsigned long lba, int count, int supplementary)
{
	long err;
	unsigned long recno;
	struct iso_directory_record root;
	
	err = ERROR;
	lba += 16; /* skip the reserved area */
	recno = lba;
	while ((count + lba) > recno)
	{
		err = DCRead(ldp, recno * ISOFS_BLOCK_SIZE, ISOFS_BLOCK_SIZE, ldp->scratch);
		if (err == E_CHNG)
			err = DCRead(ldp, recno * ISOFS_BLOCK_SIZE, ISOFS_BLOCK_SIZE, ldp->scratch);
		if (err == EMEDIA)
			return err;
		if (err == 0)
		{
			struct iso_supplementary_descriptor *desc = (struct iso_supplementary_descriptor *)ldp->scratch;
			struct hs_primary_descriptor *hs;
			
			if (desc->type == (supplementary ? ISO_VD_SUPPLEMENTARY : ISO_VD_PRIMARY))
			{
				if ((strncmp(desc->id, ISO_STANDARD_ID, 5) == 0 ||
					 strncmp(desc->id, "CD-I ", 5) == 0) &&
					(!supplementary || strncmp((const char *)desc->escape, "%/@", 3) == 0))
				{
					root = desc->root_directory_record;
					{
						struct iso_path_table path;
		
						/*
						 * FIXME: should also try type_l_path_table
						 */
						if (isonum_733(root.extent) == 0 &&
							DCRead(ldp, *((unsigned long *)(desc->type_m_path_table)) * ISOFS_BLOCK_SIZE, sizeof(path), &path) == 0 &&
							DCRead(ldp, *((unsigned long *)(path.extent)) * ISOFS_BLOCK_SIZE, sizeof(root), &root) == 0)
						{
							isonum_733(root.extent) = *((unsigned long *)(path.extent));
						}
					}
					
					if (isonum_733(root.extent) != 0)
					{
						unsigned char name_len = 32;
						ldp->totalsize = isonum_733(desc->volume_space_size);
						ldp->blocksize = isonum_721(desc->logical_block_size);
						ldp->rootdir = isonum_733(root.extent) * ldp->blocksize;
						ldp->rootdirsize = isonum_733(root.size);
						if (supplementary)
						{
							uni_tune(desc->volume_id, &name_len);
						}
						strncpy(ldp->fslabel, desc->volume_id, name_len);
						ldp->fslabel[name_len] = '\0';
						remove_trailing_blanks(ldp->fslabel);
						ldp->fsprivate = supplementary ? ISOFS_JOLIET : 0;
						if (is_rr(ldp))
							ldp->fsprivate = ISOFS_ROCKRIDGE;
						return 0;
					}
				}
			}
			
			hs = (struct hs_primary_descriptor *)ldp->scratch;
			if (hs->type == ISO_VD_PRIMARY &&
				strncmp(hs->id, HS_STANDARD_ID, 5) == 0)
			{
				struct iso_directory_record *r = &hs->root_directory_record;
				
				ldp->totalsize = isonum_733(hs->volume_space_size);
				ldp->blocksize = isonum_721(hs->logical_block_size);
				ldp->rootdir = isonum_733(r->extent) * ldp->blocksize;
				ldp->rootdirsize = isonum_733(r->size);
				ldp->fsprivate = ISOFS_HIGHSIERRA;
				strncpy(ldp->fslabel, hs->volume_id, 32);
				ldp->fslabel[32] = '\0';
				remove_trailing_blanks(ldp->fslabel);
				return 0;
			}
		}
		recno++;
	}
	if (err == 0)
		return ERROR;
	return err;
}


static long get_root(LOGICAL_DEV *ldp, unsigned long lba, int count)
{
	long err;
	
	err = __get_root(ldp, lba, count, TRUE);
	if (err != 0)
		err = __get_root(ldp, lba, count, FALSE);
	return err;
}


static long label(LOGICAL_DEV *ldp, char *str, int size, int rw)
{
	if (rw)
		return EWRPRO;
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
		return 512;
	case DP_NAMEMAX:
		if (ldp->fsprivate & ISOFS_JOLIET)
			return 64;
		if (ldp->fsprivate & ISOFS_ROCKRIDGE)
			return 128;
		return 31;
	case DP_CASE:
		if (ldp->fsprivate & ISOFS_JOLIET)
			return DP_CASEINSENS;
		if (ldp->fsprivate & ISOFS_ROCKRIDGE)
			return DP_CASESENS;
		return DP_CASECONV;
	case DP_ATOMIC:
		return 0;
	case DP_TRUNC:
		return DP_NOTRUNC;
	case DP_MAXLINKS:
		return 1;
	case DP_MODEATTR:
		/* FA_VOLUME is handled by kernel */
		return DP_FT_REG|DP_FT_DIR|FA_VOLUME|FA_READONLY|FA_HIDDEN;
	}
	return EINVFN;
}


FILESYSTEM const isofs = {
	get_root,
	get_direntry,
	readfile,
	label,
	pathconf
};
