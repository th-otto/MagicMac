#ifdef __PUREC__
#include <portab.h>
#include <tos.h>
#include <aes.h>
#else
#include <gemx.h>
#include <osbind.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "extern.h"



WORD simple_popup(OBJECT *tree, WORD obj_index, const char *const *names, WORD num_names, WORD selected)
{
	OBJECT *obj;
	WORD i;
	WORD maxlen;
	OBJECT *newtree;
	
	obj = &tree[obj_index];
	for (i = maxlen = 0; i < num_names; i++)
	{
		WORD len = (WORD)strlen(names[i]);
		if (len > maxlen)
			maxlen = (WORD)len;
	}
	newtree = (OBJECT *)Malloc((num_names * 2 + 1) * sizeof(OBJECT));
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
		o->ob_state = OS_SHADOWED;
		o->ob_spec.index = 0xff1000L;
		o->ob_flags = OF_FL3DBAK;
		if (num_names > 0)
		{
			o->ob_head = 1;
			o->ob_tail = (num_names * 2) - 1;
		} else
		{
			o->ob_flags |= OF_LASTOB;
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
			o->ob_flags = OF_FL3DBAK|OF_SELECTABLE;
			o->ob_type = G_IBOX;
			o->ob_spec.index = 0;
			o->ob_state = OS_NORMAL;
			o->ob_width = maxlen;
			o->ob_height = gl_hchar;
			o->ob_x = 0;
			o->ob_y = y;
			if ((selected + 1) == i)
			{
				sel_y = y;
				o->ob_state |= OS_CHECKED;
			}
			o++;
			o->ob_next = i * 2 - 1;
			o->ob_head = o->ob_tail = NIL;
			o->ob_flags = OF_NONE;
			if (i == num_names)
				o->ob_flags |= OF_LASTOB;
			o->ob_type = G_STRING;
			o->ob_spec.free_string = (char *)names[i - 1];
			o->ob_state = OS_NORMAL;
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
			selected >>= 1;
		} else
		{
			selected = -1;
		}
		Mfree(newtree);
	}
	return selected;
}
