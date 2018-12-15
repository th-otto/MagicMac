/*******************************************************
*
* GEMUTILS
* ========
*
* Praktische Hilfsroutinen fÅr GEM
* MT-Version
*
*******************************************************/

#include <tos.h>
#include <aes.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdarg.h>
#include <toserror.h>
#include "gemut_mt.h"

#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ABS(X) ((X>0) ? X : -X)

#ifndef FL3DMASK

#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200
#define FL3DBAK      0x0400
#define FL3DACT      0x0600

#endif

int	vdi_handle;
int	work_out[57], work_in[12];	 /* VDI- Felder fÅr v_opnvwk() */


/****************************************************************
*
* Gibt Fensterhandle des obersten Fensters zurÅck.
*
****************************************************************/

int top_whdl( void )
{
	int whdl;
	int dummy;

	if	(!wind_get(0, WF_TOP, &whdl, &dummy, &dummy, &dummy))
		return(-1);
	if	(whdl < 0)
		return(-1);
	return(whdl);
}


/****************************************************************
*
* Rechnet Mausposition in Objektnummer um.
* (Ñhnlich objc_find, jedoch nur eine Ebene).
* RÅckgabe  0, falls kein Objekt unter dem Mauszeiger,
* RÅckgabe -1, falls inaktiver Hintergrund.
*
****************************************************************/

int find_obj(OBJECT *tree, int x, int y)
{
	register int i,obx,oby,obw,obh;
	register ICONBLK *icn;
	int end;


	if	((i = (tree -> ob_head)) < 0)
		return(0);
	if	((tree -> ob_flags) & HIDETREE)
		return(-1);			/* etwa inaktiver Hintergrund */
	end = tree -> ob_tail;
	x -= tree -> ob_x;			/* Position der Root abziehen */
	y -= tree -> ob_y;
	for	(; i <= end; i++)
		{
		tree++;
		if	((tree->ob_flags) & HIDETREE)
			continue;
		if	(tree -> ob_type == G_USERDEF)
			icn = (ICONBLK *) tree->ob_spec.userblk->ub_parm;
		else
		if	((tree -> ob_type == G_ICON) ||
			 (tree -> ob_type == G_CICON))
			icn = tree->ob_spec.iconblk;
		else icn = NULL;

		/* 1. Fall: ICON */
		if	(icn)
			{
			/* 1. Fall: Icon selbst */
			obx = tree->ob_x + icn->ib_xicon;
			oby = tree->ob_y + icn->ib_yicon;
			obw = icn->ib_wicon;
			obh = icn->ib_hicon;
			if	(x >= obx && x < obx+obw && y >= oby && y < oby+obh)
				return(i);
			/* 2. Fall: Unterschrift */
			obx = tree->ob_x + icn->ib_xtext;
			oby = tree->ob_y + icn->ib_ytext;
			obw = icn->ib_wtext;
			obh = icn->ib_htext;
			if	(x >= obx && x < obx+obw && y >= oby && y < oby+obh)
				return(i);
			}
		/* 2. Fall: sonst (STRING bzw. G_USERDEF) */
		else {
			if	(x >= tree->ob_x && x < tree->ob_x+tree->ob_width &&
				 y >= tree->ob_y && y < tree->ob_y+tree->ob_height)
				return(i);
			}
		}
	return(0);
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

void objc_grect(OBJECT *tree, int objn, GRECT *g)
{
	OBJECT *o;
	int x,y,nx,ny;

	o = tree + objn;
	objc_offset(tree, objn, &nx, &ny);
	if	(((o -> ob_type == G_BUTTON) || (o -> ob_type == G_FTEXT)) &&
		 (o-> ob_flags & FL3DMASK))
		{
		x = o->ob_x;
		y = o->ob_y;
		form_center_grect(o, g);
		g->g_x += nx - o->ob_x;
		g->g_y += ny - o->ob_y;
		o->ob_x = x;
		o->ob_y = y;
		}
	else	{
		g -> g_x = nx;
		g -> g_y = ny;
		g -> g_w = o -> ob_width;
		g -> g_h = o -> ob_height;
		}
}


/****************************************************************
*
* Malt ein Unterobjekt.
*
****************************************************************/

void subobj_draw(OBJECT *tree, int obj, int start, int depth)
{
	GRECT g;

	objc_grect(tree, obj, &g);
	objc_draw_grect(tree, start, depth, &g);
}


/*********************************************************************
*
* Schaltet Maus ein/aus/Pfeil/Biene
*
*********************************************************************/

void  Mgraf_mouse(int type)
{
	static int last = ARROW;

	if	(type == 0x1000)
		type = last;
	graf_mouse(ABS(type), NULL);
	if	(type >= 0 && type != 0x1000 && type != M_ON && type != M_OFF)
		last = type;
}



/*********************************************************************
*
* Objekte verstecken/hervorholen
*
*********************************************************************/

void objs_hide(OBJECT *tree, ...)
{
	va_list argpoint;
	int	objnr;

	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		(tree+objnr)->ob_flags |= HIDETREE;
		(tree+objnr)->ob_flags &= ~EDITABLE;
		}
	while(TRUE);
	va_end(argpoint);
}

void objs_unhide(OBJECT *tree, ...)
{
	va_list argpoint;
	int	objnr;

	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		(tree+objnr)->ob_flags &= ~HIDETREE;
		}
	while(TRUE);
	va_end(argpoint);
}


/*********************************************************************
*
* Objekte enablen/disablen
*
*********************************************************************/

void objs_disable(OBJECT *tree, ...)
{
	va_list argpoint;
	int	objnr;

	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		(tree+objnr)->ob_state |= DISABLED;
		}
	while(TRUE);
	va_end(argpoint);
}

void objs_enable(OBJECT *tree, ...)
{
	va_list argpoint;
	int	objnr;

	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		(tree+objnr)->ob_state &= ~DISABLED;
		}
	while(TRUE);
	va_end(argpoint);
}


/*********************************************************************
*
* Objekte deselektieren/selektieren/Status abfragen
*
*********************************************************************/

int selected(OBJECT *tree, int which)
{
	return( ((tree+which)->ob_state & SELECTED) ? 1 : 0 );
}

void ob_dsel(OBJECT *tree, int which)
{
	(tree+which)->ob_state &= ~SELECTED;
}

void ob_sel_dsel(OBJECT *tree, int which, int sel)
{
	if	(sel)
		(tree+which)->ob_state |=  SELECTED;
	else (tree+which)->ob_state &= ~SELECTED;
}

void ob_sel(OBJECT *tree, int which)
{
	(tree+which)->ob_state |= SELECTED;
}


/*********************************************************************
*
* Radiobuttons setzen und abfragen
*
*********************************************************************/

void objs_setradio(OBJECT *tree, int set, ...)
{
	va_list argpoint;
	int	objnr;

	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		if	(objnr == set)
			(tree+objnr)->ob_state |=  SELECTED;
		else	(tree+objnr)->ob_state &= ~SELECTED;
		}
	while(TRUE);
	va_end(argpoint);
}

void objs_getradio(OBJECT *tree, int *get, ...)
{
	va_list argpoint;
	int	objnr;

	*get = 0;		/* keins ausgewÑhlt */
	va_start(argpoint, tree);
	do	{
		objnr = va_arg(argpoint, int);
		if	(objnr == 0)
			break;
		if	((tree+objnr)->ob_state & SELECTED)
			{
			*get = objnr;
			break;
			}
		}
	while(TRUE);
	va_end(argpoint);
}


/*********************************************************************
*
* VDI initialisieren
*
*********************************************************************/

void open_work(void)
{
	register int i;


	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);
}


/*********************************************************************
*
* LÑdt RSC-Datei, bricht ggf. das Programm ab.
*
*********************************************************************/

void Mrsrc_load( char *fname, WORD *global )
{
	if	(!mt_rsrc_load(fname, global))
		{
		form_xerr(EFILNF, fname);
		appl_exit();
		Pterm((int) EFILNF);
		}
}


/*********************************************************************
*
* Liest Komma-getrennte Werte aus einer Zeichenkette, die mit
* '\n' oder EOS beendet ist
*
*	RÅckgabe:	0		nichts gefunden
*			sonst	Anzahl eingelesener Werte
*
*********************************************************************/

int scan_values(char **s, int n, int values[])
{
	register char *t = *s;
	register int i;
	long val;

	for	(i = 0; i < n; i++)
		{
		while(*t == ' ')
			t++;
		if	(i)				/* Komma finden */
			{
			if	(*t != ',')
				{
				*s = t;
				return(i);	/* Fehler, kein Komma */
				}
			t++;
			}
		val = strtol(t, s, 10);
		if	(t == *s)
			return(i);		/* Fehler beim Einlesen */
		*values++ = (int) val;	/* ein Wert eingelesen */
		t = *s;
		while(*t == ' ')
			t++;
		}
	*s = t;
	return(i);
}


/*********************************************************************
*
* Schreibt Komma-getrennte Werte in eine Zeichenkette
*
*********************************************************************/

void print_values(char *s, int n, int values[])
{
	register int i;

	for	(i = 0; i < n; i++)
		{
		if	(i)
			*s++ = ',';
		itoa(*values++, s, 10);
		s += strlen(s);
		}
}


/*********************************************************************
*
* Ermittelt zu einem vollen Pfadnamen den Zeiger auf den
* reinen Dateinamen
*
*********************************************************************/

char *get_name(char *path)
{
	register char *n;

	n = strrchr(path, '\\');
	if	(!n)
		{
		if	((*path) && (path[1] == ':'))
			path += 2;
		return(path);
		}
	return(n + 1);
}


/*********************************************************************
*
* Rechnet Dateinamen ins interne Format und zurÅck
*
*********************************************************************/

void fname_int(char *s, char *d)
{
	register char *p = d;
	register int i;

	for	(i = 0;					/* Name */
		(*s) && (*s != '.');
		i++,s++)
		{
		if	(i < 8)
			*p++ = *s;			/* nur max. 8 Zeichen */
		}
	if	(*s)						/* Punkt */
		s++;
	if	(*s)						/* Extension */
		{
		while(p < d+8)
			*p++ = ' ';
		for	(i = 0; (*s); i++,s++)
			{
			if	(i < 3)
				*p++ = *s;
			}
		}
	*p = '\0';
}

void fname_ext(char *s, char *d)
{
	register char *p = s;

	while(*p && p < s+8)
		{
		if	(*p != ' ')
			*d++ = *p++;
		else p++;
		}
	if	(*p)
		*d++ = '.';
	while(*p)
		*d++ = *p++;
	*d = '\0';
}


/*********************************************************************
*
* PrÅft, ob ein Pfad absolut ist.
*
*********************************************************************/

int is_absolute_path(char *path)
{
	if	(!(*path++))
		return(FALSE);
	if	(*path++ != ':')
		return(FALSE);
	return(*path == '\\');
}


/*********************************************************************
*
* Holt eine Zeichenkette aus der RSC-Datei.
*
*********************************************************************/

char *Rgetstring( WORD string_id, WORD *global )
{
	char *alert;

	mt_rsrc_gaddr(R_STRING, string_id, &alert, global);
	return(alert);
}


/*********************************************************************
*
* FÅhrt einen Alert aus der RSC-Datei durch.
*
*********************************************************************/

WORD Rform_alert( WORD defbutton, WORD alert_id, WORD *global )
{
	return(form_alert(defbutton, Rgetstring(alert_id, global)));
}


/*********************************************************************
*
* FÅhrt einen Alert aus der RSC-Datei durch.
* Der Alertstring enthÑlt einen Dateinamen.
*
*********************************************************************/

WORD Rxform_alert( WORD defbutton, WORD alert_id,
				char drv, char *path, WORD *global )
{
	register char *alert;
	char buf[256];
	register char *t;


	alert = Rgetstring(alert_id, global);
	t = buf;
	while(*alert)
		{
		if	(*alert == '%')
			{
			alert++;
			if	(*alert == 'c')
				{
				*t++ = drv;
				alert++;
				continue;
				}
			if	(*alert == 's')
				{
				while(*path)
					*t++ = *path++;
				alert++;
				continue;
				}
			}
		*t++ = *alert++;
		}
	*t = EOS;

	return(form_alert(defbutton, buf));
}


/*********************************************************************
*
* FÅhrt einen Dialog durch.
*
*********************************************************************/

int do_dialog(OBJECT *dialog)
{
	GRECT gc;
	int exitbutton, dummy;
	void *flyinf = NULL;
	void **p_flyinf;


	flyinf = NULL;
	p_flyinf = &flyinf;
	form_center_grect(dialog, &gc);
	form_xdial_grect(FMD_START, NULL, &gc, p_flyinf);
	objc_draw_grect(dialog, ROOT, MAX_DEPTH, &gc);
	exitbutton = 0x7f & form_xdo(dialog, 0, &dummy, NULL, flyinf);
	form_xdial_grect(FMD_FINISH, NULL, &gc, p_flyinf);
	ob_dsel(dialog, exitbutton);
	return(exitbutton);
}

int do_exdialog(OBJECT *dialog,
			 int (*check)(OBJECT *dialog, int exitbutton),
			 int *was_redraw)
{
	GRECT gc;
	int exitbutton,dummy;
	void *flyinf = NULL;
	void **p_flyinf;


	flyinf = NULL;
	p_flyinf = &flyinf;
	form_center_grect(dialog, &gc);
	form_xdial_grect(FMD_START, NULL, &gc, p_flyinf);
	objc_draw_grect(dialog, ROOT, MAX_DEPTH, &gc);
	for	(;;)
		{
		exitbutton = 0x7f & form_xdo(dialog, 0, &dummy, NULL, flyinf);
/*		ob_dsel(dialog, exitbutton);	*/
		if	((*check)(dialog, exitbutton))
			break;
/*		objc_draw(dialog, exitbutton, 1, cx, cy, cw, ch);	*/
		}
	form_xdial_grect(FMD_FINISH, NULL, &gc, p_flyinf);
	if	(was_redraw != NULL)
		*was_redraw = (flyinf == NULL);	/* RÅckgabe: Bildschirm zerstîrt */
	return(exitbutton);
}
