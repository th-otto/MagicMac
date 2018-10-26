/*******************************************************
*
* WDIALOG
* =======
*
* Bibliothek fÅr Dialogboxen in Fenstern
*
*******************************************************/

#define DEBUG 0

#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#if	DEBUG
#include <stdio.h>
#else
#include <stddef.h>
#endif
#include <magx.h>
#include "gemutils.h"
#include "wdialog.h"

static DIALOG *diags = NULL;		/* verkettete Liste aller Dialoge */


#ifndef FL3DMASK

#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200
#define FL3DBAK      0x0400
#define FL3DACT      0x0600

#endif


/****************************************************************
*
* Ermittelt die Objektnummer des ersten EDITABLE Objekts
*
****************************************************************/

static int get_1st_edit( OBJECT *tree )
{
	register int i;

	i = 0;
	do	{
		if	((tree->ob_flags) & EDITABLE)
			return(i);
		tree++;
		i++;
		}
	while(!((tree->ob_flags) & LASTOB));
	return(-1);
}


/******************************************************
*
* Ermittelt zu <whdl> die zugehîrige Struktur.
*
******************************************************/

static DIALOG *whdl_to_dialog(int whdl)
{
	DIALOG 	*alt;


	alt = diags;
	if	(alt)
		{
		do	{
			if	(alt->whdl == whdl)
				return(alt);
			alt = alt->next;
			}
		while(alt);
		}
	return(NULL);
}


/******************************************************
*
* Ermittelt zu <handle_exit()> die zugehîrige Struktur.
*
******************************************************/

static DIALOG *handle_exit_to_dialog(void *handle_exit)
{
	DIALOG 	*alt;


	alt = diags;
	if	(alt)
		{
		do	{
			if	(alt->handle_exit == handle_exit)
				return(alt);
			alt = alt->next;
			}
		while(alt);
		}
	return(NULL);
}


/******************************************************
*
* Erledigt den Redraw (Åber die Rechteckliste).
*
******************************************************/

void wdlg_xredraw(DIALOG *d, GRECT *neu, int startob, int depth)
{
	GRECT w;

	Mgraf_mouse(M_OFF);
	wind_get(d->whdl,WF_FIRSTXYWH,&(w.g_x),&(w.g_y),&(w.g_w),&(w.g_h));
	do	{
		if	(rc_intersect(neu,&w))
			{
			objc_draw(d->tree, startob, depth, w.g_x, w.g_y, w.g_w, w.g_h);
			if	(d->act_editob > 0)
				{
				_GemParBlk.addrin[1] = &w;
				objc_edit(d->tree, d->act_editob, 0, &(d->cursorpos), ED_DRAW);
				}
			}
		wind_get(d->whdl,WF_NEXTXYWH,&(w.g_x),&(w.g_y),&(w.g_w),&(w.g_h));
		}
	while(w.g_w > 0);					/* bis Rechteckliste vollstÑndig */
	Mgraf_mouse(M_ON);
}


/******************************************************
*
* Erledigt den Redraw (Åber die Rechteckliste).
*
******************************************************/

void wdlg_redraw(DIALOG *d, GRECT *neu)
{
	wdlg_xredraw(d, neu, 0, 8);
}


/****************************************************************
*
* Malt ein Unterobjekt.
*
****************************************************************/

void subobj_wdraw(DIALOG *d, int obj, int startob, int depth)
{
	GRECT g;

	objc_grect(d->tree, obj, &g);
	wdlg_xredraw(d, &g, startob, depth);
}


/******************************************************
*
* Erstellt das Fenster und initialisisiert einige
* Variablen.
* Gibt das Handle des erstellten Fensters zurÅck.
*
******************************************************/

int wdlg_init( char *title, int kind, int x, int y, char *ident,
			int	 (*handle_exit)( DIALOG *d, int objnr, int clicks, void *data ),
			int	 code, void *data )
{
	OBJECT 	*dialog_tree;
	DIALOG 	*neu,*alt;
	int		cx,cy,cw,ch;
	int		retcode;


	if	((neu = (DIALOG *) Malloc(sizeof(DIALOG))) == NULL)
		return(-1);
	retcode = (*handle_exit)(neu, -1, code, data);	/* Initialisierung */
	if	(retcode == -2)	/* Dialog schon geîffnet */
		{
		Mfree(neu);
		neu = handle_exit_to_dialog(handle_exit);
		if	(!neu)
			return(-1);		/* nicht gefunden: Fehler */
		wind_set(neu->whdl, WF_TOP);
		return(neu->whdl);
		}
	if	(retcode < 0)		/* Fehler */
		{
		Mfree(neu);
		return(-1);
		}
	dialog_tree = neu->tree;
	dialog_tree[0].ob_state &= ~OUTLINED;
	dialog_tree[0].ob_spec.obspec.framesize = 0;
	form_center(dialog_tree, &cx, &cy, &cw, &ch);
	if	(cy < 2*gl_hhbox)
		cy = dialog_tree->ob_y = 2*gl_hhbox;		/* Fenstertitel sichtbar! */
	if	((x != -1) || (y != -1))
		{
		if	(y < 2*gl_hhbox)
			y = 2*gl_hhbox;		/* Fenstertitel sichtbar! */
		cx = dialog_tree->ob_x = x;
		cy = dialog_tree->ob_y = y;
		}
	wind_calc(WC_BORDER, kind,
			cx, cy, cw, ch,
			&(neu->out.g_x),
			&(neu->out.g_y),
			&(neu->out.g_w),
			&(neu->out.g_h));
	if	((neu->whdl = wind_create(kind,
					neu->out.g_x,
					neu->out.g_y,
					neu->out.g_w,
					neu->out.g_h)) < 0)
		{
		Mfree(neu);
		return(-1);
		}
	if	(ident)
		strncpy(neu->ident, ident, 32);
	else	neu->ident[0] = EOS;
	neu->handle_exit = handle_exit;
	neu->next = NULL;
	alt = (DIALOG *) &diags;
	while(alt->next)
		alt = alt->next;
	alt->next = neu;
	if	(title)
		wind_set(neu->whdl, WF_NAME, title);
	wind_open(neu->whdl,
			neu->out.g_x,
			neu->out.g_y,
			neu->out.g_w,
			neu->out.g_h);
	neu->act_editob = get_1st_edit(dialog_tree);
	if	(neu->act_editob > 0)
		{
		int rett_w,rett_h;

		rett_w = neu->tree[neu->act_editob].ob_width;
		rett_h = neu->tree[neu->act_editob].ob_height;
		neu->tree[neu->act_editob].ob_width  = 1;
		neu->tree[neu->act_editob].ob_height = 1;
		objc_edit(neu->tree, neu->act_editob, 0, &(neu->cursorpos), ED_INIT);
		neu->tree[neu->act_editob].ob_width  = rett_w;
		neu->tree[neu->act_editob].ob_height = rett_h;
		}

	/* Neu: evtl. Initialisierung nach dem ôffnen! */
	if	(retcode == 2)
		(*handle_exit)(neu, -5, code, data);

	return(neu->whdl);
}


/******************************************************
*
* Lîscht das Fenster und gibt die allozierten
* Strukturen frei.
*
******************************************************/

int wdlg_exit(int whdl)
{
	DIALOG 	*alt,*prev;


	prev = (DIALOG *) &diags;
	alt = diags;
	while(alt)
		{
		if	(alt->whdl == whdl)
			goto found;
		prev = alt;
		alt = alt->next;
		}
	return(-1);
	found:
	prev->next = alt->next;
	wind_close(whdl);
	wind_delete(whdl);
	Mfree(alt);
	return(0);
}


/******************************************************
*
* Verarbeitet eine Fenster-Nachricht bzw. Nachrichten
* mit Code >= 1040.
* Röckgabe 1, wenn Dialog beendet.
*
******************************************************/

static int wdlg_mesag(DIALOG *d, int message[16])
{
	int retcode;


	switch(message[0]) {
		case WM_REDRAW:	wdlg_redraw(d, (GRECT *) (message+4));
						break;
		case WM_TOPPED:	wind_set(d->whdl, WF_TOP);
						break;
		case WM_CLOSED:	retcode = (*(d->handle_exit))(d, -3, 0, NULL);
						if	(!retcode)
							wdlg_exit(d->whdl);
						return(retcode);

		/* case WM_FULLED:	*/
		/* case WM_ARROWED:	*/
		/* case WM_HSLID:	*/
		/* case WM_VSLID:	*/
		/* case WM_SIZED:	*/
		case WM_MOVED:		wind_set(d->whdl, WF_CURRXYWH,
								message[4],
								message[5],
								message[6],
								message[7]);
						d->tree[0].ob_x += message[4] - d->out.g_x;
						d->tree[0].ob_y += message[5] - d->out.g_y;
						d->out.g_x = message[4];
						d->out.g_y = message[5];
						break;
		/* case WM_NEWTOP:	*/
		/* case WM_UNTOPPED:*/

		default:			retcode = (*(d->handle_exit))(d, -2, 0, message);
						if	(!retcode)
							{
							wdlg_exit(d->whdl);
							return(retcode);
							}
						break;

		}
	return(0);
}


/****************************************************************
*
* Der Benutzer hat an der Bildschirmposition (x_koor,y_koor) mit
* dem <knopf> einen <anzahl>- fachen Mausklick ausgefÅhrt.
* RÅckgabe:	0	alles OK, Klick verarbeitet/ignoriert
*			<0	Fehler
*			>0	Exitbutton wurde bearbeitet
*
****************************************************************/

#pragma warn -par

static int wdlg_button(DIALOG *d, int anzahl, int x_koor, int y_koor, int knopf, int kbsh)
{
	int no_exit;
	int objnr;
	int neu_editob;


	if	(knopf != 1)
		return(1);

	if	(anzahl)
		{
		objnr = objc_find(d->tree, 0, 8, x_koor, y_koor);
		if	(objnr < 0)
			return(1);
		if	(((d->tree+objnr)->ob_state) & DISABLED)
			return(1);
		}
	else {
		objnr = x_koor;
		anzahl = 1;
		}

	no_exit = form_button(d->tree, objnr, anzahl, &neu_editob);
	neu_editob &= 0x7fff;	/* Doppelklickbit lîschen */
	if	(!no_exit)
		{
		int retcode;

		retcode = (*(d->handle_exit))(d, neu_editob, anzahl, NULL);
		if	(!retcode)
			wdlg_exit(d->whdl);
		return(retcode);
		}

	if	(neu_editob > 0)
		{
		if	((d->act_editob != neu_editob) || (objnr == neu_editob))
			{
			/* Cursor im alten Editfeld ausschalten */
			objc_edit(d->tree, d->act_editob, 0, &(d->cursorpos), ED_END);
			/* Cursor aufs neue Editfeld */
			d->act_editob = neu_editob;
			objc_edit(d->tree, d->act_editob, x_koor, &(d->cursorpos), ED_CRSR);
			}
		}
	return(1);
}

#pragma warn +par

/******************************************************
*
* Verarbeitet eine Fenster-Taste
*
******************************************************/

static int wdlg_key(DIALOG *d, int keycode, int kbsh)
{
	int	no_exit;
	int	neu_editob;
	int	retcode;


	/* Abfrage auf ALT-Taste */
	if	(kbsh == K_ALT)
		{
		if	(form_keybd(d->tree, 0x8765, d->act_editob, keycode,
			 	&(neu_editob), &keycode))
		 	{
			return(wdlg_button(d, 0, neu_editob, 0, 1, kbsh));
		 	}

		}

	no_exit = form_keybd(d->tree, d->act_editob, d->act_editob, keycode,
			 	&neu_editob, &keycode);

	if	(keycode)		/* noch nicht verarbeitet */
		{
		objc_edit(d->tree, d->act_editob, keycode, &(d->cursorpos), ED_CHAR);
		}
	else	{
		if	((neu_editob != d->act_editob) && no_exit)
			{
			if	(d->act_editob > 0)
				objc_edit(d->tree, d->act_editob, 0, &(d->cursorpos), ED_END);
			if	(neu_editob > 0)
				objc_edit(d->tree,    neu_editob, 0, &(d->cursorpos), ED_INIT);
			d->act_editob = neu_editob;
			}
		}

	if	(no_exit)
		return(1);
	retcode = (*(d->handle_exit))(d, neu_editob, 1, NULL);
	if	(!retcode)
		wdlg_exit(d->whdl);
	return(retcode);
}


/******************************************************
*
* Verarbeitet einen Event
* mwhich		Bitmaske von evnt_multi,
*			bearbeitete werden gelîscht
*
* RÅckgabe > 0:	letzter Dialog geschlossen
*		 < 0:	Fehler
*
******************************************************/

int wdlg_evnt(int *mwhich, int message[16], int kreturn, int kstate,
			int button, int anzclicks, int mox, int moy)
{
	extern int top_whdl( void );
	DIALOG *d;
	int topw;
	int retcode;



	retcode = 0;

	/* Abfrage auf Empfang einer Nachricht */
	/* ----------------------------------- */

	if	((*mwhich & MU_MESAG) &&(
		 ((message[0] >= 20) && (message[0] < 40)) ||		/* WM_XX */
		 (message[0] >= 1040)))
		{
		d = whdl_to_dialog(message[3]);
		if	(d)
			{
			*mwhich &= ~MU_MESAG;
			retcode = wdlg_mesag(d, message);
			}
		}

	/* Wenn kein Button und keine Taste:	*/
	/* Kein wind_update erforderlich!		*/
	/* ------------------------------------ */

	if	(!(*mwhich & (MU_KEYBD+MU_BUTTON)))
		return(diags == NULL);

	wind_update(BEG_UPDATE);
	topw = top_whdl();
	d = whdl_to_dialog(topw);
	if	(!d)
		goto ende;			/* kein Fenster von unseren ist oberstes */


	/* Abfrage auf BetÑtigung einer Taste */
	/* ---------------------------------- */

	if	(*mwhich & MU_KEYBD)
		{
		retcode |= wdlg_key(d, kreturn, kstate);
		*mwhich &= ~MU_KEYBD;
		}


	/* Abfrage auf BetÑtigung eines Mausknopfs */
	/* --------------------------------------- */

	if	(*mwhich & MU_BUTTON)
		{
		int mywin;

		mywin = wind_find(mox, moy);
		if	(mywin == topw)
			{
			retcode |= wdlg_button(d, anzclicks, mox, moy,button, kstate);
			*mwhich &= ~MU_BUTTON;
			}
		}

	ende:
	wind_update(END_UPDATE);
	if	(retcode < 0)
		return(retcode);
	else return(diags == NULL);
}
