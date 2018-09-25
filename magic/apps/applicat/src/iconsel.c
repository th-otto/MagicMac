/*
*
* EnthÑlt die spezifischen Routinen fÅr das
* Fenster zur Icon-Auswahl
*
*/

#include <mgx_dos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "applicat.h"
#include "windows.h"
#include "appl.h"
#include "appldata.h"
#include "iconsel.h"
#include "ica_dial.h"
#include "icp_dial.h"
#include "spc_dial.h"

#define  WXOFFS	3
#define  WYOFFS	1
#define  WXDIST	3
#define  WYDIST	1

/* Daten fÅrs Fenster */
static WINDOW iconwindow;

WINDOW *mywindow = NULL;


/****************************************************************
*
* Malt alle Objekte in der Liste <mov_boxes[anz_boxes]>.
* Wird als Begrenzung <grenz> != NULL angegeben, wird verhindert,
*  daû die Objekte auûerhalb des Bildschirms liegen.
*
****************************************************************/

int xrel, yrel;

void draw_boxes(OBJECT *tree, OBJECT *mov_boxes[], int anz_boxes,
			 GRECT *grenz, int xoff, int yoff)
{
	int px, py;
	int pxy[10];


	vswr_mode	(vdi_handle, MD_XOR);
	vsl_type	(vdi_handle, DASH);
	if	(grenz)
		{
		if	(grenz->g_x + xoff < scrg.g_x)
			xoff = scrg.g_x - grenz->g_x;
		if	(grenz->g_y + yoff < scrg.g_y)
			yoff = scrg.g_y - grenz->g_y;
		if	(grenz->g_x + grenz->g_w + xoff > scrg.g_x + scrg.g_w)
			xoff = scrg.g_x + scrg.g_w - (grenz->g_x + grenz->g_w);
		if	(grenz->g_y + grenz->g_h + yoff > scrg.g_y + scrg.g_h)
			yoff = scrg.g_y + scrg.g_h - (grenz->g_y + grenz->g_h);
		}
	px = tree->ob_x + xoff;
	py = tree->ob_y + yoff;
	xrel = xoff;
	yrel = yoff;

	for	(; anz_boxes > 0; anz_boxes--,mov_boxes++)
		{
		pxy[0] = (*mov_boxes)->ob_x + px;
		pxy[1] = (*mov_boxes)->ob_y + py;

		pxy[2] = pxy[0] + (*mov_boxes)->ob_width;
		pxy[3] = pxy[1];

		pxy[4] = pxy[0] + (*mov_boxes)->ob_width;
		pxy[5] = pxy[1] + (*mov_boxes)->ob_height;

		pxy[6] = pxy[0];
		pxy[7] = pxy[1] + (*mov_boxes)->ob_height;

		pxy[8] = pxy[0];
		pxy[9] = pxy[1];

		v_pline(vdi_handle,5,pxy);		/* Rechteck malen */
		}
	vswr_mode(vdi_handle, MD_REPLACE);
}


/****************************************************************
*
* Verschieben von selektierten Objekten.
* <wnr>,<tree>		: Nummer und Baum der selektierten Objekte
* <x_koor>,<y_koor>	: Anklickpunkt in absoluten Koordinaten
* KEIN BEG_UPDATE ausgefÅhrt
*
****************************************************************/

void move_icons(int x_koor, int y_koor, OBJECT *tree, int objnr)
{
	int clip_rect[4];
	GRECT g;
	GRECT *ptr_g;
	OBJECT *mov_boxes;
	EVNTDATA ev;
	int old_x,old_y;
	OBJECT *zieltree;
	int zielwhdl;
	int zielobj;
	int altobj = 0;
	OBJECT *alttree = NULL;
	void (*set_icon)(int iconnr, int objnr);
	void (*malen)(int objnr);
	void (*altmalen)(int objnr) = NULL;


	mov_boxes = tree + objnr;		/* Tabelle aller Objekte */
	ptr_g = &g;
	objc_grect(tree, objnr, ptr_g);	/* HÅlle aller Objekte */

	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	graf_mouse(FLAT_HAND, NULL);

	clip_rect[0] = scrg.g_x;
	clip_rect[1] = scrg.g_y;
	clip_rect[2] = scrg.g_x+scrg.g_w-1;
	clip_rect[3] = scrg.g_y+scrg.g_h-1;
	vs_clip	(vdi_handle, TRUE, clip_rect);

	ev.x = x_koor;
	ev.y = y_koor;
	do	{
		vs_clip	(vdi_handle, TRUE, clip_rect);
		draw_boxes(tree, &mov_boxes, 1, ptr_g,
				 ev.x-x_koor, ev.y-y_koor);
		graf_mouse(M_ON, NULL);

		old_x = ev.x;
		old_y = ev.y;
		do	{
			graf_mkstate(&ev.x, &ev.y, &ev.bstate, &ev.kstate);
			}
		while(ev.x == old_x && ev.y == old_y && (ev.bstate & 1));
		graf_mouse(M_OFF, NULL);
		draw_boxes(tree, &mov_boxes, 1, ptr_g,
				 old_x-x_koor, old_y-y_koor);

		zielwhdl = wind_find(ev.x, ev.y);
		if	(!ica_get_zielobj(ev.x, ev.y, zielwhdl, &zieltree,
				&zielobj, &set_icon, &malen) &&
			 !icp_get_zielobj(ev.x, ev.y, zielwhdl, &zieltree,
				&zielobj, &set_icon, &malen) &&
			 !spc_get_zielobj(ev.x, ev.y, zielwhdl, &zieltree,
				&zielobj, &set_icon, &malen))
			{
			zieltree = NULL;
			zielobj = -1;
			}

		if	(zieltree != alttree || zielobj != altobj)
			{
			if	(alttree && altobj > 0)
				{
				altmalen(altobj);
				}
			if	(zieltree && zielobj > 0)
				{
				ob_sel(zieltree, zielobj);
				malen(zielobj);
				ob_dsel(zieltree, zielobj);
				}
			alttree = zieltree;
			altobj  = zielobj;
			altmalen = malen;
			}
		}
	while(ev.bstate & 1);

	if	(zielobj > 0)
		{
		malen(zielobj);
		set_icon(objnr - 1, zielobj);
		}
	graf_mouse(ARROW, NULL);
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);

}


/*******************************************************************
*
* Mausklick
*
*******************************************************************/

#pragma warn -par
static void button_iconsel( WINDOW *w, int kstate,
				int x, int y, int button, int nclicks )
{
	int	objnr;
	EVNTDATA ev;


	objnr = find_obj(w->tree, x, y);
	if	(objnr <= 0)
		return;
	if	(nclicks == 2)
		{
		ica_dial_set_icon(objnr - 1);
		icp_dial_set_icon(objnr - 1);
		spc_dial_set_icon(objnr - 1);
		return;
		}
	graf_mkstate(&ev.x, &ev.y, &ev.bstate, &ev.kstate);
	if	(ev.bstate & 1)
		{
		move_icons(x, y, w->tree, objnr);
		return;
		}

	if	(selected(w->tree, objnr))
		ob_dsel(w->tree, objnr);
	else	ob_sel(w->tree, objnr);
	obj_malen(w->handle, w->tree, objnr);
}
#pragma warn .par


/*******************************************************************
*
* Initialisierung
*
*******************************************************************/

void init_iconsel( void )
{
	WINDEFPOS *w;

	w = def_wind_pos("ICONS");
	if	(w)
		{
		iconwindow.out = w->g;
		}
	else	{
		iconwindow.out = scrg;
		}
}


/*******************************************************************
*
* Initialisierung
*
*******************************************************************/

#pragma warn -par
static void close_iconsel( WINDOW *w, int kstate )
{
	WINDEFPOS *wd;
	WINDOW **sw;

	wd = def_wind_pos("ICONS");
	if	(wd)
		wd->g = iconwindow.out;

	wind_close(w->handle);
	wind_delete(w->handle);
	Mfree(w->tree);
	sw = find_slot_window(w);
	mywindow = NULL;
	*sw = NULL;
}
#pragma warn .par


/*******************************************************************
*
* Fenster îffnen
*
*******************************************************************/

int open_iconsel( void )
{
	WINDOW **w;
	register OBJECT *o,*sob;
	ICONBLK *icb;
	register int i;


	if	(mywindow)		/* schon geîffnet */
		{
		wind_set(WF_TOP, mywindow->handle, 0,0,0,0);
		return(0);	/* OK */
		}
	w = new_window();
	if	(!w)
		return(-1);		/* kein Slot */
	iconwindow.handle = wind_create(NAME+CLOSER+FULLER+MOVER+
						SIZER+UPARROW+DNARROW+VSLIDE,
						&scrg);

	iconwindow.tree = Malloc(sizeof(OBJECT) * (icnn+1));
	if	(!iconwindow.tree)
		return(-3);

	if	(iconwindow.handle < 0)
		{
		Mfree(iconwindow.tree);
		return(-2);		/* kein AES-Fenster */
		}

	/* Baum aufbauen */

	o = iconwindow.tree;
	/* Objekt der weiûen Hintergrundbox */
	o -> ob_next = -1;
	o -> ob_type = G_BOX;
	o -> ob_state = NORMAL;
	o -> ob_spec.index = (long) (WHITE);
	if	(icnn > 0)
		{
		o -> ob_flags = NONE;
		o -> ob_head = 1;
		o -> ob_tail = icnn;
		}
	else {
		o -> ob_flags = LASTOB;
		o -> ob_head = o -> ob_tail = -1;
		}

	iconwindow.max_hicon = 0;
	for	(i = 1; i <= icnn; i++)
		{
		o++;
		o -> ob_next = (i < icnn) ? (i+1) : (0);
		o -> ob_head = o -> ob_tail = -1;
		o -> ob_flags = (i < icnn) ? NONE : LASTOB;
		sob = rscx[icnx[i-1].rscfile].adr_icons + icnx[i-1].objnr;

		icb = NULL;
		if	(sob -> ob_type == G_USERDEF)
			icb = (ICONBLK *) sob->ob_spec.userblk->ub_parm;
		else
		if	((sob -> ob_type == G_ICON) ||
			 (sob -> ob_type == G_CICON))
			icb = sob->ob_spec.iconblk;
		else icb = NULL;

		if	(icb && (icb->ib_hicon > iconwindow.max_hicon))
			iconwindow.max_hicon = icb->ib_hicon;

		o->ob_type   = sob->ob_type;
		o->ob_width  = sob->ob_width;
		o->ob_height = sob->ob_height;
		o->ob_spec   = sob->ob_spec;
		o->ob_state  = NORMAL+WHITEBAK;
		}

	init_window(&iconwindow);
	iconwindow.flags = 0;
	iconwindow.is_1col = FALSE;
	iconwindow.showw = 72;
	iconwindow.showh = iconwindow.max_hicon + 8;
	iconwindow.shownum = icnn;
	iconwindow.xoffs = WXOFFS;
	iconwindow.yoffs = WYOFFS;
	iconwindow.xdist = WXDIST;
	iconwindow.ydist = WYDIST;
	iconwindow.button = button_iconsel;
	iconwindow.close = close_iconsel;
	*w = mywindow = &iconwindow;
	wind_set_str(iconwindow.handle, WF_NAME,
				Rgetstring(STR_WTIT_ICONS, NULL));
	iconwindow.open(&iconwindow);
	wind_set(iconwindow.handle, WF_BEVENT, 0x0001, 0, 0, 0 );
	return(0);
}
