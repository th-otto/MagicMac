#include <string.h>
#include <ctype.h>
#include <tos.h>
#include "cdfs.h"
#include "libcdfs.h"
#include "metados.h"

int DCSize = 0;
CACHEENTRY *DCCache = 0;


/* clear all cache entries for the logical device */
void DCClear(LOGICAL_DEV *ldp)
{
	int i;
	
	for (i = 0; i < DCSize; i++)
	{
		if (DCCache[i].device == ldp->metadevice)
			DCCache[i].blkno = -1;
	}
}


static int get_free_buffer(void)
{
	int i;
	unsigned long oldest;
	unsigned long current;
	int last;
	unsigned long timestamp;
	
	current = get_hz();
	last = -1;
	oldest = 0;
	for (i = 0; i < DCSize; i++)
	{
		timestamp = current - DCCache[i].timestamp;
		if (DCCache[i].blkno == -1)
			return i;
		if (last < 0 || timestamp > oldest)
		{
			last = i;
			oldest = timestamp;
		}
	}
	return last;
}


static int locate_block_in_buffer(LOGICAL_DEV *ldp, unsigned long blockno)
{
	int i;

	for (i = 0; i < DCSize; i++)
	{
		if (ldp->metadevice == DCCache[i].device && DCCache[i].blkno == blockno)
		{
			DCCache[i].timestamp = get_hz();
			return i;
		}
	}
	return -1;
}


static long get_block(LOGICAL_DEV *ldp, unsigned long blockno)
{
	long err;
	int entry;
	
	entry = locate_block_in_buffer(ldp, blockno);
	if (entry >= 0)
		return entry;
	entry = get_free_buffer();
	err = Metaread(ldp->metadevice, DCCache[entry].data, blockno, 1);
	if (err != 0)
		return err;
	DCCache[entry].blkno = blockno;
	DCCache[entry].device = ldp->metadevice;
	ldp->mediatime = (DCCache[entry].timestamp = get_hz()) + MEDIADELAY;
	return entry;
}


/* read from a logical device */
long DCRead(LOGICAL_DEV *ldp, unsigned long adr, unsigned long cnt, void *buffer)
{
	char *p;
	unsigned long blockno;
	unsigned long offset;
	unsigned long toread;
	long err;
	
	p = buffer;
	while (cnt != 0)
	{
		unsigned short blks;
		
		blockno = adr / BLOCKSIZE;
		offset = adr & (BLOCKSIZE - 1);
		toread = BLOCKSIZE - offset;
		if (toread > cnt)
			toread = cnt;
		if (offset == 0 && cnt >= (BLOCKSIZE * 2) && locate_block_in_buffer(ldp, blockno) < 0)
		{
			blks = (unsigned short)(cnt / BLOCKSIZE);
			toread = blks * BLOCKSIZE;
			err = Metaread(ldp->metadevice, p, blockno, blks);
			if (err < 0)
				return err;
		} else
		{
			err = get_block(ldp, blockno);
			if (err < 0)
				return err;
			memcpy(p, DCCache[err].data + offset, toread);
		}
		p += toread;
		adr += toread;
		cnt -= toread;
	}
	return 0;
}
