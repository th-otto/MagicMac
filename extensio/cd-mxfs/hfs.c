#include <string.h>
#include <ctype.h>
#include <tos.h>
#include <time.h>
#include <toserror.h>
#include "cdfs.h"
#include "metados.h"
#include "libcdfs.h"
#include "hfs.h"

#define RSRC_FLAG 0x80000000UL

#define be16_to_cpu(x) x
#define cpu_to_be16(x) x
#define be32_to_cpu(x) x
#define cpu_to_be32(x) x

#define hfs_u_to_mtime(sec) (be32_to_cpu(sec) + 0x83DA4F80UL)

static unsigned char const transpose[128] = {
	0x8E, 0x8F, 0x80, 0x90, 0xA5, 0x99, 0x9A, 0xA0,
	0x85, 0x83, 0x84, 0xB0, 0x86, 0x87, 0x82, 0x8A,
	0x88, 0x89, 0xA1, 0x8D, 0x8C, 0x8B, 0xA4, 0xA2,
	0x95, 0x93, 0x94, 0xB1, 0xA3, 0x97, 0x96, 0x81,
	0xBB, 0xF8, 0x9B, 0x9C, 0xDD, 0xF9, 0xBC, 0x9E,
	0xBE, 0xBD, 0xBF, 0xBA, 0xB9, 0xC2, 0x93, 0xB2,
	0xDF, 0xF1, 0xF3, 0xF2, 0x9D, 0xE6, 0xC2, 0xE4,
	0xC2, 0xE3, 0xF4, 0xC2, 0xC2, 0xEA, 0x91, 0xB3,
	0xA8, 0xAD, 0xAB, 0xFB, 0x9F, 0xF7, 0x7F, 0xAE,
	0xAF, 0xC2, 0x20, 0xB6, 0xB7, 0xB8, 0xB5, 0xB4,
	0x2D, 0xFF, 0x22, 0x22, 0x60, 0x27, 0xF6, 0xC2,
	0x98, 0x98, 0x2F, 0xC2, 0x3C, 0x3E, 0xC2, 0xC2,
	0xBB, 0x2E, 0x2C, 0x22, 0xC2, 0x41, 0x45, 0x41,
	0x45, 0x45, 0x49, 0x49, 0x49, 0x49, 0x4F, 0x4F,
	0x0E, 0x4F, 0x55, 0x55, 0x55, 0xC2, 0x5E, 0x7E,
	0xFF, 0xC2, 0xC2, 0xF8, 0x2C, 0xB9, 0xC2, 0xC2
};

struct hfs_private {
	hfs_bnode_desc node;
#define NODE_OFFSETS 249 /* (HFS_BLOCKSZ - sizeof(hfs_bnode_desc)) / 2 */
	hfsu16_t offsets[NODE_OFFSETS];
	
};
#define HFS_PRIVATE(ldp) ((struct hfs_private *)(ldp->scratch))


static long get_record_from_node(LOGICAL_DEV *ldp, unsigned short first_block, short num_blocks, hfs_bnode_desc *node, void *buf, unsigned long bufsize);



static void mac2atari(char *str)
{
	while (*str)
	{
		if (*str & 0x80)
			*str = transpose[(unsigned char)*str & 0x7f];
		str++;
	}
}


static void dir2direntry(hfs_cat_key *key, CatDataRec *rec, DIRENTRY *de, long ino)
{
	int isexec;
	union {
		DOSTIME d;
		long l;
	} t;
	
	isexec = 0;
	memset(de, 0, sizeof(*de));
	strncpy(de->longname, &key->CName[1], (unsigned char)key->CName[0]);
	de->longname[(unsigned char)key->CName[0]] = '\0';
	mac2atari(de->longname);
	de->iindex = ino;
	if (rec->cdrType == HFS_CDR_DIR)
	{
		de->tosattr = FA_SUBDIR;
		if (be32_to_cpu(rec->u.dir.BkDat) < be32_to_cpu(rec->u.dir.MdDat))
			de->tosattr |= FA_ARCHIVE;
		de->pri.start = be32_to_cpu(rec->u.dir.DirID);
		de->pri.length = be16_to_cpu(rec->u.dir.Val);
		t.l = DMDosTime(hfs_u_to_mtime(rec->u.dir.MdDat));
		de->adate = de->cdate = de->mdate = t.d.date;
		de->atime = de->ctime = de->mtime = t.d.time;
		de->nlink = 2;
		isexec = 1;
	} else if (rec->cdrType == HFS_CDR_FIL)
	{
		de->pri.start = be32_to_cpu(rec->u.fil.FlNum);
		de->ass.start = be32_to_cpu(rec->u.fil.FlNum) | RSRC_FLAG;
		de->pri.length = be32_to_cpu(rec->u.fil.LgLen);
		de->ass.length = be32_to_cpu(rec->u.fil.RLgLen);
		if (be32_to_cpu(rec->u.fil.BkDat) < be32_to_cpu(rec->u.fil.MdDat))
			de->tosattr |= FA_ARCHIVE;
		t.l = DMDosTime(hfs_u_to_mtime(rec->u.fil.MdDat));
		de->adate = de->cdate = de->mdate = t.d.date;
		de->atime = de->ctime = de->mtime = t.d.time;
		de->nlink = 1;
		de->type = be32_to_cpu(rec->u.fil.UsrWds.fdType);
		de->creator = be32_to_cpu(rec->u.fil.UsrWds.fdCreator);
		if (de->type == 0x4150504cL)
			isexec = 1;
		if (rec->u.fil.UsrWds.fdFlags & cpu_to_be16(HFS_FLG_INVISIBLE))
			de->tosattr |= FA_HIDDEN;
	} else
	{
		de->tosattr = FA_SUBDIR;
		de->pri.start = be32_to_cpu(rec->u.dthd.ParID);
		de->nlink = 2;
		strcpy(de->longname, "..");
	}
	/* BUG: should not include writable */
	de->mode = isexec ? S_IRWXU|S_IRWXG|S_IRWXO : S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH;
	de->mode |= de->tosattr & FA_SUBDIR ? __S_IFDIR : __S_IFREG;
	DKTosify(de->truncname, de->longname);
}


static CatDataRec *catalog_record(hfs_cat_key *key)
{
	char *p = (char *)key;
	int len = key->key_len + 1;
	if (len & 1)
		len++;
	return (CatDataRec *)(p + len);
}


static int get_file_seg(LOGICAL_DEV *ldp, long iindex, int rsrc_flag, long addr, unsigned long *start, unsigned long *extstart, unsigned long *extlen)
{
	long block;
	hfs_extent *ext;
	int i;
	unsigned long numblks;
	unsigned short totalblks;
	
	block = addr / ldp->p.hfs.blocksize;
	totalblks = 0;
	if (iindex == 0 || iindex == 1)
	{
		ext = ldp->p.hfs.catalogextents;
		if (rsrc_flag)
			return FALSE;
		if (iindex == 1)
			ext = ldp->p.hfs.overflowextents;
	} else
	{
		struct {
			hfs_cat_key key;
			CatDataRec rec;
			short pad;
		} buf;
		hfs_cat_key *key;
		hfs_bnode_desc node;
		CatDataRec *rec;
		
		key = &buf.key;
		if (get_record_from_node(ldp, ((hfs_extent *)&iindex)->block, ((hfs_extent *)&iindex)->count, &node, &buf, sizeof(buf)) != 0)
			return FALSE;
		rec = catalog_record(key);
		ext = rec->u.fil.ExtRec;
		if (rsrc_flag == 1) /* FIXME */
			ext = rec->u.fil.RExtRec;
	}
	
	for (i = 0; i < 3; i++)
	{
		numblks = ext[i].count;
		if (numblks != 0 && (numblks + totalblks) > block)
		{
			*start = ldp->p.hfs.allocstart * HFS_BLOCKSZ;
			*start += ext[i].block * ldp->p.hfs.blocksize;
			*extstart = totalblks * ldp->p.hfs.blocksize;
			*extlen = numblks * ldp->p.hfs.blocksize;
			return TRUE;
		}
		totalblks += ext[i].count;
	}
	
	Bconout(2, 7); /* WTF */
	
	return FALSE;
}


static long dc_read(LOGICAL_DEV *ldp, unsigned long adr, unsigned long cnt, void *buffer)
{
	return DCRead(ldp, ldp->p.hfs.partoffset + adr, cnt, buffer); /* FIXME: optimize */
}


static long file_read(LOGICAL_DEV *ldp, long iindex, int rsrc_flag, long offset, long size, char *buffer)
{
	unsigned long start;
	unsigned long extstart;
	unsigned long extlen;
	unsigned long toread;
	unsigned long addr;
	long err;
	
	while (size != 0)
	{
		toread = size;
		if (get_file_seg(ldp, iindex, rsrc_flag, offset, &start, &extstart, &extlen) == FALSE)
			return ERANGE;
		addr = offset - extstart + start;
		if ((extlen - (offset - extstart)) < toread)
			toread = (extlen - (offset - extstart));
		err = dc_read(ldp, addr, toread, buffer);
		if (err != 0)
			return err;
		size -= toread;
		buffer += toread;
	}
	return 0;
}


static long dc_cat_read(LOGICAL_DEV *ldp, long offset, long size, void *buffer)
{
	return file_read(ldp, 0, 0, offset, size, buffer);
}


static long get_record_from_node(LOGICAL_DEV *ldp, unsigned short first_block, short num_blocks, hfs_bnode_desc *node, void *buf, unsigned long bufsize)
{
	long err;
	hfsu16_t *off;
	unsigned short size;
	
	off = &HFS_PRIVATE(ldp)->offsets[NODE_OFFSETS - 1];
	err = dc_cat_read(ldp, (unsigned long)first_block * HFS_BLOCKSZ, HFS_BLOCKSZ, &HFS_PRIVATE(ldp)->node);
	if (err != 0)
		return err;
	*node = HFS_PRIVATE(ldp)->node;
	if (num_blocks >= (short)node->num_recs)
		return EFILNF;
	first_block = off[-num_blocks];
	size = off[-num_blocks - 1] - first_block;
	if (size > bufsize)
		return ERANGE;
	memcpy(buf, &((const char *)&HFS_PRIVATE(ldp)->node)[first_block], size);
	return 0;
}


static long next_rec(hfs_bnode_desc *node, unsigned short *link, unsigned short *recno)
{
	int err; /* FIXME: should be long */
	
	++(*recno);
	if (*recno >= node->num_recs)
	{
		*recno = 0;
		*link = (unsigned short)node->next;
	}
	if ((err = *link) != 0) /* FIXME */
		err = 0;
	else
		err = (int)EPTHNF;
	return err;
}

struct xbuf {
	union {
		hfs_bnode_desc node;
		hfs_ext_key key;
	} u;
	hfs_ext_key key;
	char res2[18];
	unsigned short first2;
	char res3[100];
};

static long find_leaf_node(LOGICAL_DEV *ldp, unsigned long cnid)
{
	long err;
	hfs_bnode_desc current;
	unsigned short first_block;
	unsigned short recno;
	struct xbuf buf;
	struct xbuf *p, *p2;
	unsigned short d4;
	
	p2 = &buf;
	p = p2;
	err = dc_cat_read(ldp, 0, 44, p);
	if (err != 0)
		return err;
	if (p2->u.node.type != HFS_NODE_HEADER)
		return ERROR;
	first_block = (unsigned short)p2->key.FNum;
	recno = 0;
	err = get_record_from_node(ldp, first_block, recno, &current, &buf, sizeof(buf));
	if (err != 0)
		return err;
	d4 = p->first2;
	while (current.type == HFS_NODE_INDEX)
	{
		if (p->u.key.FNum >= cnid || next_rec(&current, &first_block, &recno) != 0)
		{
			first_block = d4;
			recno = 0;
		}
		d4 = p->first2;
		err = get_record_from_node(ldp, first_block, recno, &current, &buf, sizeof(buf));
		if (err != 0)
			return err;
	}
	if (current.type != HFS_NODE_LEAF)
		return EFILNF;
	return first_block;
}


static long get_direntry(LOGICAL_DEV *ldp, unsigned long *start, unsigned long dirend, DIRENTRY *de)
{
	unsigned short first_block;
	unsigned short recno;
	hfs_bnode_desc current;
	struct xbuf buf;
	struct xbuf *p;
	unsigned long block;
	long err;
	CatDataRec *rec;
	int done;
	long iindex;
	
	UNUSED(dirend);
	
	p = &buf;
	if (*start < 0x10000UL)
	{
		block = *start;
		err = find_leaf_node(ldp, block);
		if (err < 0)
			return err;
		first_block = (unsigned short)err;
		recno = 0;
		err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
		if (err != 0)
			return err;
		while (p->u.key.FNum < block)
		{
			err = next_rec(&current, &first_block, &recno);
			if (err != 0)
				return err;
			err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
			if (err != 0)
				return err;
		}
		*start = (unsigned long)first_block << 16;
		*start += recno;
		{
			unsigned short parid;
			
			while (p->u.key.FNum == block)
			{
				rec = catalog_record((hfs_cat_key *)p);
				if (rec->cdrType == HFS_CDR_THD)
				{
					recno = 0;
					parid = (unsigned short)rec->u.fthd.ParID;
					err = find_leaf_node(ldp, rec->u.fthd.ParID);
					if (err < 0)
						return err;
					first_block = (unsigned short)err;
					break;
				}
				err = next_rec(&current, &first_block, &recno);
				if (err != 0)
					return err;
				err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
				if (err != 0)
					return err;
			}
	
			if (p->u.key.FNum != block)
			{
				*start = -1;
				return EPTHNF;
			}
	
			err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
			if (err != 0)
				return err;
			/* BUG: parid may be used unitialized */
			while (p->u.key.FNum < parid)
			{
				err = next_rec(&current, &first_block, &recno);
				if (err != 0)
					return err;
				err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
				if (err != 0)
					return err;
			}
		}
		
		err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
		if (err != 0)
			return err;
		{
			unsigned long fnum;
			
			fnum = p->u.key.FNum;
			while (p->u.key.FNum == fnum)
			{
				rec = catalog_record((hfs_cat_key *)p);
				if (rec->cdrType == HFS_CDR_DIR && rec->u.dir.DirID == block)
				{
					/* BUG: does not set length field */
					strcpy(&((hfs_cat_key *)p)->CName[1], ".");
					/* BUG: missing cast for first_block */
					dir2direntry((hfs_cat_key *)p, rec, de, (first_block << 16) != 0 || recno != 0 ? 1 : 0);
					return 0;
				}
				err = next_rec(&current, &first_block, &recno);
				if (err != 0)
					return err;
				err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
				if (err != 0)
					return err;
			}
		}
	}

	first_block = ((hfs_extent *)start)->block;
	recno = ((hfs_extent *)start)->count;
	do
	{
		done = 0;
		iindex = *start;
		if (*start == -1)
			return ENMFIL;
		err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
		if (err != 0)
			return err;
		rec = catalog_record((hfs_cat_key *)p);
		next_rec(&current, &first_block, &recno); /* BUG: no error check */
		*start = (unsigned long)first_block << 16;
		*start |= recno;
		if (first_block == 0)
			*start = -1;
		
		switch (rec->cdrType)
		{
		case HFS_CDR_THD:
			if (rec->u.dthd.ParID == 1)
				break;
			/* fall through */
		case HFS_CDR_DIR:
		case HFS_CDR_FIL:
			dir2direntry((hfs_cat_key *)p, rec, de, iindex);
			done = 1;
			break;
		}
		
		if (first_block != 0)
		{
			unsigned long fnum;
				
			fnum = p->u.key.FNum;
			err = get_record_from_node(ldp, first_block, recno, &current, p, sizeof(buf));
			if (err != 0)
				return err;
			if (p->u.key.FNum != fnum)
				*start = -1;
		}
	} while (done == 0);
	
	return 0;
}


static long readfile(LOGICAL_DEV *ldp, long start, long offset,
	long size, long iindex, long cnt, char *buffer)
{
	UNUSED(size);
	return file_read(ldp, iindex, start & RSRC_FLAG ? 1 : 0, offset, cnt, buffer);
}


static long get_root(LOGICAL_DEV *ldp, unsigned long lba, int count)
{
	MDB mdb;
	Block0 blk0;
	Partition part;
	long addr;
	long err;
	unsigned long blkcnt;
	int i; /* FIXME: should be unsigned */
	
	UNUSED(count);
	addr = lba * BLOCKSIZE;
	err = DCRead(ldp, addr, sizeof(blk0), &blk0);
	if (err == E_CHNG)
		err = DCRead(ldp, addr, sizeof(blk0), &blk0);
	if (err == EMEDIA || err == EINSERT || err < 0) /* FIXME: unneeded extra check for EMEDIA */
		return err;
	if (blk0.sbSig != cpu_to_be16(HFS_DRVR_DESC_MAGIC))
		return ERROR;
	ldp->blocksize = be16_to_cpu(blk0.sbBlkSize);
	if (ldp->blocksize & 0xff)
		ldp->blocksize <<= 8;
	err = DCRead(ldp, addr + HFS_PMAP_BLK * ldp->blocksize, sizeof(part), &part);
	if (err != 0)
		return ERROR;
	if (part.pmSig != cpu_to_be16(HFS_NEW_PMAP_MAGIC))
		return ERROR;
	blkcnt = be32_to_cpu(part.pmMapBlkCnt);
	for (i = 0; i < blkcnt; i++)
	{
		err = DCRead(ldp, addr + (i + HFS_PMAP_BLK) * ldp->blocksize, sizeof(part), &part);
		if (err != 0)
			return ERROR;
		if (strncmp(part.pmPartType, "Apple_HFS", 9) == 0)
		{
			ldp->totalsize = be32_to_cpu(part.pmPartBlkCnt);
			err = DCRead(ldp, addr + (be32_to_cpu(part.pmPyPartStart) + HFS_MDB_BLK) * ldp->blocksize, sizeof(mdb), &mdb);
			if (err != 0)
				return ERROR;
			if (mdb.drSigWord != cpu_to_be16(HFS_SUPER_MAGIC))
				return ERROR;
			ldp->p.hfs.partoffset = addr + ldp->blocksize * be32_to_cpu(part.pmPyPartStart);
			ldp->p.hfs.blocksize = be32_to_cpu(mdb.drAlBlkSiz);
			ldp->p.hfs.allocstart = be16_to_cpu(mdb.drAlBlSt);
			memcpy(ldp->p.hfs.catalogextents, mdb.drCTExtRec, sizeof(ldp->p.hfs.catalogextents));
			memcpy(ldp->p.hfs.overflowextents, mdb.drXTExtRec, sizeof(ldp->p.hfs.overflowextents));
			ldp->rootdirsize = -2;
			ldp->rootdir = HFS_ROOT_CNID;
			strncpy(ldp->fslabel, &mdb.drVN[1], (unsigned char)mdb.drVN[0]);
			ldp->fslabel[(unsigned char)mdb.drVN[0]] = '\0';
			mac2atari(ldp->fslabel);
			return E_OK;
		}
	}
	return ERROR;
}


static long label(LOGICAL_DEV *ldp, char *str, int size, int rw)
{
	if (rw)
		return EWRPRO;
	strncpy(str, ldp->fslabel, size);
	str[size - 1] = '\0';
	/* FIXME */
	return strlen(ldp->fslabel) >= size ? (int)ERANGE : 0;
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
	case DP_MAXLINKS:
		return 1;
	case DP_PATHMAX:
		return 512; /* BUG? should be 255 */
	case DP_NAMEMAX:
		return HFS_NAMELEN;
	case DP_ATOMIC:
		return 0;
	case DP_TRUNC:
		return DP_NOTRUNC;
	case DP_CASE:
		return DP_CASEINSENS;
	case DP_MODEATTR:
		return DP_FT_REG|DP_FT_DIR|FA_READONLY|FA_HIDDEN; /* FIXME: should include unix modes */
	}
	return EINVFN;
}


FILESYSTEM const hfs = {
	get_root,
	get_direntry,
	readfile,
	label,
	pathconf
};
