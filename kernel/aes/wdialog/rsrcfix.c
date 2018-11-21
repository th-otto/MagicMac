#include "wdlgmain.h"
#include <stddef.h>


static unsigned char const rg_type_tab[] = {
	offsetof(RSHDR, rsh_trindex) / sizeof(UWORD),  /* R_TREE */
	offsetof(RSHDR, rsh_object) / sizeof(UWORD),   /* R_OBJECT */
	offsetof(RSHDR, rsh_tedinfo) / sizeof(UWORD),  /* R_TEDINFO */
	offsetof(RSHDR, rsh_iconblk) / sizeof(UWORD),  /* R_ICONBLK */
	offsetof(RSHDR, rsh_bitblk) / sizeof(UWORD),   /* R_BITBLK */
	offsetof(RSHDR, rsh_frstr) / sizeof(UWORD),    /* R_STRING */
	offsetof(RSHDR, rsh_frimg) / sizeof(UWORD),    /* R_IMAGEDATA */
	offsetof(RSHDR, rsh_object) / sizeof(UWORD),   /* R_OBSPEC */
	offsetof(RSHDR, rsh_tedinfo) / sizeof(UWORD),  /* R_TEPTEXT */
	offsetof(RSHDR, rsh_tedinfo) / sizeof(UWORD),  /* R_TEPTMPLT */
	offsetof(RSHDR, rsh_tedinfo) / sizeof(UWORD),  /* R_TEPVALID */
	offsetof(RSHDR, rsh_iconblk) / sizeof(UWORD),  /* R_IBPMASK */
	offsetof(RSHDR, rsh_iconblk) / sizeof(UWORD),  /* R_IBPDATA */
	offsetof(RSHDR, rsh_iconblk) / sizeof(UWORD),  /* R_IBPTEXT */
	offsetof(RSHDR, rsh_bitblk) / sizeof(UWORD),   /* R_BIPDATA */
	offsetof(RSHDR, rsh_frstr) / sizeof(UWORD),    /* R_FRSTR */
	offsetof(RSHDR, rsh_frimg) / sizeof(UWORD)     /* R_FRIMG */
};

static unsigned char const rg_size_tab[] = {
	0,                /* rsh_vrsn: unused */
	sizeof(OBJECT),   /* rsh_object */
	sizeof(TEDINFO),  /* rsh_tedinfo */
	sizeof(ICONBLK),  /* rsh_iconblk */
	sizeof(BITBLK),   /* rsh_bitblk */
	sizeof(char *),   /* rsh_frstr */
	0,                /* rsh_string: unused */
	0,                /* rsh_imdata: unused */
	sizeof(BITBLK *), /* rsh_frimg */
	sizeof(OBJECT *)  /* rsh_trindex */
};

static unsigned char const rg_offset_tab[] = {
	0,                            /* R_TREE */
	0,                            /* R_OBJECT */
	0,                            /* R_TEDINFO */
	0,                            /* R_ICONBLK */
	0,                            /* R_BITBLK */
	0,                            /* R_STRING */
	offsetof(BITBLK, bi_pdata),   /* R_IMAGEDATA */
	offsetof(OBJECT, ob_spec),    /* R_OBSPEC */
	offsetof(TEDINFO, te_ptext),  /* R_TEPTEXT */
	offsetof(TEDINFO, te_ptmplt), /* R_TEPTMPLT */
	offsetof(TEDINFO, te_pvalid), /* R_TEPVALID */
	offsetof(ICONBLK, ib_pmask),  /* R_IBPMASK */
	offsetof(ICONBLK, ib_pdata),  /* R_IBPDATA */
	offsetof(ICONBLK, ib_ptext),  /* R_IBPTEXT */
	offsetof(BITBLK, bi_pdata),   /* R_BIPDATA */
	0,                            /* R_FRSTR */
	0                             /* R_FRIMG */
};


static void *get_sub(RSHDR *rscHdr, WORD idx, ULONG offset, size_t size)
{
	char *base = ((char *)rscHdr) + offset;
	base += (LONG)idx * size;
	return base;
}


#define get_sub(rscHdr, idx, offset, size) ((void *)(((UBYTE *)rscHdr) + (offset) + ((size) * (idx))))


static void *get_address(RSHDR *rscHdr, UWORD rstype, UWORD rsindex)
{
    unsigned char type;
	void *the_addr;
	
	if (rstype > R_FRIMG)
		return NULL;
	type = rg_type_tab[rstype];
	the_addr = get_sub(rscHdr, rsindex, ((const UWORD *)rscHdr)[type] + rg_offset_tab[rstype], rg_size_tab[type]);
	
	/* addresses that must be dereferenced */
	switch (rstype)
	{
	case R_TREE:
	case R_STRING:
	case R_IMAGEDATA:
		the_addr = *((void **)the_addr);
		break;
	}
	
	return the_addr;
}


static void fix_long(RSHDR *rscHdr, LONG *lptr)
{
	LONG base;

	base = *lptr;
	if (base != 0)
	{
		base += (LONG)rscHdr;
		*lptr = base;
	}
}


static void fix_nptr(RSHDR *rscHdr, WORD idx, WORD ob_type)
{
	while (idx != 0)
	{
		idx--;
		fix_long(rscHdr, (LONG *)get_address(rscHdr, ob_type, idx));
	}
}


static void fix_ptr(RSHDR *rscHdr, WORD type, WORD idx)
{
	fix_long(rscHdr, (LONG *)get_address(rscHdr, type, idx));
}


static void fix_chp(WORD *pcoord, int hor)
{
	WORD ncoord;
	WORD coord;
	
	ncoord = *pcoord & 0xff;
	ncoord *= hor ? gl_hchar : gl_wchar;

	coord = (*pcoord >> 8) & 0xff;

	if (coord > 128)
	{
		coord |= (-1 & ~0xff);
		ncoord += coord;
	} else
	{
		ncoord += (*pcoord >> 8) & 0xff;
	}
	*pcoord = ncoord;
}


static void fix_obj(OBJECT *tree, WORD obj)
{
	WORD *p;
	WORD i;
	WORD flag;
	
	flag = 0;
	i = 0;
	p = &tree[obj].ob_x;
	while (i++ < 4)
	{
		fix_chp(p++, flag);
		flag = flag ? 0 : 1;
	}
}


void _rsrc_rcfix(WORD *global, RSHDR *rscHdr)
{
	*((RSHDR **)&global[7]) = rscHdr;
	
	/* fix_treeindex(); */
	{
		UWORD count;
		OBJECT **RootTree;
	
		count = rscHdr->rsh_ntree;
	
		RootTree = (OBJECT **)get_sub(rscHdr, 0, rscHdr->rsh_trindex, sizeof(OBJECT *));
		*((OBJECT ***)&global[5]) = RootTree;
	
		while (count != 0)
		{
			count--;
			fix_long(rscHdr, (LONG *) (count * sizeof (OBJECT *) + (LONG) RootTree));
		}
	}

	/* fix_tedinfo(); */
	{
		UWORD count;
		
		count = rscHdr->rsh_nted;
	
		while (count != 0)
		{
			count--;
			fix_ptr(rscHdr, R_TEPTEXT, count);
			fix_ptr(rscHdr, R_TEPTMPLT, count);
			fix_ptr(rscHdr, R_TEPVALID, count);
		}
	}


	fix_nptr(rscHdr, rscHdr->rsh_nib, R_IBPMASK);
	fix_nptr(rscHdr, rscHdr->rsh_nib, R_IBPDATA);
	fix_nptr(rscHdr, rscHdr->rsh_nib, R_IBPTEXT);

	fix_nptr(rscHdr, rscHdr->rsh_nbb, R_BIPDATA);
	fix_nptr(rscHdr, rscHdr->rsh_nstring, R_FRSTR);
	fix_nptr(rscHdr, rscHdr->rsh_nimages, R_FRIMG);

	/* fix_object();  */
	{
		UWORD count;
		OBJECT *obj;
	
		count = rscHdr->rsh_nobs;
	
		while (count != 0)
		{
			WORD type;
	
			count--;
			obj = (OBJECT *)get_address(rscHdr, R_OBJECT, count);
			fix_obj(obj, 0);
			type = obj->ob_type & 0xFF;
			if (type != G_BOX && type != G_IBOX && type != G_BOXCHAR)
			{
				fix_long(rscHdr, (LONG *) &obj->ob_spec);
			}
		}
	}
}
