#include "wdlgmain.h"

#define strlen mystrlen

#undef Mfree
#define	Mfree(addr) Mfree(addr)

#define MAX_POPUP_LINES 20

struct my_popup_init_args {
	const char **names;
	WORD num_names;
	WORD nlines;
	WORD spaces;
	WORD selected;
	char *strings[MAX_POPUP_LINES];
};

static WORD __CDECL draw_scroll(PARMBLK *pb);

static WORD const first_scroll_data[] = { 0x0000, 0x0100, 0x0380, 0x07c0, 0x0fe0, 0x1ff0, 0x3ff8, 0x0000 };
static WORD const last_scroll_data[] = { 0x0000, 0x3ff8, 0x1ff0, 0x0fe0, 0x07c0, 0x0380, 0x0100, 0x0000 };
static BITBLK const first_scroll_parm = { first_scroll_data, 2, 8, 0, 0, BLACK };
static BITBLK const last_scroll_parm = { last_scroll_data, 2, 8, 0, 0, BLACK };
static USERBLK first_scroll_user = { draw_scroll, (LONG)&first_scroll_parm };
static USERBLK last_scroll_user = { draw_scroll, (LONG)&last_scroll_parm };

static WORD run_popup(GRECT *gr, const char **names, WORD num_names, WORD spaces, WORD selected);
static void __CDECL my_popup_init(OBJECT *tree, WORD scrollpos, WORD nlines, void *param);


PDLG_SUB *install_sub_dialogs(OBJECT **tree_addr, const SIMPLE_SUB *subs, WORD count)
{
	PDLG_SUB *root;
	WORD i;
	PDLG_SUB *sub;
	
	root = NULL;
	for (i = 0; i < count; subs++, i++)
	{
		sub = Malloc(sizeof(*sub));
		if (sub != NULL)
		{
			sub->next = NULL;
			sub->option_flags = 0;
			sub->sub_id = subs->sub_id;
			sub->sub_icon = &tree_addr[SUBDLG_ICONS][subs->icon_index];
			if (subs->tree_index >= 0)
				sub->sub_tree = tree_addr[subs->tree_index];
			else
				sub->sub_tree = NULL;
			sub->dialog = NULL;
			sub->tree = NULL;
			sub->index_offset = 0;
			sub->reserved1 = 0;
			sub->reserved2 = 0;
			sub->init_dlg = subs->init_dlg;
			sub->do_dlg = subs->do_dlg;
			sub->reset_dlg = subs->reset_dlg;
			sub->reserved3 = 0;
			sub->reserved4 = 0;
			sub->reserved5 = 0;
			sub->reserved6 = 0;
			sub->private1 = 0;
			sub->private2 = 0;
			sub->private3 = 0;
			sub->private4 = 0;
			list_append((void **)&root, sub);
		}
	}
	return root;
}


WORD simple_popup(OBJECT *tree, WORD root, const char **names, WORD num_names, WORD selected)
{
	GRECT gr;
	
	objc_offset(tree, root, &gr.g_x, &gr.g_y);
	gr.g_w = tree[root].ob_width;
	gr.g_h = tree[root].ob_height;
	return run_popup(&gr, names, num_names, 2, selected);
}


static WORD run_popup(GRECT *gr, const char **names, WORD num_names, WORD spaces, WORD selected)
{
	WORD nlines;
	WORD i, maxlen;
	struct my_popup_init_args args;
	size_t object_size;
	OBJECT *tree;
	
	if (num_names > MAX_POPUP_LINES)
		nlines = MAX_POPUP_LINES;
	else
		nlines = num_names;
	for (i = maxlen = 0; i < num_names; i++)
	{
		LONG len = strlen(names[i]);
		if (len > maxlen)
			maxlen = (WORD)len;
	}
	maxlen += spaces + 2;
	object_size = (nlines + 1) * sizeof(OBJECT);
	tree = mmalloc(nlines * (maxlen + 1) + object_size);
	if (tree == NULL)
		return selected;
	for (i = 0; i < nlines; i++)
	{
		args.strings[i] = ((char *)tree + object_size) + i * (maxlen + 1);
	}
	maxlen = maxlen * gl_wchar;
	if (maxlen < gr->g_w)
		maxlen = gr->g_w;
	tree[ROOT].ob_next = NIL;
	/* FIXME: does not make sense at all to display popup without strings */
	if (nlines > 0)
	{
		tree[ROOT].ob_head = 1;
		tree[ROOT].ob_tail = nlines;
	} else
	{
		tree[ROOT].ob_flags |= LASTOB;
		tree[ROOT].ob_head = NIL;
		tree[ROOT].ob_tail = NIL;
	}
	tree[ROOT].ob_type = G_BOX;
	tree[ROOT].ob_flags = 0;
	tree[ROOT].ob_state = SHADOWED;
	tree[ROOT].ob_spec.index = 0xff1000L;
	tree[ROOT].ob_x = gr->g_x;
	tree[ROOT].ob_y = gr->g_y;
	tree[ROOT].ob_width = maxlen;
	tree[ROOT].ob_height = nlines * gl_hchar;
	args.names = names;
	args.num_names = num_names;
	args.nlines = nlines;
	args.spaces = spaces;
	args.selected = selected;
	
	{
		WORD scrollpos;
		if (num_names <= MAX_POPUP_LINES)
		{
			scrollpos = 0;
		} else
		{
			scrollpos = selected - MAX_POPUP_LINES / 2;
			if (scrollpos < 0)
				scrollpos = 0;
			if (scrollpos > (num_names - MAX_POPUP_LINES))
				scrollpos = num_names - MAX_POPUP_LINES;
		}
		if (selected < 0 || selected >= num_names)
			selected = 0;
		
		my_popup_init(tree, scrollpos, num_names, &args);
		tree[ROOT].ob_y -= (selected - scrollpos) * gl_hchar;
		
		selected = mt_xfrm_popup(tree, 0, 0, 1, nlines, num_names, (void (*)(struct POPUP_INIT_args))my_popup_init, &args, &scrollpos, NULL);
		if (selected > 0)
		{
			selected -= 1;
			selected += scrollpos;
		} else
		{
			selected = NIL;
		}
	}
	
	Mfree(tree);
	
	return selected;
}


static void __CDECL my_popup_init(OBJECT *tree, WORD scrollpos, WORD nlines, void *param)
{
	struct my_popup_init_args *args = (struct my_popup_init_args *)param;
	WORD count = args->nlines;
	OBJECT *obj;
	WORD i;
	char *dst;
	WORD j;
	
	obj = &tree[1];
	for (i = 1; i <= count; obj++, i++)
	{
		dst = args->strings[i - 1];
		if (i < count)
			obj->ob_next = i + 1;
		else
			obj->ob_next = ROOT;
		obj->ob_head = NIL;
		obj->ob_tail = NIL;
		obj->ob_type = G_STRING;
		obj->ob_flags = SELECTABLE;
		if (i == count)
			obj->ob_flags |= LASTOB;
		obj->ob_state = NORMAL;
		if ((i + scrollpos - 1) == args->selected)
			obj->ob_state |= CHECKED;
		obj->ob_spec.free_string = dst;
		obj->ob_x = 0;
		obj->ob_y = (i - 1) * gl_hchar;
		obj->ob_width = tree[ROOT].ob_width;
		obj->ob_height = gl_hchar;
		for (j = 0; j < args->spaces; j++)
			*dst++ = ' ';
		vstrcpy(dst, args->names[scrollpos + i - 1]);
	}
	if (args->num_names > MAX_POPUP_LINES)
	{
		if ((nlines - MAX_POPUP_LINES) > scrollpos)
		{
			obj = &tree[MAX_POPUP_LINES];
			obj->ob_type = G_USERDEF;
			obj->ob_state &= ~CHECKED;
			obj->ob_spec.userblk = &last_scroll_user;
		}
		if (scrollpos > 0)
		{
			obj = &tree[1];
			obj->ob_type = G_USERDEF;
			obj->ob_state &= ~CHECKED;
			obj->ob_spec.userblk = &first_scroll_user;
		}
	}
}



static WORD __CDECL draw_scroll(PARMBLK *pb)
{
	MFDB src;
	MFDB dst;
	GRECT clip;
	WORD pxy[8];
	WORD colors[2];
	BITBLK *bit;
	
	clip = *((GRECT *)&pb->pb_xc);
	clip.g_w += clip.g_x - 1;
	clip.g_h += clip.g_y - 1;
	vs_clip(vdi_handle, 1, &clip.g_x);
	bit = (BITBLK *)pb->pb_parm;
	src.fd_addr = bit->bi_pdata;
	src.fd_w = bit->bi_wb << 3;
	src.fd_h = bit->bi_hl;
	src.fd_wdwidth = bit->bi_wb / 2;
	src.fd_stand = FALSE;
	src.fd_nplanes = 1;
	src.fd_r1 = 0;
	src.fd_r2 = 0;
	src.fd_r3 = 0;
	dst.fd_addr = 0;
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = src.fd_w - 1;
	pxy[3] = src.fd_h - 1;
	pxy[4] = pb->pb_x + (pb->pb_w - src.fd_w) / 2;
	pxy[5] = pb->pb_y + (pb->pb_h - src.fd_h) / 2;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];
	colors[0] = BLACK;
	colors[1] = WHITE;
	vrt_cpyfm(vdi_handle, MD_REPLACE, pxy, &src, &dst, colors);
	return pb->pb_currstate;
}


