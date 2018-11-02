#include "wdlgmain.h"

#define strlen mystrlen


static WORD *gl_global;
static RSHDR *gl_rsc;

static void fix_treeindex(void);
static void fix_tedinfo(void);
static int fix_long(LONG *lptr);
static void *get_address(WORD type, WORD idx);
static int fix_ptr(WORD type, WORD idx);
static void fix_nptr(WORD idx, WORD ob_type);
static void fix_object(void);
static void fix_obj(OBJECT *tree, WORD obj);
static void fix_chp(WORD *pcoord, int hor);


void _rsrc_rcfix(WORD *global, RSHDR *rsc)
{
	gl_rsc = rsc;
	gl_global = global;
	*((RSHDR **)&global[7]) = rsc;
	fix_treeindex();
	fix_tedinfo();
	fix_nptr(gl_rsc->rsh_nib, R_IBPMASK);
	fix_nptr(gl_rsc->rsh_nib, R_IBPDATA);
	fix_nptr(gl_rsc->rsh_nib, R_IBPTEXT);

	fix_nptr(gl_rsc->rsh_nbb, R_BIPDATA);
	fix_nptr(gl_rsc->rsh_nstring, R_FRSTR);
	fix_nptr(gl_rsc->rsh_nimages, R_FRIMG);
	fix_object();
}


static void *get_sub(WORD idx, ULONG offset, size_t size)
{
	char *base = ((char *)gl_rsc) + offset;
	base += (LONG)idx * size;
	return base;
}


static void fix_treeindex(void)
{
	UWORD count;
	OBJECT **RootTree;

	count = gl_rsc->rsh_ntree;

	RootTree = (OBJECT **)get_sub(R_TREE, gl_rsc->rsh_trindex, sizeof(OBJECT *));
	*((OBJECT ***)&gl_global[5]) = RootTree;

	while (count != 0)
	{
		count--;
		fix_long((LONG *) (count * sizeof (OBJECT *) + (LONG) RootTree));
	}
}


static void fix_tedinfo(void)
{
	UWORD count;
	TEDINFO *ted;
	
	count = gl_rsc->rsh_nted;

	while (count != 0)
	{
		count--;
		ted = get_address(R_TEDINFO, count);
		/* BUG: using strlen here is wrong */
		if (fix_ptr(R_TEPTEXT, count))
			ted->te_txtlen = (WORD)strlen(ted->te_ptext) + 1;
		if (fix_ptr(R_TEPTMPLT, count))
			ted->te_tmplen = (WORD)strlen(ted->te_ptmplt) + 1;
		if (fix_ptr(R_TEPVALID, count))
			;
	}
}


static void fix_nptr(WORD idx, WORD ob_type)
{
	while (idx != 0)
	{
		idx--;
		fix_long((_LONG *)get_address(ob_type, idx));
	}
}


static int fix_ptr(WORD type, WORD idx)
{
	_WORD _idx = idx;
	_idx = _idx;
	return fix_long((LONG *)get_address(type, _idx));
}


static int fix_long(LONG *lptr)
{
	LONG base;

	base = *lptr;
	if (base == 0)
		return FALSE;
	base += (LONG)gl_rsc;
	*lptr = base;
	return TRUE;
}


static void *get_address(WORD type, WORD idx)
{
	void *the_addr = NULL;
	
	switch (type)
	{
	case R_TREE:
		{
			OBJECT **ptr = (OBJECT **)get_sub(0, gl_rsc->rsh_trindex, sizeof(OBJECT *));
			the_addr = ptr[idx];
		}
		break;

	case R_OBJECT:
		the_addr = get_sub(idx, gl_rsc->rsh_object, sizeof (OBJECT));
		break;

	case R_TEDINFO:
	case R_TEPTEXT:
		the_addr = get_sub(idx, gl_rsc->rsh_tedinfo, sizeof (TEDINFO));
		break;

	case R_ICONBLK:
	case R_IBPMASK:
		the_addr = get_sub(idx, gl_rsc->rsh_iconblk, sizeof (ICONBLK));
		break;

	case R_BITBLK:
	case R_BIPDATA:
		the_addr = get_sub(idx, gl_rsc->rsh_bitblk, sizeof (BITBLK));
		break;

	case R_OBSPEC:
		{
			OBJECT *ptr = (OBJECT *)get_sub(idx, gl_rsc->rsh_object, sizeof(OBJECT));
			
			the_addr = &ptr->ob_spec;
		}
		break;

	case R_TEPTMPLT:
	case R_TEPVALID:
		{
			TEDINFO *tedinfo = get_sub(idx, gl_rsc->rsh_tedinfo, sizeof(TEDINFO));
			if (type == R_TEPVALID)
				the_addr = &tedinfo->te_pvalid;
			else
				the_addr = &tedinfo->te_ptmplt;
		}
		break;

	case R_IBPDATA:
	case R_IBPTEXT:
		{
			ICONBLK *iconblk = (ICONBLK *)get_sub(idx, gl_rsc->rsh_iconblk, sizeof (ICONBLK));
			if (type == R_IBPDATA)
				the_addr = &iconblk->ib_pdata;
			else
				the_addr = &iconblk->ib_ptext;
		}
		break;

	case R_IMAGEDATA:
		the_addr = get_sub(idx, gl_rsc->rsh_frimg, sizeof(_UBYTE *));
		if (the_addr)
			the_addr = *((void **)the_addr);
		break;

	case R_FRIMG:
		the_addr = get_sub(idx, gl_rsc->rsh_frimg, sizeof (_UBYTE *));
		break;

	case R_STRING:
		the_addr = get_sub(idx, gl_rsc->rsh_frstr, sizeof(_UBYTE *));
		if (the_addr)
			the_addr = *((_VOID **)the_addr);
		break;

	case R_FRSTR:
		the_addr = get_sub(idx, gl_rsc->rsh_frstr, sizeof (_UBYTE *));
		break;

	default:
		break;
	}

	return the_addr;
}


static void fix_object(void)
{
	UWORD count;
	OBJECT *obj;

	count = gl_rsc->rsh_nobs;

	while (count != 0)
	{
		WORD type;

		count--;
		obj = (OBJECT *)get_address(R_OBJECT, count);
		fix_obj(obj, 0);
		type = obj->ob_type & 0xFF;
		if (type != G_BOX && type != G_IBOX && type != G_BOXCHAR)
		{
			fix_long((_LONG *) &obj->ob_spec);
		}
	}
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
