#include <portab.h>
#define wdlg_close wdlg_close_ex
#include <aes.h>
#define __GRECT
#define __MOBLK
#define __PORTAES_H__
#define _WORD WORD
#define _LONG LONG
#define _VOID void
#define _CDECL cdecl
#define EXTERN_C_BEG
#define EXTERN_C_END
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#undef wdlg_close
_WORD wdlg_close(DIALOG *dialog);
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"


#define FL3DBAK 0x400
#ifndef NIL
# define NIL (-1)
#endif
WORD form_popup(OBJECT *tree, WORD x, WORD y);



WORD simple_popup(OBJECT *tree, WORD obj_index, const char*const *names, WORD num_names, WORD selected)
{
	OBJECT *obj;
	WORD i;
	WORD maxlen;
	OBJECT *newtree;
	
	obj = &tree[obj_index];
	for (i = maxlen = 0; i < num_names; i++)
	{
		long len = strlen(names[i]);
		if (len > maxlen)
			maxlen = (WORD)len;
	}
	newtree = Malloc((num_names * 2 + 1) * sizeof(OBJECT));
	if (newtree != NULL)
	{
		OBJECT *o;
		WORD y;
		WORD sel_y;
		
		maxlen += 4;
		maxlen *= gl_wchar;
		if (maxlen < obj->ob_width)
			maxlen = obj->ob_width;
		o = newtree;
		o->ob_next = NIL;
		o->ob_type = G_BOX;
		o->ob_state = SHADOWED;
		o->ob_spec.index = 0xff1000L;
		o->ob_flags = FL3DBAK;
		if (num_names > 0)
		{
			o->ob_head = 1;
			o->ob_tail = (num_names * 2) - 1;
		} else
		{
			o->ob_flags += LASTOB;
			o->ob_head = o->ob_tail = NIL;
		}
		o->ob_width = maxlen;
		o->ob_height = num_names * gl_hchar;
		y = 0;
		sel_y = -obj->ob_height;
		for (i = 1; i <= num_names; i++)
		{
			o++;
			if (i < num_names)
				o->ob_next = (i * 2) + 1;
			else
				o->ob_next = ROOT;
			o->ob_head = o->ob_tail = i * 2;
			o->ob_flags = FL3DBAK|SELECTABLE;
			o->ob_type = G_IBOX;
			o->ob_spec.index = 0;
			o->ob_state = NORMAL;
			o->ob_width = maxlen;
			o->ob_height = gl_hchar;
			o->ob_x = 0;
			o->ob_y = y;
			if ((selected + 1) == i)
			{
				sel_y = y;
				o->ob_state += CHECKED;
			}
			o++;
			o->ob_next = (i * 2) - 1;
			o->ob_head = o->ob_tail = NIL;
			o->ob_flags = NONE;
			if (i == num_names)
				o->ob_flags += LASTOB;
			o->ob_type = G_STRING;
			o->ob_spec.free_string = (char *)names[i - 1];
			o->ob_state = NORMAL;
			o->ob_width = 0;
			o->ob_height = gl_hchar;
			o->ob_x = gl_wchar * 2;
			o->ob_y = 0;
			y += gl_hchar;
		}
		objc_offset(tree, obj_index, &newtree[ROOT].ob_x, &newtree[ROOT].ob_y);
		newtree[ROOT].ob_y -= sel_y;
		selected = form_popup(newtree, 0, 0);
		if (selected > 0)
		{
			selected -= 1;
			selected /= 2;
		} else
		{
			selected = -1;
		}
		Mfree(newtree);
	}
	return selected;
}


WORD form_popup(OBJECT *tree, WORD x, WORD y)
{
	static AESPB aespb = { _GemParBlk.contrl, _GemParBlk.global, _GemParBlk.intin, _GemParBlk.intout, (void *)_GemParBlk.addrin, (void *)_GemParBlk.addrout };
	
	_GemParBlk.intin[0] = x;
	_GemParBlk.intin[1] = y;
	_GemParBlk.addrin[0] = tree;
	_GemParBlk.contrl[0] = 135;
	_GemParBlk.contrl[1] = 2;
	_GemParBlk.contrl[3] = 1;
	_crystal(&aespb);
	return _GemParBlk.intout[0];
}
