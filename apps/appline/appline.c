/*******************************************************************
*
*             APPLINE.APP
*             ===========
*
* Originally written by Holger Weets & Rainer Wiesenfeller,
* using SozobonX 2.00x35
* Reconstructed & ported to Pure-C by Thorsten Otto
*
********************************************************************/

#include <stdio.h>
#include <string.h>
#ifdef __SOZOBONX__
#include <xgemfast.h>
#define _DTA DTA
#define d_fname dta_name
#include <atari.h>
#include <osbind.h>
#else
#ifdef __PUREC__
#include <aes.h>
#include <tos.h>
#else
#include <gem.h>
#include <gemx.h>
#include <osbind.h>
#include <support.h>
#define ultoa _ultoa
#endif
#endif

#ifndef _WORD
#if defined(__PUREC__) || defined(__SOZOBONX__)
#define _WORD int
#else
#define _WORD short
#endif
#endif

#include "appline.h"

#ifndef FALSE
#  define FALSE 0
#  define TRUE  1
#endif


#define MAX_APPS 30

#define WIND_DATA 0x935
/* flags of our window: none */
#define WFKIND 0

#define APP_NAME_MAX 8

static _WORD last_objs = -1;
static _WORD last_barowner = -10;
static char avname[] = "APPLINE ";

static _WORD msgbuff[8];
static char *inffile;
static GRECT desk;
static OBJECT *appline_tree;
static _WORD whdl;
static int flag_vertical;
static _WORD appids[MAX_APPS];
static _WORD button_len;
static char *showmem;
static _WORD frozen_mask;
static _WORD nowindow_mask;
static char firstapp[APP_NAME_MAX + 2];
static unsigned long lastmem;
static _WORD wind_xoff;
static _WORD selection;
static _WORD avserver;
static int nobackwind;
static OBJECT *app_popup;
static OBJECT *main_popup;

#define gl_apid aes_global[2]
#define gl_planes aes_global[10]


/* VA protocol */
#define AV_PROTOKOLL    0x4700
#define VA_START        0x4711
#define AV_ACCWINDOPEN  0x4724
#define AV_ACCWINDCLOSE 0x4726
#define AV_EXIT         0x4736
#define AV_SENDKEY      0x4710
#define VA_DRAGACCWND   0x4725

/* SM_M_SPECIAL codes */
#define SM_M_SPECIAL 101
#define SMC_TIDY_UP     0           /* MagiC 2  */
#define SMC_TERMINATE   1           /* MagiC 2  */
#define SMC_SWITCH      2           /* MagiC 2  */
#define SMC_FREEZE      3           /* MagiC 2  */
#define SMC_UNFREEZE    4           /* MagiC 2  */
#define SMC_RES5        5           /* MagiC 2  */
#define SMC_UNHIDEALL   6           /* MagiC 3.1 */
#define SMC_HIDEOTHERS  7           /* MagiC 3.1 */
#define SMC_HIDEACT     8           /* MagiC 3.1 */


#undef PATH_MAX
#define PATH_MAX 128


static void load_inffile(void)
{
	char pathname[PATH_MAX + 6];
	int fd;
	long size;
	char *buf;
	
	buf = pathname;
	strcpy(buf, "appline.inf");
	shel_find(buf);
	fd = (int)Fopen(buf, 0);
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
	char *buf = inffile;
	int len;
	char c;
	
	if (buf != NULL)
	{
		len = (int)strlen(key);
		while (*buf != '\0')
		{
			if (*buf == ' ')
				buf++;
			if ((c = buf[len]) == '\0' || c == ' ')
			{
				if (strncmp(buf, key, len) == 0)
				{
					buf += len;
					while (*buf == ' ')
						buf++;
					return buf;
				}
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
	
	wind_update(BEG_UPDATE);
	rc_intersect(&desk, (GRECT *)&message[4]);
	wind_get_grect(whdl, WF_FIRSTXYWH, &gr);
	while (gr.g_w != 0 && gr.g_h != 0)
	{
		work.g_x = message[4] - 1;
		work.g_y = message[5] - 1;
		work.g_w = message[6] + 1;
		work.g_h = message[7] + 1;
		if (rc_intersect(&gr, &work))
			objc_draw_grect(appline_tree, ROOT, MAX_DEPTH, &work);
		wind_get_grect(whdl, WF_NEXTXYWH, &gr);
	}
	wind_update(END_UPDATE);
}


static void sendmsg(_WORD appid, _WORD msg, _WORD w3, _WORD w4, _WORD w5, _WORD w6, _WORD w7)
{
	_WORD *ptr;
	
	ptr = msgbuff;
	if (appid < 0)
		return;
	*ptr++ = msg;
	*ptr++ = gl_apid;
	*ptr++ = 0;
	*ptr++ = w3;
	*ptr++ = w4;
	*ptr++ = w5;
	*ptr++ = w6;
	*ptr = w7;
	appl_write(appid, 16, msgbuff);
}


static void sm_special(_WORD cmd, _WORD appid)
{
	sendmsg(1, SM_M_SPECIAL, 0, 0x4D41, 0x4758, cmd, appid);
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
			sendmsg(app, WIND_DATA, whdl, (_WORD)((unsigned long)appline_tree >> 16), (_WORD)(unsigned long)appline_tree, 0, flags);
	}
}


static void move_window(void)
{
	GRECT gr;
	
	wind_calc_grect(WC_BORDER, WFKIND, ((GRECT *)&appline_tree->ob_x), &gr);
	wind_set_grect(whdl, WF_CURRXYWH, &gr);
}


static int myatoi(const char *str)
{
	int val;
	int sign;
	
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
	int space;
	int x;
	int len;
	int resize;
	_WORD orig_width;
	int obj;
	const char *p;
	
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
		if (resize && !(tree->ob_flags & OF_HIDETREE))
			appline_tree[ROOT].ob_width = x;
	} while (!(tree->ob_flags & OF_LASTOB));
	
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
	_WORD height;
	int space;
	_WORD y;
	const char *p;
	
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
		if (!(tree->ob_flags & OF_HIDETREE))
			height = y;
		if (--space == 0)
		{
			if (height == y)
				height += 8;
			y += 8;
		}
	} while (!(tree->ob_flags & OF_LASTOB));
	
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
	OBJECT *tree;
	int changed;
	_WORD hdl;
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
	} while (!(tree->ob_flags & OF_LASTOB));
	hdl = 0;
	for (;;)
	{
		wind_get_grect(hdl, WF_OWNER, (GRECT *)&owner);
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
			} while (!(tree->ob_flags & OF_LASTOB));
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
			} while (!(tree->ob_flags & OF_LASTOB));
			return changed;
		} else
		{
			hdl = owner.above;
		}
	}
}


static int scan_procs(int doredraw)
{
	OBJECT *tree;
	char *nameptr;
	TEDINFO *ted;
	OBJECT *nextapp;
	OBJECT *firstapppos;
	char namebuf[APP_NAME_MAX + 2];
	int found;
	int numobjs;
	int need_redraw;
	unsigned long memavail;
	int i;
	const char *deskfirst;
	short appid;
	_WORD message[8];
	int ret;
	_WORD default_color;
	_DTA *old_dta;
	_DTA dta;
	_WORD barowner;
	_WORD isspecial;
	struct {
		_WORD hdl;
		_WORD owner;
		_WORD next;
		_WORD special;
	} top;
	char apname[APP_NAME_MAX + 2];
	const char *p;

	tree = appline_tree;
	tree += CLOSER_BUTTON;
	nextapp = NULL;
	numobjs = 0;
	need_redraw = FALSE;
	nameptr = &namebuf[1];
	deskfirst = NULL;
	ret = FALSE;
	barowner = -10;
	if (inf_get("/select"))
	{
		wind_get_grect(0, WF_TOP, (GRECT *)&top);
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
			tree->ob_state |= OS_SELECTED;
		} else
		{
			tree->ob_state &= ~OS_SELECTED;
		}
	}
	if (firstapp[0] == '\0' && (deskfirst = inf_get("/deskfirst")) != NULL)
		tree++;
	default_color = G_BLACK;
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
		for (p = dta.dta_name, i = 0; *p != '.'; )
			nameptr[i++] = *p++;
		nameptr[i] = '\0';
		if (strcmp(nameptr, "AESSYS") != 0)
		{
			/* translate process ID to AES id */
			appid = appl_find((char *)(0xffff0000L | myatoi(p + 1)));
			if (appid >= 0 && appid <= 255)
			{
				/* get application name */
				apname[0] = '?';
				apname[1] = 0;
				/* Note: only works for appids <= 255 */
				apname[2] = appid;
				apname[3] = 0;
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
					if ((deskfirst != NULL && appid == 0) ||
						(selection || inf_get(nameptr) == NULL))
					{
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
						if (strcmp(ted->te_ptext, nameptr) != 0)
						{
							strcpy(ted->te_ptext, nameptr);
							need_redraw = TRUE;
						} else if (isspecial >= 0 && (tree->ob_state & frozen_mask) != 0)
						{
							need_redraw = TRUE;
						} else if (isspecial == -1 && (tree->ob_state & frozen_mask) == 0)
						{
							need_redraw = TRUE;
						}
						tree->ob_flags &= ~OF_HIDETREE;
						tree->ob_type &= 0xff;
						tree->ob_type |= appid << 8;
						if (isspecial != -1)
						{
							tree->ob_state &= ~frozen_mask;
							if (appid == barowner)
								tree->ob_state |= OS_SELECTED;
							else
								tree->ob_state &= ~OS_SELECTED;
						} else
						{
							tree->ob_state |= frozen_mask;
							if (appid == barowner)
								tree->ob_state |= OS_SELECTED;
							else
								tree->ob_state &= ~OS_SELECTED;
						}
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
		if (tree->ob_flags & OF_LASTOB)
			break;
	}
	Fsetdta(old_dta);
	
	while (!(tree->ob_flags & OF_LASTOB))
	{
		tree++;
		tree->ob_flags |= OF_HIDETREE;
	}
	
	if (showmem)
	{
		numobjs++;
		memavail = (long)Mxalloc(-1L, MX_TTRAM);
		memavail += (long)Mxalloc(-1L, MX_STRAM);
		memavail >>= 10;
		if (memavail != lastmem)
		{
			char *end;
			lastmem = memavail;
			ultoa(memavail, showmem, 10);
			for (end = showmem; *end != '\0'; end++)
				;
			*end++ = ' ';
			*end = '\0';
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
		tree = appline_tree;
		objc_offset(tree, ROOT, &message[4], &message[5]);
		message[6] = tree[ROOT].ob_width;
		message[7] = tree[ROOT].ob_height;
		redraw(message);
		send_update();
	}
	
	last_objs = numobjs;
	
	return ret;
}


static void format_name(char *dst, const char *src)
{
	int i;
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
	char *ptr;

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
			evnt_timer(1000);
		}
		avserver = apid;
	}
	/* BUG: application name not in shareable memory */
	ptr = avname;
	sendmsg(avserver, AV_PROTOKOLL, 0, 0, 0, (_WORD)((unsigned long)ptr >> 16), (_WORD)(unsigned long)ptr);
	if (scan_procs(FALSE))
		return 0;
	wind_calc_grect(WC_BORDER, WFKIND, ((GRECT *)&appline_tree->ob_x), &gr);
	whdl = wind_create_grect(WFKIND, &gr);
	if (whdl <= 0)
	{
		/* FIXME: move to resource */
		form_alert(1, "[3][|AppLine:|Keine Fenster mehr.][Abbruch]");
		whdl = 0;
		return whdl;
	}
	wind_set_int(whdl, WF_BEVENT, 1);
	wind_open_grect(whdl, &gr);
	if (nobackwind == FALSE || inf_get("/topwind") == NULL)
		wind_set_int(whdl, WF_BOTTOM, 0);
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
	int hdl;
	int numwindows;
	struct {
		_WORD appid;
		_WORD isopen;
		_WORD above;
		_WORD below;
	} owner;
	char apname[APP_NAME_MAX + 2];
	
	if (appid == gl_apid && nobackwind == FALSE)
		return appid;
	hdl = 0;
	numwindows = 0;
	for (;;)
	{
		wind_get_grect(hdl, WF_OWNER, (GRECT *)&owner);
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
				wind_set_int(windows[numwindows], WF_BOTTOM, 0);
		} else
		{
			hdl = 0;
			while (hdl < numwindows)
			{
				wind_set_int(windows[hdl], WF_TOP, 0);
				hdl++;
			}
		}
		wind_get_grect(0, WF_TOP, (GRECT *)&owner);
		appid = owner.isopen; /* owner */
		sendmsg(appid, WM_NEWTOP, owner.appid, 0, 0, 0, 0);
	} else
	{
		if (mode != 0)
			return -1;
		apname[0] = '!';
		strcpy(apname + 1, name);
		if (inf_get(apname) == NULL)
			sendmsg(appid, VA_START, 0, 0, 0, 0, 0);
	}
	apname[0] = '-';
	strcpy(apname + 1, name);
	if (inf_get(apname) == NULL)
	{
		/* MagiC special: send message to SCRENMGR to activate app */
		sm_special(SMC_SWITCH, appid);
	}
	if (mode == 2)
		return appid;
	return -1;
}


static void send_vastart(_WORD *message)
{
	_WORD obj;
	
	obj = objc_find(appline_tree, ROOT, MAX_DEPTH, message[4], message[5]);
	if (obj > 0)
	{
		obj = appline_tree[obj].ob_type >> 8;
		sendmsg(obj, VA_START, message[6], message[7], 0, 0, 0);
	}
}


static void cleanup(void)
{
	rsrc_free();
	sendmsg(avserver, AV_EXIT, gl_apid, 0, 0, 0, 0);
	appl_exit();
}


int main(void)
{
	int do_popup;
	int border;
	int freeze;
	_WORD xoff;
	_WORD yoff;
	_WORD obj;
	_WORD events;
	_WORD mox, moy, button, kstate, kreturn, clicks;
	_WORD message[8];
	_WORD timeout;
	_WORD appid = 0;
	OBJECT *tree;
	OBJECT *popup;
	const char *p;
	int cont;
	int fkeys;
	char procname[sizeof("U:\\PROC\\.*") + APP_NAME_MAX + 8];
	OBJECT *strings;
	_DTA *old_dta;
	_DTA dta;

	appl_init();
	if (aes_global[0] != 0x399)
	{
		form_alert(1, "[1][|AppLine:|Dieses Programm l\204uft|nur unter MagiC][ Ende ]");
		appl_exit();
		return 1;
	}
	if (rsrc_load("appline.rsc") == 0)
	{
		form_alert(1, "[3][|AppLine:|RSC-File konnte nicht|geladen werden.][ Ende ]");
		appl_exit();
		return 1;
	}

	rsrc_gaddr(R_TREE, APPLINE_TREE, &appline_tree);
	rsrc_gaddr(R_TREE, APP_POPUP, &app_popup);
	rsrc_gaddr(R_TREE, MAIN_POPUP, &main_popup);
	rsrc_gaddr(R_TREE, STRINGS, &strings);
	
	wind_get_grect(0, WF_WORKXYWH, &desk);
	load_inffile();

	tree = appline_tree;
	if (gl_planes >= 4)
	{
		border = 4;
		p = inf_get("/border");
		if (p != NULL)
			border = myatoi(p);
	} else
	{
		border = -1;
		tree[ROOT].ob_flags &= ~OF_FL3DBAK;
		tree[ROOT].ob_spec.tedinfo->te_color = 0x1121;
	}
	do
	{
		tree++;
		tree->ob_spec.tedinfo->te_thickness = border;
	} while (!(tree->ob_flags & OF_LASTOB));
	
	tree = appline_tree;
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
	
	tree->ob_y = desk.g_y;
	if (inf_get("/topline") == NULL && !flag_vertical)
		yoff = desk.g_h - tree->ob_height - yoff;
	tree->ob_y += yoff;
	tree->ob_width = desk.g_w - xoff;
	tree->ob_x = xoff;
	wind_xoff = xoff;
	button_len = tree[FIRST_BUTTON].ob_width >> 3;

	nobackwind = inf_get("/backwind") == NULL;
	fkeys = inf_get("/fkeys") != NULL;
	frozen_mask = OS_CROSSED;
	nowindow_mask = OS_DISABLED;
	if (inf_get("/frozen-disabled") != NULL)
	{
		frozen_mask = OS_DISABLED;
		nowindow_mask = OS_CROSSED;
	}
	if ((p = inf_get("/large")) != NULL)
	{
		tree[ROOT].ob_spec.tedinfo->te_font = IBM;
		if (myatoi(p) != 0)
		{
			do
			{
				tree++;
				tree->ob_spec.tedinfo->te_font = IBM;
			} while (!(tree->ob_flags & OF_LASTOB));
		}
	}

	tree = appline_tree;
	if (inf_get("/nocloser"))
	{
		tree[CLOSER_BUTTON].ob_width = 0;
		tree[CLOSER_BUTTON].ob_height = 0;
		tree[CLOSER_BUTTON].ob_flags |= OF_HIDETREE;
	}
	
	showmem = tree[ROOT].ob_spec.tedinfo->te_ptext;
	if (inf_get("/showmem") == NULL || flag_vertical)
	{
		showmem[0] = '\0';
		showmem = NULL;
	}
	
	timeout = 2000;
	p = inf_get("/timer");
	if (p != NULL && *p != '\0')
		timeout = myatoi(p);
	
	if (create_win() == 0)
	{
		cleanup();
		return 1;
	}
	
	cont = TRUE;
	for (;;)
	{
		events = evnt_multi(MU_TIMER | MU_MESAG | MU_KEYBD | MU_BUTTON,
			0x102, 3, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			message,
			timeout,
			&mox, &moy, &button, &kstate, &kreturn, &clicks);
		
		if (events & MU_KEYBD)
		{
			_WORD key = kreturn >> 8;
			if (fkeys && key >= 0x3b && key <= 0x44)
			{
				obj = key - (0x3b - FIRST_BUTTON);
				if (!(tree[obj].ob_flags & OF_HIDETREE))
					goto handle_obj;
			} else
			{
				sendmsg(avserver, AV_SENDKEY, kstate, kreturn, 0, 0, 0);
			}
		}
		
		if (events & MU_MESAG)
		{
			switch (message[0])
			{
			case WM_REDRAW:
				redraw(message);
				break;
			
			case WM_TOPPED:
			case VA_START:
				/* BUG: does not reply with AV_STARTED */
			do_top:
				if (nobackwind)
					wind_set_int(whdl, WF_TOP, 0);
				break;
				
			case WM_BOTTOMED:
			do_bottom:
				wind_set_int(whdl, WF_BOTTOM, 0);
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
					wind_set_int(whdl, WF_BOTTOM, 0);
				break;
			
			case WIND_DATA:
				obj = message[3];
				appids[message[1]] = obj;
				if (obj == -1)
					send_update();
				break;
				
			case VA_DRAGACCWND:
				send_vastart(message);
				break;
			}
		}
		
		if (events & MU_BUTTON)
		{
			obj = objc_find(tree, ROOT, MAX_DEPTH, mox, moy);
		handle_obj:
			if (obj == ROOT)
			{
				obj = CLOSER_BUTTON;
				events = MU_KEYBD;
			} else
			{
				if (obj <= 0)
					goto scan;
				do_popup = FALSE;
				if (button == 2 || clicks == 2 || kstate == K_CTRL)
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
					p = tree[obj].ob_spec.tedinfo->te_ptext;
					appid = tree[obj].ob_type >> 8;
					popup = app_popup;
					popup->ob_x = tree[ROOT].ob_x + tree[obj].ob_x;
					goto handle_popup;
				}
			}
			
			do_popup = TRUE;
			popup = main_popup;
			if (events)
			{
				popup->ob_x = mox;
			} else
			{
				popup->ob_x = tree[ROOT].ob_x + tree[obj].ob_x;
			}
	
			popup[MAINP_SHOWALL].ob_spec.free_string = selection ? strings[ST_SHOWSEL].ob_spec.free_string : strings[ST_SHOWALL].ob_spec.free_string;
			
		handle_popup:
			if (inf_get("/topline") || flag_vertical)
			{
				popup[ROOT].ob_y = tree[ROOT].ob_y + tree[obj].ob_y + tree[obj].ob_height + 1;
			} else
			{
				popup[ROOT].ob_y = tree[ROOT].ob_y - popup[ROOT].ob_height - 2;
			}
			
			if (do_popup)
			{
				if (obj != CLOSER_BUTTON)
				{
					if (tree[obj].ob_state & frozen_mask)
					{
						popup[APP_FREEZE].ob_spec.free_string = strings[ST_UNFREEZE].ob_spec.free_string;
						freeze = SMC_UNFREEZE;
					} else
					{
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
					ultoa(dta.dta_size, popup[APP_MEM].ob_spec.free_string + 5, 10);
				}
				events = form_popup(popup, 0, 0);
				if (obj == CLOSER_BUTTON)
				{
					switch (events)
					{
					case MAINP_SHOWALL:
						selection ^= TRUE;
						break;
					case MAINP_UNHIDEALL:
						sm_special(SMC_UNHIDEALL, appid);
						break;
					case MAINP_QUIT:
						cont = FALSE;
						break;
					}
				} else
				{
					switch (events)
					{
					case APP_KILL:
						sm_special(SMC_TERMINATE, appid);
						break;
					case APP_QUIT:
						sendmsg(appid, AP_TERM, 0, 0, 0, 0, 0);
						break;
					case APP_FREEZE:
						sm_special(freeze, appid);
						break;
					case APP_HIDEALL:
					case APP_HIDE:
						if (cycle_windows(appid, 2, p) == appid)
							sm_special((events - APP_HIDEALL) + SMC_HIDEOTHERS, appid);
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
				cycle_windows(appid, 0, p);
			}
		}
			
	scan:
		scan_procs(TRUE);
		if (!cont)
		{
			close_win();
			cleanup();
			return 0;
		}
	}
}
