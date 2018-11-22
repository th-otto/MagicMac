/****************************************************************
*
* PDLG
* ====
*
****************************************************************/

#include <portab.h>
#include <tos.h>
#include <aes.h>
#include <mt_aes.h>
#include <wdlgwdlg.h>
#include <wdlgedit.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>



static PRN_DIALOG *d_dialog;
static PRN_SETTINGS *settings;
static WORD gl_hhbox;
static WORD gl_hwbox;
static WORD gl_hhchar;
static WORD gl_hwchar;
static WORD ap_id;
static WORD aes_handle;							/* Screen-Workstation des AES */

/* fr die SharedLib */
static SLB_EXEC slbexec;
static SHARED_LIB slb;


/*********************************************************************
*
* Objekte deselektieren/selektieren/Status abfragen
*
*********************************************************************/

static WORD selected(OBJECT *tree, WORD which)
{
	return (tree[which].ob_state & SELECTED) ? 1 : 0;
}

static void ob_dsel(OBJECT *tree, WORD which)
{
	tree[which].ob_state &= ~SELECTED;
}

static void ob_sel_dsel(OBJECT *tree, WORD which, WORD sel)
{
	if (sel)
		tree[which].ob_state |= SELECTED;
	else
		tree[which].ob_state &= ~SELECTED;
}

static void ob_sel(OBJECT *tree, WORD which)
{
	tree[which].ob_state |= SELECTED;
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

static void objc_grect(OBJECT *tree, WORD objn, GRECT *g)
{
	OBJECT *o;
	WORD x, y, nx, ny;

	o = tree + objn;
	objc_offset(tree, objn, &nx, &ny);
	if ((o->ob_type == G_BUTTON || o->ob_type == G_FTEXT) && (o->ob_flags & FL3DMASK))
	{
		x = o->ob_x;
		y = o->ob_y;
		form_center_grect(o, g);
		g->g_x += nx - o->ob_x;
		g->g_y += ny - o->ob_y;
		o->ob_x = x;
		o->ob_y = y;
	} else
	{
		g->g_x = nx;
		g->g_y = ny;
		g->g_w = o->ob_width;
		g->g_h = o->ob_height;
	}
}


/*********************************************************************
*
* Prft, ob der Mausklick ins Objekt ging.
*
*********************************************************************/

static WORD xy_in_grect(WORD x, WORD y, GRECT * g)
{
	return x >= g->g_x && x < g->g_x + g->g_w && y >= g->g_y && y < g->g_y + g->g_h;
}


/*********************************************************************
*
* Ermittelt zu einem vollen Pfadnamen den Zeiger auf den
* reinen Dateinamen
*
*********************************************************************/

static char *get_name(char *path)
{
	register char *n;

	n = strrchr(path, '\\');
	if (!n)
	{
		if ((*path) && (path[1] == ':'))
			path += 2;
		return path;
	}
	return n + 1;
}


/****************************************************************
*
* Malt ein Unterobjekt eines Fensters
*
****************************************************************/

static void subobj_wdraw(void *d, WORD obj, WORD startob, WORD depth)
{
	OBJECT *tree;
	GRECT g;

	wdlg_get_tree(d, &tree, &g);
	objc_grect(tree, obj, &g);
	wdlg_redraw(d, &g, startob, depth);
}

#define	GAI_WDLG	0x0001	/* wdlg_xx()-functions available */
#define	GAI_LBOX	0x0002	/* lbox_xx()-functions available */
#define	GAI_FNTS	0x0004	/* fnts_xx()-functions available */
#define	GAI_FSEL	0x0008	/* new file selector (fslx_xx) available */
#define	GAI_PDLG	0x0010	/* pdlg_xx()-functions available */

int main(void)
{
	EVNT w_ev;
	WORD whdl_dialog = 0;
	LONG err;
	int ret = 1;
	WORD dummy;
	WORD agi;
	WORD button;
	
	if ((ap_id = appl_init()) < 0)
		return 1;

	graf_mouse(ARROW, NULL);

	appl_xgetinfo(AES_WDIALOG, &agi, &dummy, &dummy, &dummy);

	if (!(agi & GAI_PDLG))
	{
		/* SharedLib laden */
		/* --------------- */
		err = Slbopen("pdlg.slb", NULL, 1L, &slb, &slbexec);
		if (err < 0)
		{
			form_alert(1, "[1][Cannot load pdlg.slb][Cancel]");
			goto error;
		}
	}		

	appl_xgetinfo(AES_WDIALOG, &agi, &dummy, &dummy, &dummy);

	if (!(agi & GAI_PDLG))
	{
		form_alert(1, "[1][PDLG functions not available][Cancel]");
		goto error;
	}
		
	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	d_dialog = pdlg_create(PDLG_3D);
	
	if (!d_dialog)
	{
		form_alert(1, "[1][Cannot create dialog][Cancel]");
		goto error;
	}
	settings = pdlg_new_settings(d_dialog);
	
	whdl_dialog = pdlg_open(d_dialog, settings, "hello.doc", PDLG_ALWAYS_COPIES|PDLG_ALWAYS_ORIENT|PDLG_ALWAYS_SCALE|PDLG_EVENODD|PDLG_PRINT, 0, 0);
	if (!whdl_dialog)
	{
		form_alert(1, "[1][Cannot create window][Cancel]");
		goto error;
	}

	for (;;)
	{
		w_ev.mwhich = evnt_multi(MU_KEYBD + MU_BUTTON + MU_MESAG, 2,	/* Doppelklicks erkennen    */
								 1,		/* nur linke Maustaste      */
								 1,		/* linke Maustaste gedrckt */
								 0, 0, 0, 0, 0,	/* kein 1. Rechteck         */
								 0, 0, 0, 0, 0,	/* kein 2. Rechteck         */
								 w_ev.msg, 0L,	/* ms */
								 &w_ev.mx, &w_ev.my, &w_ev.mbutton, &w_ev.kstate, &w_ev.key, &w_ev.mclicks);
		
		button = 0;
		if (pdlg_evnt(d_dialog, settings, &w_ev, &button) == 0 && button != 0)
		{
			pdlg_close(d_dialog, NULL, NULL);
			whdl_dialog = 0;
			pdlg_delete(d_dialog);
			d_dialog = NULL;
			break;
		}

		if (w_ev.mwhich & MU_MESAG)
		{
			if (w_ev.msg[0] == AP_TERM)
				break;
		}
	}
	ret = 0;
	
  error:
  	if (whdl_dialog)
		pdlg_close(d_dialog, NULL, NULL);
  	if (d_dialog)
		pdlg_delete(d_dialog);
	if (settings)
		pdlg_free_settings(settings);
	if (slb)
		Slbclose(slb);
	appl_exit();
	return ret;
}
