/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Icons fÅr Pfade/Ordner/Disks auswÑhlen"
*
*/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "applicat.h"
#include "appl.h"
#include "appldata.h"
#include "pth_dial.h"
#include "iconsel.h"
#include "icp_dial.h"


/* Das "Fenster" */

static void *sbox;

static struct pth_file *selected_path = NULL;
static int visible_len = -1;


/*********************************************************************
*
* Umrechnungen
*
*********************************************************************/

static int showindex_to_icnobj(int index)
{
	static int icons[] =
		{FLICON1,FLICON2,FLICON3,FLICON4,FLICON5};

	return(icons[index]);
}
static int icnobj_to_showindex(int objnr)
{
	switch(objnr)
		{
		case FLICON1: return(0);
		case FLICON2: return(1);
		case FLICON3: return(2);
		case FLICON4: return(3);
		case FLICON5: return(4);
		}
	return(-1);
}
static int pthobj_to_showindex(int objnr)
{
	switch(objnr)
		{
		case FLD1:	return(0);
		case FLD2:	return(1);
		case FLD3:	return(2);
		case FLD4:	return(3);
		case FLD5:	return(4);
		}
	return(-1);
}


/*********************************************************************
*
* KÅrzt einen Pfadnamen sinnvoll ab.
* Der Pfad muû mit X:\ beginnen.
* Er wird, wenn er zu lang ist, auf
*
*	X:\...\lastdirs
*
* gekÅrzt.
*
*********************************************************************/

void abbrev_path(char *dst, char *src, int len )
{
	register char *t,*u;
	int l;

	if	((l = (int) strlen(src)) < len)
		{
		strcpy(dst, src);
		return;
		}
	
	u = t = src + l - len + 6;
	while((*t) && (*t != '\\'))
		t++;
	*dst++ = *src++;	/* "X:\" */
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = '.';
	*dst++ = '.';
	*dst++ = '.';
	if	(!(*t) || !(t[1]))
		strcpy(dst, u);
	else	strcpy(dst, t);
}


/*********************************************************************
*
* Scrolle den Inhalt des "Fensters" so, daû die Zeile fÅr
* den Pfad <path> oben sichtbar ist.
*
* Wenn <path> nicht gefunden, RÅckgabe -1
*
*********************************************************************/

static int scroll_win_path( DIALOG *d, char *path )
{
	register struct pth_file *pth;
	register int n;

	for	(n = 0,pth = pthx; n < pthn; n++,pth++)
		if	(!stricmp(pth->path, path))
			goto found;
	return(-1);
	found:
	adr_icp_dialog[DEL_FLD].ob_state &= ~DISABLED;
	selected_path = pth;
	if	((n > 0) && (n > pthn - 5))
		n = pthn - 5;
	if	(n < 0)
		n = 0;
	pth->sel = TRUE;
	lbox_scroll_to(sbox, n, NULL, NULL);
	if	(d)
		subobj_wdraw(d_icp, FL_BK, FL_BK, MAX_DEPTH);
	return(0);
}


/*********************************************************************
*
* Auswahl- und Setzroutinen fÅr die Scrollbox
*
*********************************************************************/

#pragma warn -par
static void cdecl select_item( LIST_BOX *box, OBJECT *tree,
			LBOX_ITEM *item, void *user_data,
			WORD obj_index, WORD last_state )
{
	struct pth_file *mypth = (struct pth_file *) item;

	if	(mypth->sel)
		selected_path = mypth;
	else	selected_path = NULL;
}

static WORD cdecl set_item( LIST_BOX *box, OBJECT *tree,
			LBOX_ITEM *item, WORD index,
			void *user_data, GRECT *rect, WORD offset )
{
	struct pth_file *mypth = (struct pth_file *) item;
	OBJECT *dob;
	OBJECT *sob;
/*	int len;	*/
	struct icon *ic;
	int ic_height,ob_height;


	if	(!item)
		{
		dob = tree+index;
		dob->ob_spec.tedinfo->te_ptext[1] = EOS;
		dob->ob_flags &= ~TOUCHEXIT;
		dob = tree+dob->ob_head;
		dob->ob_flags |= HIDETREE;
		return(index);
		}

	ob_height = tree[index].ob_height;

	/* Text */

	dob = tree+index;
	dob->ob_flags &= ~HIDETREE;
	dob->ob_flags |= TOUCHEXIT;
	abbrev_path(dob -> ob_spec.tedinfo->te_ptext+1,
			mypth->path, visible_len);
/*	len = (int) strlen(dob -> ob_spec.tedinfo->te_ptext+1);	*/
	if	(mypth->sel)
		ob_sel(dob, 0);
	else	ob_dsel(dob, 0);
/*	dob->ob_width = len * gl_hwchar;	*/
	ic = icnx + mypth->iconnr;

	/* Icons */

	dob = tree+dob->ob_head;
	dob->ob_flags &= ~HIDETREE;

	if	(item->selected)
		dob->ob_state &= ~WHITEBAK;
	else	dob->ob_state |= WHITEBAK;

/*
	if	(mypth->sel_icon)
		ob_sel(dob, 0);
	else	ob_dsel(dob, 0);
*/
	sob = rscx[ic->rscfile].adr_icons + ic->objnr;
	ic_height = sob->ob_spec.ciconblk->monoblk.ib_hicon+8;
	dob -> ob_y = ob_height - ic_height - 2;
	dob -> ob_spec	= sob -> ob_spec;
	dob -> ob_type	= sob -> ob_type;
	dob -> ob_width	= sob -> ob_width;
	dob -> ob_height	= sob -> ob_height;

/*
	if	(rect)
		{
		rect->g_x += xpos_textob;
		rect->g_w = visible_len*gl_hwchar;
		}
*/
	return(index);
}
#pragma warn .par


/*********************************************************************
*
* Verkette die Objekte
*
*********************************************************************/

static LBOX_ITEM *cat_paths( void )
{
	register int i;
	register struct pth_file *pth;
	LBOX_ITEM *sc;

	/* Verkette die "pth_file"-Strukturen */
	for	(i = 0,pth = pthx; i < pthn-1; i++,pth++)
		{
		pth->next = pth+1;
		}
	if	(pthn)
		{
		sc = (LBOX_ITEM *) pthx;
		pthx[pthn-1].next = NULL;
		}
	else	sc = NULL;
	return(sc);
}


/*********************************************************************
*
* Initialisierung der Objektklasse "Icon fÅr Pfad auswÑhlen"
*
*********************************************************************/

void icp_dial_init_rsc( void )
{
	int /* dummy,*/ i;
	static int ctrl_objs[5] =
		{FL_BK, FL_UP, FL_DOWN, FL_BSL, FL_SLID};
	static int objs[5] =
		{FLD1,FLD2,FLD3,FLD4,FLD5};


	if	(!is_3d)
		{
		adr_icp_dialog[ctrl_objs[3]].ob_spec.obspec.fillpattern = 1;
		for	(i = 1; i < 5; i++)
			adr_icp_dialog[ctrl_objs[i]].ob_spec.obspec.framesize = 1;
		}

	adr_icp_dialog[DEL_FLD].ob_state |= DISABLED;

	visible_len = (int) strlen(adr_icp_dialog[FLD1].ob_spec.tedinfo->te_ptext+1);

	sbox = lbox_create(	adr_icp_dialog,
					select_item,
					set_item,
					cat_paths(),	/* Items */
					5,		/* Anzahl sichtbarer EintrÑge */
					0,		/* erster sichtbarer Eintrag */
					ctrl_objs,
					objs,
					LBOX_VERT+LBOX_REAL+LBOX_SNGL+LBOX_TOGGLE,
					20,		/* Scrollverzîgerung */
					NULL,	/* user data */
					NULL,
					0,0,0,0
					);
	if	(!sbox)
		Pterm((int) ENSMEM);
}


/*********************************************************************
*
* Lîscht einen Pfad.
*
*********************************************************************/

static int delete_pth( int pth )
{
	register struct pth_file *p;
	register int i;

	for	(i = pth,p = pthx+pth; i < pthn-1; i++,p++)
		{
		*p = *(p+1);
		}
	pthn--;
	lbox_set_items(sbox, cat_paths());
	lbox_set_slider(sbox, lbox_get_first(sbox), NULL);

	/* AufrÑumarbeiten */
	/* --------------- */

	if	(d_icp)
		{
		lbox_update(sbox, NULL);
		subobj_wdraw(d_icp, FL_BK, FL_BK, MAX_DEPTH);
		subobj_wdraw(d_icp, FL_BSL, FL_BSL, MAX_DEPTH);
		}

	return(0);
}


/*********************************************************************
*
* TrÑgt einen neuen Pfad ein bzw Ñndert einen bestehenden.
* Die Pfade werden so sortiert, daû die absoluten Pfade, d.h. die,
* die mit "X:\" beginnen, vorn sind.
*
*********************************************************************/

int insert_pth( struct pth_file *new, struct pth_file *old )
{
	register int i,newpos;
	int is_abs;
	register struct pth_file *mypth;


	if	(!(new->path[0]))
		{
		err_form:
		Rform_alert(1, ALRT_PATH_INVAL, NULL);
		return(-1);			/* Pfad ist leer */
		}
	if	(new->path[1] == ':')
		{
		if	(new->path[2] != '\\')
			goto err_form;
		is_abs = TRUE;
		}
	else	is_abs = FALSE;

	/* Suche <new> in pthx[] */
	/* --------------------- */

	for	(i = 0,mypth = pthx; i < pthn; i++,mypth++)
		{
		if	(!stricmp(mypth->path, new->path))
			return(-2);		/* Pfad existiert schon */
		}

	/* Suche <old> in pthx[] */
	/* --------------------- */

	if	(old->path[0])
		{
		for	(newpos = 0,mypth = pthx; newpos < pthn;
				newpos++,mypth++)
			{
			/* entfernen! */
			if	(!stricmp(mypth->path, old->path))
				{
				for	(; newpos < pthn-1; newpos++,mypth++)
					{
					*mypth = *(mypth+1);
					}
				pthn--;
				break;
				}
			}
		}

	/* neuen Pfad erstellen (einsortieren) */
	/* ----------------------------------- */

	if	(datn >= MAX_DATN)
		{
		Rform_alert(1, ALRT_OVERFLOW, NULL);
		return(-3);		/* öberlauf */
		}
	for	(newpos = 0,mypth = pthx; newpos < pthn; newpos++,mypth++)
		{
		if	(is_abs && (mypth->path[1] != ':'))
			break;
		if	(!is_abs && (mypth->path[1] == ':'))
			continue;
		if	(stricmp(mypth->path, new->path) > 0)
			break;
		}
	for	(i = pthn; i > newpos; i--)
		pthx[i] = pthx[i-1];
	pthn++;

	/* eintragen */
	/* --------- */

	strcpy(pthx[i].path, new->path);
	pthx[i].iconnr = new->iconnr;
	pthx[i].sel = /* pthx[i].sel_icon = */ FALSE;

	/* AufrÑumarbeiten */
	/* --------------- */

	lbox_set_items(sbox, cat_paths());
	lbox_set_slider(sbox, i, NULL);
	lbox_update(sbox, NULL);
	if	(d_icp)
		{
		subobj_wdraw(d_icp, FL_BK, FL_BK, MAX_DEPTH);
		subobj_wdraw(d_icp, FL_BSL, FL_BSL, MAX_DEPTH);
		}

	return(0);
}


/*********************************************************************
*
* Deselektiert einen selektierte Pfad.
*
*********************************************************************/

static void deselect_path( DIALOG *d)
{
	adr_icp_dialog[DEL_FLD].ob_state |= DISABLED;
	subobj_wdraw(d, DEL_FLD, DEL_FLD, 1);
}


/*********************************************************************
*
* Das Icon fÅr Pfad <mypth> hat sich geÑndert.
*
*********************************************************************/

static void chg_icon(int mypth, int iconnr)
{
	OBJECT *sob,*dob;
	int n;
	struct icon *ic;
	register int i;


	if	(!d_icp)
		return;
	ic = icnx + iconnr;
	sob = rscx[ic->rscfile].adr_icons + ic->objnr;
	n = lbox_get_first(sbox);
	for	(i = 0; (i < 5) && (i+n < pthn); i++)
		{
		if	(i+n != mypth)
			continue;
		dob = adr_icp_dialog + showindex_to_icnobj(i);
		ob_dsel(dob, 0);
		dob->ob_spec = sob->ob_spec;
		dob->ob_type = sob->ob_type;
		dob->ob_width	= sob->ob_width;
		dob->ob_height	= sob->ob_height;
		subobj_wdraw(d_icp, showindex_to_icnobj(i),
					0, 8);
		}
}


/*********************************************************************
*
* Alle selektierten Icons als <iconnr> setzen.
*
*********************************************************************/

void icp_dial_set_icon( int iconnr )
{
	register int i;


	for	(i = 0; i < pthn; i++)
		{
		if	(pthx[i].sel)
			{
			pthx[i].iconnr = iconnr;
			chg_icon(i, iconnr);
			}
		}
}


/*********************************************************************
*
* Behandelt die Drag-Operation eines Icons auf ein Fenster.
*
*********************************************************************/

static void icp_set_icon(int iconnr, int objnr)
{
	int pth;

	pth = icnobj_to_showindex(objnr);
	if	(pth >= 0)
		{
		pth += lbox_get_first( sbox );
		pthx[pth].iconnr = iconnr;
		chg_icon(pth, iconnr);
		}
}

static void icp_malen(int objnr)
{
	if	(d_icp)
		subobj_wdraw(d_icp, objnr ,0, 8);
}

int icp_get_zielobj(int x, int y, int whdl, OBJECT **tree,
			int *objnr, void (**set_icon)(int iconnr, int objnr),
			void (**malen)(int objnr))
{
	GRECT dummy;

	if	(!d_icp)
		return(FALSE);		/* Objekt ungÅltig */
	if	(whdl != wdlg_get_handle(d_icp))
		return(FALSE);
	wdlg_get_tree(d_icp, tree, &dummy);
	*objnr = objc_find(*tree, 0, 8, x, y);
	if	(icnobj_to_showindex(*objnr) >= 0)
		{
		*set_icon = icp_set_icon;
		*malen = icp_malen;
		return(TRUE);
		}
	return(FALSE);
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Icondialogs
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*			<data> ist Zeiger auf Argumentzeiger,
*			d.h.		char *data[2]
*			<clicks> ist Parameter, z.Zt. immer 0
*		-2:	Nachricht int data[8] wurde Åbergeben
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*		-5:	Initialisierung _NACH_ ôffnen des Fensters
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/

#pragma warn -par

WORD cdecl hdl_icp( DIALOG *d, EVNT *ev, int exitbutton, int clicks, void *data )
{
	int pth;
	static char *path;
	OBJECT *tree;
	int retcode;
	struct dialog_userdata *du;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_icp_dialog;
	du = wdlg_get_udata(d);

	if	(exitbutton == HNDL_INIT)
		{
		if	(d_icp)			/* Dialog ist schon geîffnet ! */
			return(0);		/* create verweigern */

		if	(is_multiwindow)
			objs_disable(tree, FL_OK, FL_CN, 0);
		retcode = 1;			/* keine Aktion notwendig */

		if	((data) && (*((char **) data)))
			{
			path = *((char **) data);
			if	(0 > scroll_win_path( NULL, path ))
				retcode = 2;	/* Aktion notwendig ! */
			}

		du->mode = retcode;
		return(1);
		}

	/* 1a. Fall: Dialog ist geîffnet worden */
	/* ------------------------------------ */

	if	((exitbutton == HNDL_OPEN) && (du->mode == 2))
		{
		du->mode = 1;
		d_pth = xy_wdlg_init(
 				hdl_pth,
 				adr_newpath,
 				"PFAD_ANMELDEN",
 				1,
 				path,
 				STR_WTIT_DEFPATH);
		if	(!d_pth)
			Rform_alert(1, ALRT_ERRWINDOPEN, NULL);
		return(1);
		}


	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(exitbutton == HNDL_CLSD)
		{	/* Wenn Dialog geschlossen werden soll... */
		close_dialog:
		d_icp = NULL;
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(exitbutton < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

		/* Doppelklick auf Pfadnamen */
		/* ------------------------- */

	pth = pthobj_to_showindex(exitbutton);
	if	((clicks == 2) && (pth >= 0))
		{
		pth += lbox_get_first( sbox );
 		d_pth = xy_wdlg_init(
 				hdl_pth,
 				adr_newpath,
 				"PFAD_ANMELDEN",
 				0,
 				pthx + pth,
 				STR_WTIT_DEFPATH);
		if	(!d_pth)
			Rform_alert(1, ALRT_ERRWINDOPEN, NULL);
		return(1);
		}

		/* Doppelklick auf Icon */
		/* -------------------- */

	if	((clicks == 2) && (icnobj_to_showindex(exitbutton) >= 0))
		{
		open_iconsel();
		return(1);
		}


	if	(clicks != 1)
		goto ende;

	/* Scrollbox angewÑhlt */
	/* ------------------- */

	if	(exitbutton == FLICON1)
		exitbutton = FLD1;
	if	(exitbutton == FLICON2)
		exitbutton = FLD2;
	if	(exitbutton == FLICON3)
		exitbutton = FLD3;
	if	(exitbutton == FLICON4)
		exitbutton = FLD4;
	if	(exitbutton == FLICON5)
		exitbutton = FLD5;

	if	((exitbutton == FL_UP) ||
		 (exitbutton == FL_DOWN) ||
		 (exitbutton == FL_BSL) ||
		 (exitbutton == FL_SLID) ||
		 (exitbutton == FLD1) ||
		 (exitbutton == FLD2) ||
		 (exitbutton == FLD3) ||
		 (exitbutton == FLD4) ||
		 (exitbutton == FLD5))
		{
		lbox_do(sbox, exitbutton);

		/* select-Status geÑndert ? */

		if	(!selected_path &&
			 !(adr_icp_dialog[DEL_FLD].ob_state & DISABLED))
			{
			deselect_path(d);
			}
		if	(selected_path &&
			 (adr_icp_dialog[DEL_FLD].ob_state & DISABLED))
			{
			adr_icp_dialog[DEL_FLD].ob_state &= ~DISABLED;
			subobj_wdraw(d, DEL_FLD, DEL_FLD, 1);
			}
		return(1);
		}


		/* Neuen Pfad generieren */
		/* -------------------- */

	if	(exitbutton == NEU_FLD)
		{
 		d_pth = xy_wdlg_init(
 				hdl_pth,
 				adr_newpath,
 				"PFAD_ANMELDEN",
 				0,
 				NULL,
 				STR_WTIT_DEFPATH);
		if	(!d_pth)
			Rform_alert(1, ALRT_ERRWINDOPEN, NULL);
		goto ende;
		}

		/* Pfad lîschen */
		/* ------------ */

	if	(exitbutton == DEL_FLD)
		{
		if	(!selected_path)
			exit(-1);		/* ??? */
		deselect_path(d);
		delete_pth(selected_path-pthx);
		goto ende;
		}

		/* Buttons zur Dialogbeendigung */
		/* ---------------------------- */

	if	(exitbutton == FL_OK)			/* OK */
		{
		save_dialog_xy(d);
		if	(put_inf())
			goto ende;				/* Fehler bei INF */
		goto close_dialog;
		}

	if	(exitbutton == FL_CN)			/* Abbruch */
		{
		save_dialog_xy(d);
		goto close_dialog;
		}

	ende:
	ob_dsel(tree, exitbutton);
	subobj_wdraw(d, exitbutton, exitbutton, 1);
	return(1);		/* weiter */
}
#pragma warn +par
