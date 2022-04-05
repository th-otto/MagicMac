#include "applin.h"
#include "appline.h"

#define MAX_APPS 30

#define WIND_DATA 0x935
/* flags of our window: none */
#define WFKIND 0

#define APP_NAME_MAX 8

_WORD last_objs = -1;
_WORD last_barowner = -10;

extern _WORD msgbuff[8];
char *inffile;
GRECT desk;
OBJECT *appline_tree;
_WORD whdl;
int flag_vertical;
_WORD appids[MAX_APPS];
_WORD button_len;
char *showmem;
_WORD frozen_mask;
_WORD nowindow_mask;
char firstapp[APP_NAME_MAX + 2];
unsigned long lastmem;
_WORD wind_xoff;
_WORD selection;
_WORD avserver;
int nobackwind;
OBJECT *app_popup;
OBJECT *main_popup;

#define gl_apid global[2]


#define AV_PROTOKOLL    0x4700
#define VA_START        0x4711
#define AV_ACCWINDOPEN  0x4724
#define AV_ACCWINDCLOSE 0x4726
#define AV_EXIT         0x4736
#define AV_SENDKEY      0x4710
#define VA_DRAGACCWND   0x4725

#define SM_M_SPECIAL 0x65

#define BINEXACT 1


static void load_inffile(void)
{
	char pathname[PATH_MAX + 6];
	register int fd;
	register long size;
	register char *buf;
	
	buf = pathname;
	strcpy(buf, "appline.inf");
	shel_find(buf);
	fd = Fopen(buf, 0);
	if (fd >= 0)
	{
		size = Fseek(0L, fd, SEEK_END);
		Fseek(0L, fd, SEEK_SET);
		buf = (void *)Malloc(size + 2);
		if (buf != NULL)
		{
			Fread(fd, size, buf);
			inffile = buf;
			buf[size] = '\0';
			buf[size + 1] = '\0';

			while (*buf != '\0')
			{
				if (*buf == '\r')
				{
					*buf++ = '\0';
					*buf = ' ';
				} else if (*buf == '\n')
				{
					*buf = '\0';
				}
				buf++;
			}
		}
		Fclose(fd);
	}
}


static const char *inf_get(const char *key)
{
	register char *buf = inffile;
	int len;
	register char c;
	
	if (buf != NULL)
	{
		len = (int)strlen(key);
		while (*buf != '\0')
		{
			if (*buf == ' ')
				buf++;
			if (!(c = buf[len]) || c == ' ')
			{
				if (strncmp(buf, key, len) == 0)
					/* BUG: may return start of next line */
					return buf + len + 1;
			}
			while (*buf++ != '\0')
				;
		}
	}
	return NULL;
}


static void redraw(_WORD *message)
{
	GRECT gr;
	GRECT work;
	char unused[6];
	register _WORD *pmessage = message;
	register GRECT *pwork = &work;
	register GRECT *pgr = &gr;
	
	wind_update(BEG_UPDATE);
	rc_intersect(&desk, (GRECT *)&pmessage[4]);
	wind_get(whdl, WF_FIRSTXYWH, pgr);
	while (pgr->g_w != 0 && pgr->g_h != 0)
	{
		pwork->g_x = pmessage[4] - 1;
		pwork->g_y = pmessage[5] - 1;
		pwork->g_w = pmessage[6] + 1;
		pwork->g_h = pmessage[7] + 1;
		if (rc_intersect(pgr, pwork))
			objc_draw(appline_tree, ROOT, MAX_DEPTH, pwork->g_x, pwork->g_y, pwork->g_w, pwork->g_h);
		wind_get(whdl, WF_NEXTXYWH, pgr);
	}
	wind_update(END_UPDATE);
}


static void sendmsg(_WORD appid, _WORD msg, ...)
{
	register _WORD *ptr;
	_WORD *message;
	register _WORD *papp;
	
	ptr = msgbuff;
	message = ptr;
	papp = &appid;
	if (*papp < 0)
		return;
	*ptr++ = msg;
	*ptr++ = gl_apid;
	*ptr++ = 0;
	*ptr++ = (&msg)[1];
	*ptr++ = (&msg)[2];
	*ptr++ = (&msg)[3];
	*ptr++ = (&msg)[4];
	*ptr = (&msg)[5];
	appl_write(*papp, 16, message);
}


static void send_update(void)
{
	int app;
	int flags;
	
	flags = 0;
	if (inf_get("/topline"))
		flags = 0x01;
	if (inf_get("/rstart"))
		flags |= 0x02;
	if (flag_vertical)
		flags |= 0x04;
	for (app = 0; app < MAX_APPS; app++)
	{
		if (appids[app] == -1)
			sendmsg(app, WIND_DATA, whdl, appline_tree, 0, flags);
	}
}


static void move_window(void)
{
	GRECT gr;
	
	winx_calc(WC_BORDER, WFKIND, *((GRECT *)&appline_tree->ob_x), &gr);
	wind_set(whdl, WF_CURRXYWH, gr);
}


static int myatoi(const char *str)
{
	int val;
	int sign;
	
	/* BUG: does not skip leading spaces */
	val = 0;
	sign = 1;
	if (*str == '-')
	{
		sign = -1;
		str++;
	}
	while (*str >= '0' && *str <= '9')
	{
		val *= 10;
		val += *str - '0';
		str++;
	}
	return val * sign;
}


static void resize_tree_horizontal(int maxlen)
{
	OBJECT *tree;
	register int space;
	/*
	 * BUG in compiler: obj is allocated in D1,
	 * but that is trashed by the strlen() call below
	 */
	register int x;
	register int len;
	register int resize;
	register _WORD orig_width;
	int obj;
	char *p;
	
	tree = appline_tree;
	resize = inf_get("/resize") != 0;
	space = MAX_APPS;
	orig_width = tree->ob_width;
	{
		if ((p = inf_get("/space")) != 0)
			space = myatoi(p);
	}
	tree++;
	obj = 0;
	x = tree->ob_width;
	do
	{
		tree++;
		obj++;
		if (resize && obj == 1)
			appline_tree[ROOT].ob_width = x;
		tree->ob_x = x;
		if (maxlen)
			len = ((int)strlen(tree->ob_spec.tedinfo->te_ptext) + 1);
		else
			len = 9;
		len *= button_len;
		tree->ob_width = len;
		x += len;
		if (--space == 0)
			x += 8;
		if (resize && !(tree->ob_flags & HIDETREE))
			appline_tree[ROOT].ob_width = x;
	} while (!(tree->ob_flags & LASTOB));
	
	if (resize)
	{
		tree = appline_tree;
		if (showmem)
			tree->ob_width += len;
		if (tree->ob_width != orig_width)
		{
			if (inf_get("/rstart"))
				tree->ob_x = desk.g_w - tree->ob_width;
			if (whdl != 0)
				move_window();
		}
	}
}


static void resize_tree_vertical(void)
{
	OBJECT *tree;
	register _WORD height;
	register int space;
	register _WORD y;
	char *p;
	
	tree = appline_tree;
	space = MAX_APPS;
	if ((p = inf_get("/space")) != 0)
		space = myatoi(p);
	tree[ROOT].ob_width = tree[FIRST_BUTTON].ob_width;
	tree++;
	height = y = tree->ob_height;
	if (tree->ob_width != 0)
		tree->ob_width = tree[1].ob_width;
	do
	{
		tree++;
		tree->ob_y = y;
		tree->ob_x = 0;
		y += tree->ob_height;
		if (!(tree->ob_flags & HIDETREE))
			height = y;
		if (--space == 0)
		{
			if (height == y)
				height += 8;
			y += 8;
		}
	} while (!(tree->ob_flags & LASTOB));
	
	tree = appline_tree;
	if (whdl != 0 && height != tree->ob_height)
	{
		if (inf_get("/rstart"))
			tree->ob_y = desk.g_y + desk.g_h - height;
		tree->ob_height = height;
		move_window();
	}
}


static int update_state(void)
{
	register OBJECT *tree; /* a0 */
	register int changed;
	register _WORD hdl;
	long unused;
	struct {
		_WORD appid;
		_WORD isopen;
		_WORD above;
		_WORD below;
	} owner;

	changed = FALSE;
	tree = appline_tree;
	tree++;
	do
	{
		tree++;
		if ((tree->ob_state & frozen_mask) == 0)
		{
			if (tree->ob_state & nowindow_mask)
				tree->ob_state &= ~0x8000;
			else
				tree->ob_state |= nowindow_mask | 0x8000;
		}
	} while (!(tree->ob_flags & LASTOB));
	hdl = 0;
	for (;;)
	{
		wind_get(hdl, WF_OWNER, &owner);
		if (hdl != 0)
		{
			tree = appline_tree;
			tree++;
			do
			{
				tree++;
				if ((tree->ob_state & frozen_mask) == 0 && ((short)tree->ob_type >> 8) == owner.appid)
				{
					if ((tree->ob_state & 0x8000) == 0)
						changed = TRUE;
					tree->ob_state &= ~(0x8000 | nowindow_mask);
					break;
				}
			} while (!(tree->ob_flags & LASTOB));
		}
		if (owner.above <= 0)
		{
			tree = appline_tree;
			tree++;
			do
			{
				tree++;
				if ((tree->ob_state & frozen_mask) == 0 && (tree->ob_state & 0x8000))
				{
					changed = TRUE;
					break;
				}
			} while (!(tree->ob_flags & LASTOB));
			return changed;
		} else
		{
			hdl = owner.above;
		}
	}
}


static int scan_procs(int doredraw)
{
	register OBJECT *tree;
	register char *nameptr;
	register TEDINFO *ted;
	OBJECT *nextapp;
	OBJECT *firstapppos;
	char namebuf[APP_NAME_MAX + 2];
	register int found;
	register int numobjs;
	register int need_redraw; /* d5 */
	register unsigned long memavail;
	register int i;
	char unused1[8];
	const char *deskfirst; /* 30 */
	short unused2; /* 32 */
	short appid; /* 34 */
	_WORD message[8]; /* 50 */
	int ret; /* 52 */
	_WORD default_color; /* 54 */
	_DTA *old_dta; /* 58 */
	_DTA dta; /* 102 */
	long unused3; /* unused */
	_WORD barowner; /* 108 */
	_WORD isspecial;
	struct {
		_WORD hdl;
		_WORD owner;
		_WORD next;
		_WORD special;
	} top; /* 118 */
	char apname[APP_NAME_MAX + 2]; /* 128 */
	char *p;

	tree = appline_tree;
	tree += CLOSER_BUTTON;
	nextapp = NULL;
	numobjs = 0;
	need_redraw = FALSE;
	nameptr = (char *)&namebuf[1]; /* FIXME: cast */
	deskfirst = NULL;
	ret = FALSE;
	barowner = -10;
	if (inf_get("/select"))
	{
		wind_get(0, WF_TOP, (GRECT *)&top);
		if (top.hdl > 0)
		{
			barowner = top.owner;
		} else
		{
			/* query owner of menu bar */
			barowner = menu_bar(NULL, -1);
		}
		if (gl_apid == barowner)
		{
			tree->ob_state |= SELECTED;
		} else
		{
			tree->ob_state &= ~SELECTED;
		}
	}
	if (firstapp[0] == '\0' && (deskfirst = inf_get("/deskfirst")) != NULL)
		tree++;
	default_color = BLACK;
	if ((p = inf_get("=*")) != NULL)
	{
		default_color = myatoi(p);
	}
	old_dta = Fgetdta();
	Fsetdta(&dta);
	found = Fsfirst("U:\\PROC\\*.*", 0x3f);
	if (found != 0)
	{
		ret = TRUE;
		/* FIXME: move to resource */
		/* FIXME2: only give this message once */
		form_alert(1, "[1][|AppLine:|Diese MagiC Version|ist zu alt.][Ende]");
	}
	firstapppos = NULL;
	
	while (found == 0)
	{
		for (p = dta.dta_fname, i = 0; *p != '.'; )
			nameptr[i++] = *p++;
		nameptr[i] = '\0';
		if (strcmp(nameptr, "AESSYS") == 0)
		{
		} else
		{
			/* translate process ID to AES id */
			appid = appl_find(-1, myatoi(p + 1));
			apname[0] = '?';
			apname[1] = 0;
			/* BUG: only works for appids <= 255 */
			apname[2] = appid;
			apname[3] = 0;
			/* get application name */
			appl_find(apname);
			isspecial = 0;
			if (strcmp(firstapp, apname) == 0)
			{
				firstapppos = tree + 1;
			}
			if (apname[0] == '?')
			{
				isspecial = -1;
			}
			if (appid != gl_apid)
			{
/*
				if ((deskfirst != NULL && appid == 0) ||
					(selection || inf_get(nameptr) == NULL))
*/
				if (deskfirst != NULL && appid == 0)
					goto addit;
				else if	(selection || inf_get(nameptr) == NULL)
				{
				addit:
					if (appid == 0 && deskfirst != NULL)
					{
						nextapp = tree;
						tree = appline_tree;
						tree += FIRST_BUTTON;
					} else
					{
						tree++;
					}
					numobjs++;
					ted = tree->ob_spec.tedinfo;
					i = ted->te_color & 0xf0ff;
					namebuf[0] = '=';
					found = default_color;
					if ((p = inf_get(namebuf)) != NULL)
						found = myatoi(p);
					/* BUG: does not check range */
					i |= found << 8;
					ted->te_color = i;
					p = ted->te_ptext;
					if (strcmp(p, nameptr) != 0)
					{
						strcpy(p, nameptr);
						need_redraw = TRUE;
					} else if (isspecial >= 0 && (tree->ob_state & frozen_mask) != 0)
					{
						need_redraw = TRUE;
					} else if (isspecial == -1 && (tree->ob_state & frozen_mask) == 0)
					{
						need_redraw = TRUE;
					}
					tree->ob_flags &= ~HIDETREE;
					tree->ob_type &= 0xff;
					tree->ob_type |= appid << 8;
					if (isspecial != -1)
					{
						tree->ob_state &= ~frozen_mask;
						if (appid == barowner)
							tree->ob_state |= SELECTED;
						else
							tree->ob_state &= ~SELECTED;
					} else
					{
						tree->ob_state |= frozen_mask;
						if (appid == barowner)
							tree->ob_state |= SELECTED;
						else
							tree->ob_state &= ~SELECTED;
					}
				}
			}
		}
		found = Fsnext();
		if (nextapp != NULL)
		{
			tree = nextapp;
			nextapp = NULL;
		}
		if (tree->ob_flags & LASTOB)
			break;
	}
	while (found == 1)
		; /* WTF? */
	Fsetdta(old_dta);
	
	while (!(tree->ob_flags & LASTOB))
	{
		tree++;
		tree->ob_flags |= HIDETREE;
	}
	
	if (showmem)
	{
		numobjs++;
		memavail = (long)Mxalloc(-1L, MX_ALTONLY);
		memavail += (long)Mxalloc(-1L, MX_STONLY);
		memavail >>= 10;
		if (memavail != lastmem)
		{
			lastmem = memavail;
			ltoa(memavail, showmem, 10);
			for (p = showmem; *p != '\0'; p++)
				;
			*p++ = ' ';
			*p = '\0';
			need_redraw = TRUE;
		}		
	}
	
	if (barowner != last_barowner)
	{
		last_barowner = barowner;
		need_redraw = TRUE;
	}
	
	if (flag_vertical)
	{
		resize_tree_vertical();
	} else
	{
		i = 0;
		if (inf_get("/space"))
			i = 8;
		resize_tree_horizontal(button_len * numobjs * 9 + i + appline_tree[CLOSER_BUTTON].ob_width + wind_xoff > desk.g_w);
	}

	if (inf_get("/nowind") && update_state())
		need_redraw = TRUE;
	if (numobjs != last_objs)
		need_redraw = TRUE;
	if (firstapppos != NULL)
	{
		/* if found, put the firstapp into first slot */
		tree = appline_tree;
		tree += FIRST_BUTTON;
		found = tree->ob_x;
		tree->ob_x = firstapppos->ob_x;
		firstapppos->ob_x = found;
		found = tree->ob_y;
		tree->ob_y = firstapppos->ob_y;
		firstapppos->ob_y = found;
	}
	
	if (doredraw && need_redraw)
	{
		objc_offset_grect(appline_tree, ROOT, (GRECT *)&message[4]);
		redraw(message);
		send_update();
	}
	
	last_objs = numobjs;
	
	return ret;
}


static void format_name(char *dst, const char *src)
{
	register int i;
	const char *p = src;
	char *d = dst;
	
	for (i = 0; i < APP_NAME_MAX; i++)
	{
		if (*p != '\0')
		{
			*d = *p++;
			if (*d >= 'a' && *d <= 'z')
				*d -= 'a' - 'A';
			d++;
		} else
		{
			*d++ = ' ';
		}
	}
	*d = '\0';
}


static _WORD create_win(void)
{
	GRECT gr;
	char *server;
	char apname[APP_NAME_MAX + 2];
	_WORD apid;
	
	avserver = 0;
	shel_envrn(&server, "AVSERVER=");
	if (server != NULL)
	{
		format_name(apname, server);
		for (;;)
		{
			apid = appl_find(apname);
			if (apid >= 0)
				break;
			evnt_timer(1000, 0);
		}
		avserver = apid;
	}
	/* BUG: application name not in shareable memory */
	sendmsg(avserver, AV_PROTOKOLL, 0l, 0, "APPLINE ");
	if (scan_procs(FALSE))
		return 0;
	winx_calc(WC_BORDER, WFKIND, *((GRECT *)&appline_tree->ob_x), &gr);
	whdl = winx_create(WFKIND, gr);
	if (whdl <= 0)
	{
		/* FIXME: move to resource */
		form_alert(1, "[3][|AppLine:|Keine Fenster mehr.][Abbruch]");
		whdl = 0;
		return whdl;
	}
	wind_set(whdl, WF_BEVENT, 1);
	winx_open(whdl, gr);
	if (nobackwind == FALSE || inf_get("/topwind") == NULL)
		wind_set(whdl, WF_BOTTOM);
	if (nobackwind)
		sendmsg(avserver, AV_ACCWINDOPEN, whdl, 0, 0, 0, 0);
	return whdl;
}


static void close_win(void)
{
	wind_close(whdl);
	wind_delete(whdl);
	if (nobackwind)
		sendmsg(avserver, AV_ACCWINDCLOSE, whdl, 0, 0, 0, 0);
	whdl = 0;
}


static int cycle_windows(_WORD appid, int mode, const char *name)
{
	_WORD windows[32];
	register int hdl;
	register int numwindows;
	long unused;
	struct {
		_WORD appid;
		_WORD isopen;
		_WORD above;
		_WORD below;
	} owner; /* 76 */
	char unused2[22];
	char apname[APP_NAME_MAX + 2]; /* 108 */
	
	if (appid == gl_apid && nobackwind == FALSE)
		return /* appid */;
	hdl = 0;
	numwindows = 0;
	for (;;)
	{
		wind_get(hdl, WF_OWNER, &owner);
		if (hdl != 0)
			if (owner.appid == appid)
			{
				windows[numwindows++] = hdl;
			}
		if (owner.above <= 0)
			break;
		else
			hdl = owner.above;
	}
	
	if (numwindows != 0)
	{
		if (mode == 1)
		{
			while (--numwindows >= 0)
				wind_set(windows[numwindows], WF_BOTTOM);
		} else
		{
			hdl = 0;
			while (hdl < numwindows)
			{
				wind_set(windows[hdl], WF_TOP);
				hdl++;
			}
		}
		wind_get(0, WF_TOP, &owner);
		appid = owner.isopen; /* owner */
		sendmsg(appid, WM_NEWTOP, owner.appid, 0, 0, 0, 0);
	} else
	{
		if (mode != 0)
			return -1;
		apname[0] = '!';
		strcpy(apname + 1, name);
		if (inf_get(apname) == NULL)
			sendmsg(appid, VA_START, 0l, 0l, 0);
	}
	apname[0] = '-';
	strcpy(apname + 1, name);
	if (inf_get(apname) == NULL)
	{
		/* MagiC special: send message to SCRENMGR to activate app */
		sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, SMC_SWITCH, appid);
	}
	if (mode == 2)
		return appid;
	return -1;
}


static void send_vastart(register _WORD *message)
{
	register _WORD obj;
	
	obj = objc_find(appline_tree, ROOT, MAX_DEPTH, message[4], message[5]);
	if (obj > 0)
	{
		obj = OB_TYPE(appline_tree, obj) >> 8;
		sendmsg(obj, VA_START, message[6], message[7], 0l, 0);
	}
}


void main(void)
{
	register int d3;
	register int d4;
#define do_popup d4
#define rsc_ok d4
#define border d4
#define freeze d4
#define yoff d4
#define key d4
	register _WORD obj; /* d5 */
	register _WORD events; /* d6 */
	register _WORD appid;
	XMULTI xm; /* 62 */
	register XMULTI *pxm;
	register OBJECT *tree; /* a4 */
	register OBJECT *popup; /* a5 */
	char *p;
	int cont; /* 68 */
	long o72;
	int fkeys; /* 74 */
	_WORD xoff; /* 76 */
	_WORD o78; /* 78 / d4 */
	char procname[23];
	char o106[5];
	OBJECT *strings; /* 110 */
	_DTA *old_dta; /* 114 */
	_DTA dta; /* 158 */

	pxm = &xm;
	appl_init();
	if (global[0] != 0x399)
	{
		form_alert(1, "[1][|AppLine:|Dieses Pogramm l\204uft|nur unter MagiC][ Ende ]");
		appl_exit();
		return;
	}
	/* check number of planes */
	rsc_ok = 0;
	if (global[10] < 4)
		rsc_ok = rsrc_load("applinem.rsc");
	if (rsc_ok == 0)
		rsc_ok = rsrc_load("appline.rsc");
	if (rsc_ok == 0)
	{
		form_alert(1, "[3][|AppLine:|RSC-File konnte nicht|geladen werden.][ Ende ]");
		appl_exit();
		return;
	}
	
	rsrc_gaddr(R_TREE, APPLINE_TREE, &appline_tree);
	rsrc_gaddr(R_TREE, APP_POPUP, &app_popup);
	rsrc_gaddr(R_TREE, MAIN_POPUP, &main_popup);
	rsrc_gaddr(R_TREE, STRINGS, &strings);
	
	wind_get(0, WF_WORKXYWH, &desk);
	load_inffile();
	tree = appline_tree;

	if (global[10] >= 4)
	{
		p = inf_get("/border");
		if (p != NULL)
		{
			border = myatoi(p);
			do
			{
				tree++;
				tree->ob_spec.tedinfo->te_thickness = border;
			} while (!(tree->ob_flags & LASTOB));
			tree = appline_tree;
		}
	}
	
	/* 10f76 */
	tree[FIRST_BUTTON].ob_spec.tedinfo->te_ptext[0] = '\0';
	xoff = 0;
	yoff = 0;
	p = inf_get("/xoff");
	if (p != NULL)
		xoff = myatoi(p);
	p = inf_get("/yoff");
	if (p != NULL)
		yoff = myatoi(p);
	p = inf_get("/firstapp");
	if (p != NULL)
		format_name(firstapp, p);
	flag_vertical = inf_get("/vertical") != NULL;
	
	/* 10ff0 */
	tree->ob_y = desk.g_y;
	if (inf_get("/topline") == NULL && !flag_vertical)
		d3 = desk.g_h - tree->ob_height - yoff;
	else
		d3 = yoff;
	tree->ob_y += d3;
	tree->ob_width = desk.g_w - xoff;
	tree->ob_x = xoff;
	wind_xoff = xoff;
	button_len = tree[FIRST_BUTTON].ob_width >> 3;

	pxm->mflags = MU_TIMER | MU_MESAG | MU_KEYBD | MU_BUTTON;
	nobackwind = inf_get("/backwind") == NULL;
	fkeys = inf_get("/fkeys") != NULL;
	frozen_mask = CROSSED;
	nowindow_mask = DISABLED;
	if (inf_get("/frozen-disabled") != NULL)
	{
		frozen_mask = DISABLED;
		nowindow_mask = CROSSED;
	}
	if (inf_get("/large"))
		tree[ROOT].ob_spec.tedinfo->te_font = IBM;
	if (inf_get("/nocloser"))
	{
		tree[CLOSER_BUTTON].ob_width = 0;
		tree[CLOSER_BUTTON].ob_height = 0;
		tree[CLOSER_BUTTON].ob_flags |= HIDETREE;
	}
	
	/* 110e0 */
	showmem = tree[ROOT].ob_spec.tedinfo->te_ptext;
	if (inf_get("/showmem") == NULL || flag_vertical)
	{
		showmem[0] = '\0';
		showmem = NULL;
	}
	
	/* 1110a */
	pxm->mbclicks = 0x102;
	pxm->mbmask = 3;
	pxm->mbstate = 0;
	pxm->mtlocount = 2000;
	pxm->mthicount = 0;
	p = inf_get("/timer");
	if (p != NULL && *p != '\0')
		pxm->mtlocount = myatoi(p);
	
	if (create_win() == 0)
	{
		sendmsg(avserver, AV_EXIT, gl_apid, 0, 0, 0, 0);
		appl_exit();
		return;
	}
	
	cont = TRUE;
	/* 11174 */
	for (;;)
	{
		events = evnx_multi(pxm);
		
		if (events & MU_KEYBD)
		{
			key = pxm->mkreturn >> 8;
			if (fkeys && key >= 0x3b && key <= 0x44)
			{
				obj = key - (0x3b - FIRST_BUTTON);
				if (OB_FLAGS(tree, obj) & HIDETREE)
					;
				else
					goto handle_obj;
			} else
			{
				sendmsg(avserver, AV_SENDKEY, pxm->mmokstate, pxm->mkreturn); /* BUG: not enough egruments */
			}
		}
		
		if (events & MU_MESAG)
		{
			switch ((short)pxm->msgbuf[0]) /* FIXME: cast */
			{
			case WM_REDRAW:
				redraw(pxm->msgbuf);
				break;
			
			case WM_TOPPED:
			case VA_START:
				/* BUG: does not reply with AV_STARTED */
				/* 11486 */
			do_top:
				if (nobackwind)
					wind_set(whdl, WF_TOP);
				break;
				
			case WM_BOTTOMED:
			do_bottom:
				wind_set(whdl, WF_BOTTOM);
				break;
			
			case AP_TERM:
			ap_term:
				cont = FALSE;
				break;
			
			case WM_NEWTOP:
			case WM_ONTOP:
				if (nobackwind)
					;
				else
					wind_set(whdl, WF_BOTTOM);
				break;
			
			case WIND_DATA:
				obj = pxm->msgbuf[3];
				appids[pxm->msgbuf[1]] = obj;
				if (obj == -1)
					send_update();
				break;
				
			case VA_DRAGACCWND:
				send_vastart(pxm->msgbuf);
				break;
			}
		}
		
		if (events & MU_BUTTON)
		{
			obj = objc_find(tree, ROOT, MAX_DEPTH, pxm->mmox, pxm->mmoy);
			/* 000111f8 */
		handle_obj:
			if (obj == ROOT)
			{
				obj = CLOSER_BUTTON;
				events = MU_KEYBD;
			} else
			{
				/* 11432 */
				if (obj <= 0)
					goto scan;
				do_popup = FALSE;
				if (pxm->mmobutton == 2 || pxm->mbreturn == 2 || pxm->mmokstate == K_CTRL)
					do_popup = TRUE;
				if (obj == CLOSER_BUTTON)
				{
					events = 0;
					if (do_popup == FALSE && (p = inf_get("/default")) != NULL)
					{
						if (strncmp(p, "top", 3) == 0)
						{
							goto do_top;
						} else if (strncmp(p, "bottom", 6) == 0)
						{
							goto do_bottom;
						} else if (strncmp(p, "close", 5) == 0)
						{
							goto ap_term;
						}
					}
				} else
				{
					/* 114d8 */
					p = ((TEDINFO *)OB_SPEC(tree, obj))->te_ptext;
					appid = OB_TYPE(tree, obj) >> 8;
					popup = app_popup;
					popup->ob_x = tree[ROOT].ob_x + OB_X(tree, obj);
					goto handle_popup;
				}
			}
			
			/* 11202 */
			do_popup = TRUE;
			popup = main_popup;
			if (events)
			{
				popup->ob_x = pxm->mmox;
			} else
			{
				/* 1141a */
				popup->ob_x = tree[ROOT].ob_x + OB_X(tree, obj);
			}
	
			popup[MAINP_SHOWALL].ob_spec.free_string = selection ? strings[ST_SHOWSEL].ob_spec.free_string : strings[ST_SHOWALL].ob_spec.free_string;
			
			/* 1122e */
		handle_popup:
			if (inf_get("/topline") || flag_vertical)
			{
				popup[ROOT].ob_y = tree[ROOT].ob_y + OB_Y(tree, obj) + OB_HEIGHT(tree, obj) + 1;
			} else
			{
				/* 11402 */
				popup[ROOT].ob_y = tree[ROOT].ob_y - popup[ROOT].ob_height - 2;
			}
			
			/* 1126c */
			if (do_popup)
			{
				if (obj != CLOSER_BUTTON)
				{
					if (OB_STATE(tree, obj) & frozen_mask)
					{
						popup[APP_FREEZE].ob_spec.free_string = strings[ST_UNFREEZE].ob_spec.free_string;
						freeze = SMC_UNFREEZE;
					} else
					{
						/* 113f2 */
						popup[APP_FREEZE].ob_spec.free_string = strings[ST_FREEZE].ob_spec.free_string;
						freeze = SMC_FREEZE;
					}
					old_dta = Fgetdta();
					Fsetdta(&dta);
					strcpy(procname, "U:\\PROC\\");
					strcat(procname, p);
					strcat(procname, ".*");
					Fsfirst(procname, 0x3f);
					Fsetdta(old_dta);
					ltoa(dta.d_length, popup[APP_MEM].ob_spec.free_string + 5, 10);
				}
				/* 11310 */
				events = form_popup(popup, 0, 0);
				if (obj == CLOSER_BUTTON)
				{
					switch (events)
					{
					case MAINP_SHOWALL:
						selection ^= TRUE;
						break;
					case MAINP_UNHIDEALL:
						sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, SMC_UNHIDEALL, appid);
						break;
					case MAINP_QUIT:
						cont = FALSE;
						break;
					}
				} else
				{
					/* 1137e */
					switch (events)
					{
					case APP_KILL:
						sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, SMC_TERMINATE, appid);
						break;
					case APP_QUIT:
						sendmsg(appid, AP_TERM, 0L, 0L, 0);
						break;
					case APP_FREEZE:
						sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, freeze, appid);
						break;
					case APP_HIDEALL:
					case APP_HIDE:
						if (cycle_windows(appid, 2, p) == appid)
							sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, (events - APP_HIDEALL) + SMC_HIDEOTHERS, appid);
						break;
					case APP_BOTTOM:
						cycle_windows(appid, 1, p);
						break;
					case APP_TOP:
						cycle_windows(appid, 0, p);
						break;
					}
				}
			} else
			{
				/* 113ec */
				cycle_windows(appid, 0, p);
			}
		}
			
		/* 11330 */
	scan:
		scan_procs(TRUE);
		if (!cont)
		{
			close_win();
			rsrc_free();
			sendmsg(avserver, AV_EXIT, gl_apid, 0, 0, 0, 0);
			appl_exit();
			return;
		}
	}
}
