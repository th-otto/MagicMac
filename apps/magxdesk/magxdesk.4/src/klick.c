/*********************************************************************
*
* Dieses Modul enthÑlt die Bearbeitung aller Mausklicks, also 
* Verschieben und Aktivierung von Icons, Doppelklicks in Fenster usw.
*
*********************************************************************/

#include <tos.h>
#include <vdi.h>
#include "k.h"
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "kobold.h"

#define NEWMOVE	1

static void destroy_all_selmasks( void );
static void mv_dskt_icns(int x, int y);
static void mk_dskt_icns(WINDOW *w, int xrel, int yrel);


/****************************************************************
*
* Das Objekt mit der Objektnummer <index> wird neu gemalt.
* (da es sich entweder verschoben hat oder der Status sich
*  geÑndert hat).
* Das Objekt liegt im Fenster mit Nummer <wnr> bzw. auf dem
* Desktop, wenn <wnr> = 0;
*
****************************************************************/

void obj_malen(WINDOW *w, int index)
{
	int		whdl;
	GRECT 	neu;
	OBJECT 	*tree;


	if	(index > w->shownum)
		return;
	whdl = w->handle;
	tree = w->pobj;
	objc_offset(tree, index, &(neu.g_x), &(neu.g_y));
	neu.g_w = (tree+index)->ob_width;
	neu.g_h = (tree+index)->ob_height;

	if	(((tree + index) -> ob_type == G_USERDEF) ||
		 ((tree + index) -> ob_state & WHITEBAK)
		)
		index = 0;
	objc_wdraw(tree, index, 1, &neu, whdl );
}


/****************************************************************
*
* Alle Auswahlen von Fenstern werden gelîscht.
*
****************************************************************/

static void destroy_all_selmasks( void )
{
	register int i;
	WINDOW **pw,*w;


	for	(i = 1,pw=fenster+1; i < ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && !(w->flags & WFLAG_ICONIFIED) &&
			w->sel_maske[0])
		 	dirty_info_selmask(w);
		}
}


/****************************************************************
*
* Alle Objekte in Fenstern und auf dem Desktop werden
* deselektiert und ggf. neu gezeichnet.
*
****************************************************************/

void dsel_all( void )
{
	OBJECT *tree;
	GRECT g;
	int   dummy;
	register int i;
	WINDOW **pw,*w;


	while(icsel(&w, &dummy))
		{
		tree = w->pobj;
		tree_sel_grect(tree, &g);
		if	((i = (tree -> ob_head)) > 0)
			for	(; i <= (tree -> ob_tail); i++)
				if	(selected(tree, i))
					ob_dsel(tree, i);
		redraw(w, &g);
		if	(g.g_w > 0)
			dirty_info_selmask(w);
		}
	for	(i = 1,pw=fenster+1; i < ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && !(w->flags & WFLAG_ICONIFIED) &&
			w->sel_maske[0])
		 	dirty_info_selmask(w);
		}
}


/****************************************************************
*
* Der ursprÅngliche Selektionsstatus steht in Bit 2 der MYDTAs.
* éndert ggf. den Selektionsstatus aller Unterobjekte von
* <tree>, die sich im Rechteck <*g> befinden, und zeichnet die
* jeweiligen Objekte neu.
* Gibt zurÅck, ob sich etwas geÑndert hat.
*
****************************************************************/

static int grect_toggle(WINDOW *w, char *sel_status, GRECT *g)
{
	register int i,rx,ry;
	register int mx,my,mrx,mry;	/* Maxima */
	int tx,ty;		/* Koordinaten des Wurzelobjekts */
	int x,y;			/* aktuelle Koordinaten */
	int toggle;		/* Flag "ist im Rechteck" */
	int tail;
	int newstate;
	GRECT  ob;
	register OBJECT *t = w->pobj;
	register ICONBLK *icn;
	int dirty = FALSE;


	tx = t -> ob_x;
	ty = t -> ob_y;

	mx = my = INT_MAX;		/* Ecke links oben */
	mrx = mry = -INT_MAX;	/* Ecke rechts unten (auûerhalb) */

	if	((i = (t -> ob_head)) > 0)
		{
		tail = (t++ -> ob_tail);
		for	(; i <= tail; i++,t++,sel_status++)
			{
			if	((HIDETREE+EXIT) & (t->ob_flags))
				continue;
			if	((t -> ob_type == G_ICON) || (t -> ob_type == G_CICON))
				{
				x = tx + t -> ob_x;
				y = ty + t -> ob_y;

				icn = t -> ob_spec.iconblk;
				/* 1. Fall: Icon selbst */
				ob.g_x = x + icn->ib_xicon;
				ob.g_y = y + icn->ib_yicon;
				ob.g_w = icn->ib_wicon;
				ob.g_h = icn->ib_hicon;
				if	(rc_intersect(g, &ob))
					toggle = TRUE;
				else	{
					/* 2. Fall: Unterschrift */
					ob.g_x = x + icn->ib_xtext;
					ob.g_y = y + icn->ib_ytext;
					ob.g_w = icn->ib_wtext;
					ob.g_h = icn->ib_htext;
					toggle = rc_intersect(g, &ob);
					}
				}
			/* 2. Fall: sonst (STRING bzw. G_USERDEF) */
			else {
				ob = *((GRECT *) (&(t->ob_x)));
				ob.g_x += tx;
				ob.g_y += ty;
				toggle = rc_intersect(g, &ob);
				}

			newstate = *sel_status;
			if	(toggle)
				newstate ^= SELECTED;

			if	(newstate != (t->ob_state & SELECTED))
				{
				t->ob_state &= ~SELECTED;
				t->ob_state |= newstate;
/*
				obj_malen((int) (w-fenster),
						(int) (mdta - w->pmydta)+1);
*/
				rx = t->ob_x;
				ry = t->ob_y;
				if	(rx < mx)
					mx = rx;
				if	(ry < my)
					my = ry;
				rx += t->ob_width;
				ry += t->ob_height;
				if	(rx > mrx)
					mrx = rx;
				if	(ry > mry)
					mry = ry;

				dirty = TRUE;
				}
			}
		}

	g -> g_x = mx + w->pobj->ob_x;
	g -> g_y = my + w->pobj->ob_y;
	g -> g_w = mrx - mx;
	g -> g_h = mry - my;
	return(dirty);
}


/****************************************************************
*
* Die erweiterte Rubberbox-Routine.
* Es war auf (x,y) geklickt worden, jetzt ist die Maus
* bei (mx,my)
*
****************************************************************/

void rubberbox( WINDOW *w, int x, int y, int mx, int my )
{
	EVNTDATA ev;
	register int i,tail;
	register OBJECT *tree = w->pobj;
	GRECT rub,box,mg;
	int dummy;
	int timer;
	int mwhich;
	int scrollpix;
	char *sel_status;


	mg.g_w = mg.g_h = 1;
	rub.g_x = x;
	rub.g_y = y;

	ev.x = mx;
	ev.y = my;

	/* Merkt den Selectstatus */
	/* ---------------------- */

	if	((i = (tree -> ob_head)) > 0)
		{
		sel_status = Malloc(w->shownum);
		if	(!sel_status)
			{
			form_xerr(ENSMEM, NULL);
			return;
			}

		tail = (tree++ -> ob_tail);
		for	(; i <= tail; i++,tree++)
			{
			if	(!(SELECTED&(tree->ob_state)) || (HIDETREE&(tree->ob_flags)))
				sel_status[i - 1] = 0;
			else	sel_status[i - 1] = SELECTED;
			}
		}
	else sel_status = NULL;

	wind_update(BEG_MCTRL);
	Mgraf_mouse(POINT_HAND);
	scrollpix = (w->pobj)[0].ob_y;	/* Anfangs-Scrollpos */
	do	{
		rub.g_w = ev.x-x;
		rub.g_h = ev.y-rub.g_y;

		if	(rub.g_x+rub.g_w > w->in.g_x+w->in.g_w)
			rub.g_w = w->in.g_w - rub.g_x + w->in.g_x;
		if	(rub.g_y+rub.g_h > w->in.g_y+w->in.g_h)
			rub.g_h = w->in.g_h - rub.g_y + w->in.g_y;

		if	(rub.g_x+rub.g_w < w->in.g_x)
			rub.g_w = w->in.g_x - rub.g_x + 1;
		if	(rub.g_y+rub.g_h < w->in.g_y)
			rub.g_h = w->in.g_y - rub.g_y + 1;

		xgrf_rbox(&(w->in), &rub);		/* Rubberbox zeichnen (XOR) */

		mwhich = MU_BUTTON+MU_M1;

		if	(w->handle)		/* nicht Fenster #0 */
			{
			timer = ev.y - (w->in.g_y + w->in.g_h);
			if	(timer <= 0)
				timer = w->in.g_y - ev.y + 1;
	
			if	(timer > 0)
				{
				mwhich += MU_TIMER;
				if	(timer > gl_hhchar)
					timer = gl_hhchar;
				timer = gl_hhchar - timer;
				timer *= 200;
				timer /= gl_hhchar;
				}
			}

		mg.g_x = ev.x;
		mg.g_y = ev.y;
		mwhich = evnt_multi(
				mwhich,
				1,1,0,		/* linke Mtaste loslassen */
				1,&mg,		/* Mauspos. verlassen */
				0,NULL,		/* kein 2. Mausrechteck */
				NULL,		/* keine Message */
				timer+20L,	/* Autoscroll-Timer */
				&ev,
				&dummy,		/* kreturn */
				&dummy		/* breturn */
				);
		xgrf_rbox(&(w->in), &rub);	/* Rubberbox wieder lîschen (XOR) */

		box = rub;
		if	(rub.g_w < 0)
			{
			box.g_x += rub.g_w;
			box.g_w = -rub.g_w;
			}
		if	(rub.g_h < 0)
			{
			box.g_y += rub.g_h;
			box.g_h = -rub.g_h;
			}

		if	(grect_toggle(w, sel_status, &box))
			{
			redraw(w, &box);
			dirty_info_selmask(w);
			upd_infos();
			}

		if	(w->handle)
			{
			if	(ev.y > w->in.g_y + w->in.g_h)
				{
				w->arrowed(w, WA_DNLINE);
				goto upd;
				}
			if	(ev.y < w->in.g_y)
				{
				w->arrowed(w, WA_UPLINE);
				upd:
				rub.g_y = y + (w->pobj)[0].ob_y - scrollpix;
				}
			}
		}
	while(!(mwhich & MU_BUTTON));

	Mgraf_mouse(ARROW);
	wind_update(END_MCTRL);
	if	(sel_status)
		Mfree(sel_status);
}


/****************************************************************
*
* Der Benutzer hat an der Bildschirmposition (x_koor,y_koor) mit
* dem <knopf> einen <anzahl>- fachen Mausklick ausgefÅhrt.
* Es ist kein BEG_UPDATE ausgefÅhrt worden.
*
****************************************************************/

void mausknopf(int anzahl, EVNTDATA *ev)
{
	WINDOW *w,*w2;
	EVNTDATA ev2;
	int icnobj;
	int issel,dummy2;
	OBJECT *tree;
	static void move_icons(int x_koor, int y_koor,
					WINDOW *w, int kbsh);


	/* whdl := Handle des angeklickten Fensters oder < 0			*/
	/* w	:= angeklicktes Fenster oder == NULL					*/
	/* icnobj := Objektnummer des Icons in diesem Fenster bzw. Desk.	*/
	/* tree   := Objektbaum des Fensters bzw. des Desktop			*/
	/* -------------------------------------------------------------	*/

	w = whdl2window(wind_find(ev->x, ev->y));
	if	(!w)
		return;		/* keins oder nicht unser Fenster */

	if	(w->handle)	/* echtes Fenster (nicht der Desktop) */
		{

		/* Klick auf Hintergrundfenster.					*/
		/* Weil WF_BEVENT gesetzt ist, wird das Fenster nicht	*/
		/* vom System nach oben gebracht. Dies muû daher		*/
		/* manuell erfolgen. Hier nur bei kurzem Einfachklick	*/
		/* mit nur der linken Maustaste und ohne			*/
		/* Umschalttasten!								*/
		/* --------------------------------------------------- */

		if	((anzahl == 1) && (ev->bstate == 1) && (!ev->kstate) &&
				(w->handle != top_whdl()))
			{
			graf_mkstate(&ev2.x, &ev2.y, &ev2.bstate, &ev2.kstate);
			if	(!ev2.bstate)	/* wieder losgelassen! */
				{
				wind_set_int(w->handle, WF_TOP, 0);
				wind_set_int(-1, WF_TOP, -1);	/* MenÅ nach oben! */
				return;
				}
			}

		/* In MagiC 6 kriegen wir jetzt auch Klicks auf die	*/
		/* INFO-Zeile. Wir behandeln einfach alle Klicks		*/
		/* auûerhalb des Arbeitsbereichs als INFO			*/
		/* --------------------------------------------------- */

		if	(!in_grect(ev->x, ev->y, &(w->in)))
			{
			GRECT g;

			if	(wind_get_grect(w->handle, WF_INFOXYWH, &g))
				{
				g.g_x += w->out.g_x;
				g.g_y += w->out.g_y;
				if	(in_grect(ev->x, ev->y, &g))
					show_free(w);
				}
			}
		}

	tree = w->pobj;
	icnobj = find_obj(tree, ev->x, ev->y);

	/* 1. Fall: Kein Objekt wurde angeklickt. Nichts passiert. */
	/* ------------------------------------------------------- */

	if	(icnobj < 0)
		return;

	issel = icsel(&w2, &dummy2);	/* irgendwo Icons angewÑhlt? */

	/* 2. Fall: Ein Hintergrund wurde angeklickt.			*/
	/*		  Alle Icons ggf. deselektieren				*/
	/*          Falls noch Maustaste gedrÅckt, Box ziehen		*/
	/*		  ggf. alle meine Fenster toppen				*/
	/* -------------------------------------------------------- */

	if	(icnobj == 0)
		{
		wind_update(BEG_UPDATE);
		if	(!(ev->kstate & (K_RSHIFT + K_LSHIFT)))
			{
			destroy_all_selmasks();
			if	(issel)
				dsel_all();
			}
		graf_mkstate(&ev2.x, &ev2.y, &ev2.bstate, &ev2.kstate);
		if	(ev2.bstate & 1)
			{
			rubberbox(w, ev->x, ev->y, ev2.x, ev2.y);
			}
		else	{
			if	(!w->handle)
				top_all_my_windows();
			}
		wind_update(END_UPDATE);
		return;
		}

	/* 3. Fall: selektiertes Objekt wurde einmal angeklickt	*/
	/* -------------------------------------------------------- */

	if	(anzahl < 2 && selected(tree, icnobj))
		{
		if	(ev->kstate & (K_RSHIFT + K_LSHIFT))
			{
			wind_update(BEG_UPDATE);
			ob_dsel(tree, icnobj);
			obj_malen(w, icnobj);
			dirty_info_selmask(w);
			wind_update(END_UPDATE);
			return;
			}
		goto tst_move;
		}

	/* 4. Fall: nichtselektiertes Objekt wurde angeklickt		*/
	/*          oder irgendein Objekt wurde doppelgeklickt		*/
	/*          Bei nicht SHIFT alle anderen Objekte deselekt.	*/
	/* -------------------------------------------------------- */

	if	(!(tree[icnobj].ob_flags & EXIT))	/* nicht ".." */
		{
		wind_update(BEG_UPDATE);
		if	(!(ev->kstate & (K_RSHIFT + K_LSHIFT)))
			{
			dsel_all();
			ob_sel(tree, icnobj);
			}
		else {
			if	(anzahl != 2)
				(tree + icnobj) -> ob_state ^= SELECTED;
			else (tree + icnobj) -> ob_state |= SELECTED;
			}
		obj_malen(w, icnobj);
		dirty_info_selmask(w);
		wind_update(END_UPDATE);
		}
	else	anzahl = 2;	/* Klick auf ".." wie Doppelklick */

	if	((anzahl < 2) && (!(tree[icnobj].ob_flags & EXIT)))
		{	/* einmal geklickt, nicht ".." */
		tst_move:
		graf_mkstate(&ev2.x, &ev2.y, &ev2.bstate, &ev2.kstate);
		if	(ev2.bstate & 1)
			{
			upd_infos();
			move_icons(ev->x, ev->y, w, ev->kstate);
			}
		return;
		}

	/* Ab hier nur noch Doppelklicks berÅcksichtigen */
	/* --------------------------------------------- */

	if	(anzahl == 2)
		{
		if	(dclick(w, icnobj, ev->kstate))
			{
			wind_update(BEG_UPDATE);
			ob_dsel(tree, icnobj);
			obj_malen(w, icnobj);
			dirty_info_selmask(w);
			wind_update(END_UPDATE);
			}
		}
}


/****************************************************************
*
* Alle Objekte in einem Fenster oder auf dem Desktop werden
* selektiert und ggf. neu gezeichnet.
*
****************************************************************/

void sel_all(WINDOW *w)
{
	OBJECT *tree = w->pobj;
	register OBJECT *ob;
	GRECT g;
	int   dummy;
	register int i,head;
	WINDOW *ow;



	/* In fremdem Fenster alle Objekte deselektieren */

	if	(icsel(&ow, &dummy) && (ow != w))
		dsel_all();

	/* leere Fenster nicht behandeln */

	if	((head = (tree -> ob_head)) <= 0)
		return;

	/* Select-Status aller Objekte umdrehen */
	/* auûer versteckten und ".."-Objekt	*/

	for	(i = head,ob = tree+head;
			i <= (tree -> ob_tail);
			i++,ob++)
		{
		if	(0 == (ob->ob_flags & (HIDETREE+EXIT)))
			ob->ob_state ^= SELECTED;
		}

	/* UmhÅllendes Rechteck aller selektierten */
	/* Objekte bestimmen */

	tree_sel_grect(tree, &g);

	for	(i = head,ob = tree+head;
			i <= (tree -> ob_tail);
			i++,ob++)
		{
		if	(0 == (ob->ob_flags & (HIDETREE+EXIT)))
			ob->ob_state |= SELECTED;
		}

	redraw(w, &g);
	if	(g.g_w > 0)
		dirty_info_selmask(w);
}


/****************************************************************
*
* BerÅcksichtigt das Desktop-Raster 
*
****************************************************************/

static void desk_raster(int *x, int *y)
{
	*x -= (*x % status.desk_raster);
	*y -= desk_g.g_y;
	*y -= (*y % status.desk_raster);
	*y += desk_g.g_y;
}


/****************************************************************
*
* Initialisiert ein Objekt, das ein Icon darstellt
*
****************************************************************/

void init_icnobj(OBJECT *o, CICONBLK *icn, int typ, char *text,
			int is_alias)
{
	int len;

	if	(text)
		icn->monoblk.ib_ptext = text;
	o->ob_type   = G_CICON;
	if	(typ >= 0)
		{
		o->ob_flags  = NORMAL;
		o->ob_state  = NORMAL;
		}
	len = (int) strlen(icn->monoblk.ib_ptext);
	if	(len < MIN_FNAMLEN)
		len = MIN_FNAMLEN;
	if	(is_alias)
		len++;
	len *= 6;		/* Zeichen -> Pixel */
	if	(icn->monoblk.ib_wicon > len)
		len = icn->monoblk.ib_wicon;
	icn->monoblk.ib_wtext = len;
	icn->monoblk.ib_xicon = (len-icn->monoblk.ib_wicon)>>1;
	o->ob_width  = len;
	o->ob_height = icn->monoblk.ib_hicon + 8;
	o->ob_spec.ciconblk = icn;
}


/****************************************************************
*
* Bringt ein neues Icon ins Desktop. Es soll ein Icon mit Typ
*  <typ>, absoluter Position <x,y>, (optionalem) Buchstaben <c>
*  und (optionalem) Text <text>.
* Wenn es sich um eine Datei handelt, die aufs Desktop gezogen
*  wurde, wird <path> zugeordnet.
*
* Ist x == -1, wird eine (freie) Position bestimmt.
*
* RÅckgabe != 0, falls nicht erfolgreich.
*
****************************************************************/

int make_icon(int typ, CICONBLK *cic, char c, char *icntext,
			char *path, int is_alias, int x, int y)
{
	register int i,j,k;
	register OBJECT *ob,*parent;
	ICONBLK *ic;
	char *newmemptr;


	parent = fenster[0]->pobj;

	if	(x < 0)
		{
		GRECT neu,neu2;

		neu.g_x = 0;
		neu.g_y = desk_g.g_y;
		neu.g_w = 72;	/* der Einfachheit halber */
		neu.g_h = cic->monoblk.ib_hicon + 8;
		while(neu.g_y < desk_g.g_h - neu.g_h)
			{
			while(neu.g_x < desk_g.g_w - neu.g_w)
				{
				for	(k = 1,ob = parent+1;
					k <= n_deskicons; k++,ob++)
					{
					if	(ob->ob_flags & HIDETREE)
						continue;
					neu2 = neu;
					if	(rc_intersect((GRECT *) &(ob->ob_x),
						&neu2))
						goto schneidet;
					}
				goto found;
				schneidet:
				neu.g_x += 6;
				}
			neu.g_x = 0;
			neu.g_y += 6;
			}
		neu.g_x = 0;		/* kein freier Platz */
		neu.g_y = desk_g.g_y;
		found:
		x = neu.g_x;
		y = neu.g_y;
		}

	for	(i = 0; i < n_deskicons && icon[i].icontyp; i++)
		;
	if	(i >= n_deskicons)
		{

		/* Alle Icons frei. Neuen Block allozieren	*/
		/* umkopieren und alten Block freigeben		*/
		/* -----------------------------------------	*/

		j = n_deskicons + PLUSICONS;
		newmemptr = Malloc(sizeof(ICON)        * j +
					  sizeof(OBJECT)      * (j+1));
		if	(!newmemptr)
			{
			err_alert(ENSMEM);
			return(TRUE);
			}
		/* OBJECTs relozieren */
		for	(k = 1,ob = parent+1;
			k <= n_deskicons; k++,ob++)
			{
			if	(ob->ob_type == G_CICON)
				{
				ic = ob->ob_spec.iconblk;
				ob->ob_spec.index -= (long) icon;
				if	(((long) ic->ib_ptext > (long) icon) &&
					 ((long) ic->ib_ptext < (long) (icon+n_deskicons)))
					{
					ic->ib_ptext -= (long) icon;
					}
				}
			}

		memcpy(newmemptr, parent,
			(n_deskicons+1) * sizeof(OBJECT));
		fenster[0]->pobj = parent = (OBJECT *) newmemptr;
		memcpy(parent + j + 1, icon,
			n_deskicons * sizeof(ICON));
		icon = (ICON *) (parent + j + 1);
		Mfree(gmemptr);
		gmemptr = newmemptr;
		for	(; i < j; i++)
			icon[i].icontyp = icon[i].isdisk = 0;

		ob = parent;
		ob->ob_tail = j;
		ob++;
		for	(k = 1; k <= n_deskicons; k++,ob++)
			{
			if	(ob->ob_type == G_CICON)
				{
				ob->ob_spec.index += (long) icon;
				ic = ob->ob_spec.iconblk;
				if	((long) ic->ib_ptext < (long) (n_deskicons*sizeof(ICON)))
					ic->ib_ptext += (long) icon;
				}
			}
		ob--;
		ob->ob_next = k;
		ob->ob_flags &= ~LASTOB;
		ob++;
		for	(; k <= j; k++,ob++)
			{
			ob->ob_next = k+1;
			ob->ob_head = ob->ob_tail = -1;
			ob->ob_flags = HIDETREE;
			ob->ob_state = ob->ob_type = 0;
			}
		ob--;
		ob->ob_next = 0;
		ob->ob_flags |= LASTOB;

		i = n_deskicons;
		n_deskicons = j;
		fenster[0]->shownum  = fenster[0]->realnum = n_deskicons;
		wind_set_ptr_int(SCREEN, WF_NEWDESK, parent, 0);
		}

	if	(path)
		{
		k = (icntext) ? (int) strlen(icntext) : 1;
		if	(strlen(path) > (80-k))
			{
			err_alert(EPTHOV);
			return(TRUE);
			}
		strcpy(icon[i].text, path);
		}
	else icon[i].text[0] = EOS;

	ob = parent+i+1;
	icon[i].icontyp = typ;
	icon[i].data    = *cic;
	icon[i].isdisk  = c;
	icon[i].is_alias = is_alias;
	if	(icntext)
		{
		strcat(icon[i].text, icntext);
		icntext = get_name(icon[i].text);
		}

	init_icnobj(ob, &icon[i].data, typ, icntext, is_alias);
	if	(c)
		icon[i].data.monoblk.ib_char = (c & 0x00ff) | 0x1000;
	if	(is_alias)
		ob->ob_state |= (SHADOWED+0x8000+0x400);	/* kursiv */

	/* Test, ob Icons auûerhalb des Bildschirms liegen */
	/* ----------------------------------------------- */

	x -= parent->ob_x;
	y -= parent->ob_y;
	if	(x < 0)
		x = 0;
	if	(y < desk_g.g_y)
		y = desk_g.g_y;
	if	(x + ob->ob_width > parent->ob_width)
		x = parent->ob_width - ob->ob_width;
	if	(y + ob->ob_height > parent->ob_height)
		y = parent->ob_height - ob->ob_height;

	/* Raster fÅr Iconposition, ohne Text (!) */
	/* -------------------------------------- */

	j = icon[i].data.monoblk.ib_xicon;
	x += j;				/* Position des Icons selbst */
	desk_raster(&x, &y);	/* ... rastern */
	x -= j;				/* ... und zurÅck auf Objektposition */

	ob->ob_x	    = x;
	ob->ob_y	    = y;

	obj_malen(fenster[0], i+1);
	return(FALSE);
}


/****************************************************************
*
* Nimmt ein Icon vom Desktop.
*
****************************************************************/

void kill_icon(int objnr)
{
	WINDOW *w	= fenster[0];
	OBJECT *ob = w->pobj+objnr;
	ICON   *ic = icon+objnr-1;
	GRECT  g;


	ic -> icontyp = ic -> isdisk = 0;
	ob -> ob_flags = HIDETREE;
	objc_grect(w->pobj, objnr, &g);
	redraw(w, &g);
}


/****************************************************************
*
* Gibt zu einem Objekt den Pfad und ggf. die DTA zurÅck.
* RÅckgabe  0, falls Datei
*           1, falls Pfad (Disk oder Ordner oder Fenster)
*		 -1, sonst
*
****************************************************************/

int obj_to_path(WINDOW *w, int obj, char *path, MYDTA **f)
{
	ICON  *icn;
	MYDTA *file;
	int   ispath = 0;


	if	(f)
		*f = NULL;				/* per Default keine DTA */
	*path = EOS;
	if	(!w->handle)	/* Desktop */
		{
		if	(obj == 0)			/* Desktop- Hintergrund */
			return(-1);
		icn = icon + (obj - 1);
		if	(icn->icontyp >= ITYP_ORDNER) /* Ord,Prog,Dat,Bat */
			{
			strcpy(path, icn->text);
			if	(icn->icontyp == ITYP_ORDNER)
				ispath = 1;
			}
		else {
			if	(!icn->isdisk)
				return(-1);
			path[0] = icn->isdisk;
			path[1] = ':';
			path[2] = EOS;
			ispath = 1;
			}
		}
	else {
		strcpy(path, w->path);
		if	(w->flags & WFLAG_ICONIFIED)
			{
			return(1);	/* nur Pfad, kein Dateiname */
			}
		if	(obj)
			{
			file = w->pmydta[obj-1];
			if	(f)
				*f = file;
			if	((file -> attrib) & FA_SUBDIR)
				ispath = 1;
			if	(ispath && !strcmp(file->filename, ".."))
				{
				path[strlen(path)-1] = EOS;	/* '\' weg */
				*(get_name(path)-1) = EOS;	/* einen zurÅck */
				}
			else	strcat(path, file->filename);
			}
		else ispath = 1;
		}

	if	(ispath && obj)
		strcat(path, "\\");
	return(ispath);
}


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
	set_deflt_clip();
	vsl_type	(vdi_handle, DASH);
	if	(grenz)
		{
		if	(grenz->g_x + xoff < desk_g.g_x)
			xoff = desk_g.g_x - grenz->g_x;
		if	(grenz->g_y + yoff < desk_g.g_y)
			yoff = desk_g.g_y - grenz->g_y;
		if	(grenz->g_x + grenz->g_w + xoff > desk_g.g_x + desk_g.g_w)
			xoff = desk_g.g_x + desk_g.g_w - (grenz->g_x + grenz->g_w);
		if	(grenz->g_y + grenz->g_h + yoff > desk_g.g_y + desk_g.g_h)
			yoff = desk_g.g_y + desk_g.g_h - (grenz->g_y + grenz->g_h);
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

static void move_icons(int x, int y, WINDOW *w, int kbsh)
{
	EVNTDATA ev;
	GRECT g;
	GRECT *ptr_g;
	OBJECT *tree;
	OBJECT **mov_boxes;
	int anz_boxes;
	int old_x,old_y,old_kbsh;
	register int i;
	OBJECT *zieltree;
	int zielwhdl;
	int zielobj;
	WINDOW *zielw;
	WINDOW *scrollw;
	WINDOW *altw = NULL;
	int altobj = 0;
	OBJECT *alttree = NULL;
	int scrollpix;
	int dummy;
	int timer,rtimer;
	int scroll_started;		/* Anfangsverzîgerung Åberwunden */
	int scroll_direction;	/* Richtung: WA_DNLINE oder WA_UPLINE */
	int mwhich;
	int boxes_y;
	GRECT mg;


	tree = w->pobj;
	mg.g_w = mg.g_h = 1;

	/* Speicher holen (fÅr max. 2048 Dateien) */
	/* -------------------------------------- */

	mov_boxes = (OBJECT **) Malloc(2048 * sizeof(void *));
	if	(mov_boxes == NULL)
		{
		err_alert(ENSMEM);
		return;
		}

	/* Zeiger auf alle zu verschiebenden Icons */
	/* --------------------------------------- */

	if	((i = (tree -> ob_head)) > 0)
		{
		for	(anz_boxes = 0; i <= (tree -> ob_tail); i++)
			if	(selected(tree, i) && !(HIDETREE&(tree+i)->ob_flags))
				mov_boxes[anz_boxes++] = tree+i;
		}

	if	((!w->handle) || anz_boxes == 1)	/* Desktop */
		{
		tree_sel_grect	(tree, &g);
		ptr_g = &g;
		if	((anz_boxes == 1) && (w->handle))	/* echtes Fenster */
			{
			if	(g.g_w > 12*gl_hwchar)
				g.g_w = 12*gl_hwchar;
			}
		}
	else ptr_g = NULL;

	wind_update(BEG_MCTRL);
	Mgraf_mouse(M_OFF);

	ev.x = x;
	ev.y = boxes_y = y;
	ev.kstate = kbsh;

	timer = 0;
	zielw = w;
	scrollpix = (w->pobj)[0].ob_y;	/* Anfangs-Scrollpos */
	scrollw = NULL;				/* noch kein Scrolling */
	scroll_started = FALSE;
	scroll_direction = WA_UPLINE;

	do	{
		draw_boxes(tree, mov_boxes, anz_boxes, ptr_g,
				 ev.x-x, ev.y-boxes_y);

		if	(ev.kstate & K_CTRL)
			mwhich = FLAT_HAND;
		else
		if	(ev.kstate & K_ALT)
			mwhich = POINT_HAND;
		else mwhich = ARROW;
#if NEWMOVE
		Mgraf_mouse(mwhich);
#endif
		Mgraf_mouse(M_ON);
		old_x = ev.x;
		old_y = ev.y;

		if	(scrollw)
			{
			if	(scroll_started)
				{
				if	(timer > gl_hhchar)
					timer = gl_hhchar;
				timer = gl_hhchar - timer;
				timer *= 200;
				timer /= gl_hhchar;
				}
			else timer = 500;		/* Anfangsverzîgerung */
			timer += 20;
			}

		old_kbsh = ev.kstate;
		while((!scrollw) || (timer > 0))
			{
			if	(scrollw && (timer < 50))
				rtimer = timer;
			else rtimer = 50;

			mg.g_x = ev.x;
			mg.g_y = ev.y;
			mwhich = evnt_multi(
				MU_BUTTON+MU_M1+MU_TIMER,
				1,1,0,	/* linke Mtaste loslassen */
				1,&mg,			/* Mauspos. verlassen */
				0,NULL,			/* kein 2. Mausrechteck */
				NULL,			/* keine Message */
				rtimer,			/* Autoscroll-Timer */
				&ev,
				&dummy,			/* kreturn */
				&dummy			/* breturn */
				);

			if	(mwhich & (MU_BUTTON+MU_M1))
				break;
			if	(ev.kstate != old_kbsh)
				break;

			timer -= 50;
			}

		if	(timer > 0)
			mwhich &= ~MU_TIMER;

		Mgraf_mouse(M_OFF);

		draw_boxes(tree, mov_boxes, anz_boxes, ptr_g,
				 old_x-x, old_y-boxes_y);

		/* Beginn des Scrollens: Anfangsverzîgerung Åberwunden */

		if	(!(mwhich & MU_BUTTON))
			{
			if	(scrollw && (!scroll_started) && !(mwhich & MU_M1))
				scroll_started = TRUE;

			if	(scrollw && scroll_started)
				{
				scrollw->arrowed(scrollw, scroll_direction);
				if	(scrollw == w)
					{
					g.g_y -= boxes_y;
					boxes_y = y + (scrollw->pobj)[0].ob_y - scrollpix;
					g.g_y += boxes_y;
					}
				}
			}

		zielwhdl = wind_find(ev.x, ev.y);
		zielw = whdl2window(zielwhdl);
		if	(zielw)
			{
			zieltree = zielw->pobj;

			/* Fenster-Arbeitsbereich */
			/* ---------------------- */

			if	(in_grect(ev.x, ev.y, &(zielw->in)))
				{
				scrollw = NULL;
				if	(0 < (zielobj = find_obj(zieltree, ev.x, ev.y)))
					{
					if	(zielw == w && selected(zieltree, zielobj))
						zielobj = -2;
					else if	(!is_dest(zielw, zielobj))
							zielobj = 0;
					}
				}

			/* Fenster-Randbereich */
			/* ------------------- */

			else {
				zielobj = 0;

				if	(zielw->handle)		/* nicht Fenster #0 */
					{
					if	(scrollw != zielw)
						{
						scrollw = zielw;
						scroll_started = FALSE;
						}

					/* unterer Rand */
					if	(ev.y > scrollw->in.g_y + scrollw->in.g_h)
						{
						scroll_direction = WA_DNLINE;
						timer = ev.y - (zielw->in.g_y + zielw->in.g_h);
						}
					else
					/* oberer Rand */
					if	(ev.y < scrollw->in.g_y)
						{
						scroll_direction = WA_UPLINE;
						timer = zielw->in.g_y - ev.y + 1;
						}
					else
					/* rechter Rand ohne oberen und unteren */
					if	(ev.x > scrollw->in.g_x + scrollw->in.g_w)
						{
						timer = 50;
						/* Scrollpfeil nach oben */
						if	(ev.y < scrollw->in.g_y+gl_hhbox)
							scroll_direction = WA_UPLINE;
						else
						/* Scrollpfeil nach unten */
						if	(ev.y > scrollw->in.g_y+scrollw->in.g_h-gl_hhbox)
							scroll_direction = WA_DNLINE;
						else
						scrollw = NULL;	/* Scrollbalken */
						}
					}
				else scrollw = NULL;
				}


			}
		else {
			scrollw = NULL;
			zieltree = NULL;
			zielobj = -1;
			}

		if	(zieltree != alttree || zielobj != altobj)
			{
			if	(alttree && altobj > 0)
				{
				obj_malen(altw, altobj);
				}
			if	(zieltree && zielobj > 0)
				{
				ob_sel(zieltree, zielobj);
				obj_malen(zielw, zielobj);
				ob_dsel(zieltree, zielobj);
				}
			alttree = zieltree;
			altobj  = zielobj;
			altw  = zielw;
			}
		}
	while(!(mwhich & MU_BUTTON));

	Mfree(mov_boxes);

	if	(zielobj > 0)
		{
		obj_malen(zielw, zielobj);
		}
	Mgraf_mouse(ARROW);
	Mgraf_mouse(M_ON);
	wind_update(END_MCTRL);

	/* Die zu verschiebenden Icons lagen im Desktop, Zielfenster */
	/* ist ebenfalls das Desktop, Zielobjekt ist ungÅltig oder   */
	/* der Desktop- Hintergrund :							 */
	/*	ICONS AUF DEM DESKTOP VERSCHIEBEN					 */
	/* --------------------------------------------------------- */

	if	((!w->handle) && (!zielw->handle) && (zielobj == 0 || zielobj == -2) )
		{
		wind_update(BEG_UPDATE);
		mv_dskt_icns(xrel, yrel);
		wind_update(END_UPDATE);
		return;
		}

	/* Zielobjekt ist ungÅltig (etwa fremdes Fenster oder mit    */
	/* einem der Quellobjekte identisch) :					 */
	/*	NICHTS TUN									 */
	/* --------------------------------------------------------- */

	if	(zielobj < 0)
		{

		/* Zielfenster ist fremdes Fenster						 */
		/* DRAG AND DROP									 */
		/* --------------------------------------------------------- */
	
		if	((zielwhdl >= 0) && (!zielw))
			{
			drag_and_drop(zielwhdl, ev.kstate, ev.x, ev.y);
			return;
			}
			
		if	(!(zielw->handle))
			Bconout(2,7);		/* pling */
		return;
		}

	/* Objekte sind von einem Fenster aufs Desktop gezogen 	 */
	/* worden, und zwar nicht in ein gÅltiges Zielobjekt,		 */
	/* sondern auf eine freie FlÑche :						 */
	/*	 DESKTOP- ICONS ERSTELLEN						 */
	/* --------------------------------------------------------- */

	if	((w->handle > 0) && (!zielw->handle) && (zielobj == 0))
		{
		wind_update(BEG_UPDATE);
		mk_dskt_icns(w, xrel, yrel);
		wind_update(END_UPDATE);
		return;
		}

	/* Objekte sind von irgendwoher in ein gÅltiges Objekt auf 	 */
	/* dem Desktop gezogen worden:						 */
	/*	PAPIERKORB	: LôSCHEN							 */
	/*	DRUCKER   	: DRUCKEN							 */
	/* --------------------------------------------------------- */

	if	((!zielw->handle) && zielobj > 0)
		{
		if	(icon[zielobj-1].icontyp == ITYP_PAPIER)
			{
			wind_update(BEG_UPDATE);
			cpmvdl_icns(w, NULL, ev.kstate);
			wind_update(END_UPDATE);
			return;
			}
		if	(icon[zielobj-1].icontyp == ITYP_DRUCKR)
			{
			wind_update(BEG_UPDATE);
			prt_icns(w, TRUE);
			wind_update(END_UPDATE);
			return;
			}
		}

	/*   KOPIEREN / VERSCHIEBEN							 */
	/* --------------------------------------------------------- */

		{
		char	zielpfad[130];


			/* wenn Zielobjekt kein Pfad ist... */
		if	(1 != obj_to_path(zielw, zielobj, zielpfad, NULL))
			{
			/* ... Programm starten, Ctrl ignorieren */
			wind_update(BEG_UPDATE);
			dclick(zielw, zielobj, ev.kstate & ~K_CTRL);
			wind_update(END_UPDATE);
			return;
			}
		wind_update(BEG_UPDATE);
		cpmvdl_icns(w, zielpfad, ev.kstate);
		wind_update(END_UPDATE);
		}
}


/****************************************************************
*
* Verschieben von selektierten Desktop- Icons um <x>,<y>
*
****************************************************************/

static int mvx,mvy;

#pragma warn -par
static int mv_obj(WINDOW *w, int obj, void *dummy)
{
	GRECT g;
	register OBJECT *tree = w->pobj;
	register OBJECT *o;

	o = tree+obj;
	objc_grect(tree, obj, &g);
	o->ob_x += mvx;
	o->ob_y += mvy;
	desk_raster(&o->ob_x, &o->ob_y);
	redraw(w, &g);
	obj_malen(w, obj);
	return(0);
}
#pragma warn +par

static void mv_dskt_icns(int x, int y)
{
	if	(x == 0 && y == 0)
		return;
	mvx = x;
	mvy = y;
	walk_sel(fenster[0], mv_obj, NULL);
}


/****************************************************************
*
* Verschieben von selektierten Window- Icons vom Fenster <w>
*  um <x>,<y> auf das Desktop.
*
****************************************************************/

#pragma warn -par
static int mk_obj(WINDOW *w, int obj, void *dummy)
{
	int typ;
	MYDTA *file;
	CICONBLK *cic;
	register OBJECT *tree = w->pobj + obj;
	char *icontext;
	char *iconpath;
	char path[128];
	int x,y;


	file = w->pmydta[obj-1];
	typ = file -> icontyp;
	cic = &(file -> ciconblk);
	icontext = file->filename;
	iconpath = w->path;
	if	((icontext[0] == '.') && !icontext[1])	/* "." */
		{
		if	(!iconpath[3])		/* root */
			return(-1);
		strcpy(path, iconpath);
		path[strlen(path) - 1] = EOS;	/* trailing \ */
		icontext = "";
		iconpath = path;
		}

	x = tree->ob_x + mvx;
	if	(x < 0)
		x = 0;
	y = tree->ob_y + mvy;
	if	(y < 0)
		y = 0;

	if	(make_icon(typ, cic, 0, icontext, iconpath, file->is_alias,
			    x, y))
		return(-1);
	return(0);
}
#pragma warn .par

static void mk_dskt_icns(WINDOW *w, int xrel, int yrel)
{
	mvx = w->pobj -> ob_x + xrel;
	mvy = w->pobj -> ob_y + yrel;
	walk_sel(w, mk_obj, NULL);
}


/****************************************************************
*
* Alle selektierten Icons von <wnr> sind in den Drucker
* geschoben worden oder sollen angezeigt werden.
*
* Wenn kein Pfad angegeben wurde, wird im Pfad der
* Shell nach dem Programm gesucht.
*
* Bei <print> == 0 wird angezeigt
* Bei <print> == 1 wird ausgedruckt.
*
****************************************************************/

void prt_icns(WINDOW *w, int print)
{
	char *pgm;
	int  typ;


	if	((!w) || (print && (2 == Rform_alert(1, ALRT_PRINT))))
		return;

	pgm = menuprograms[1+print].path;
	typ = tst_exepath(pgm);
	if	(typ != PGMT_NOEXE)
		{
		char cmd[128];

		typ &= ~PGMT_TP;	/* .TTP -> .TOS */
		if	(pgm[0] && (pgm[1] != ':'))
			{
			strcpy(cmd, desk_path);
			strcat(cmd, pgm);
			pgm = cmd;
			}
/*
Cconws("typ = ");
Cconout((char) (typ >> 8)); Cconout((char) typ);
Cconout(' ');
Cconws(pgm);
*/
		starten(pgm, NULL, typ, NULL, fenster[0], 0, 0);
		}
}


/****************************************************************
*
* sammelt die Pfade aller selektierten Objekte.
* hÑngt sie, durch EOS getrennt, hintereinander.
* Packt hinter jeden Pfad folgendes:
*
*	Datei im Fenster:				DateilÑnge
*	Ordner im Fenster:				-1
*	Alias im Fenster:				-2
*	Device im Fenster:				-3
*	Objekt auf dem Desktop:			-4
*
* Damit kînnen Pfade, wie auf dem Mac, auch Leerzeichen haben.
*
****************************************************************/

static int action;			/* 'Del', 'Copy', 'Move', 'Alias' */
static char *sel_mem;		/* Zeiger auf Block */
static long sel_mem_len;		/*  dessen LÑnge */
static char *selpaths;		/* Laufzeiger */
static long free_space;		/* noch freier Platz */
static int path_cnt;		/* Anzahl Zeichenketten */

static long resize_sel_mem( long add )
{
	char *blk;

	if	(add < 10240L)
		add = 10240L;		/* immer mindestens 2k mehr */
	if	( Mshrink(0, sel_mem, sel_mem_len + add) )
		{
		blk = Malloc( sel_mem_len + add );	/* neuen Block alloz. */
		if	(!blk)
			return(ENSMEM);
		memcpy(blk, sel_mem, selpaths - sel_mem);	/* umkop. */
		selpaths = blk + (selpaths - sel_mem);
		Mfree(sel_mem);			/* alten Block freigeben */
		sel_mem = blk;
		}
	free_space += add;
	sel_mem_len += add;		/* Block vergrîûern */
	return(E_OK);
}

static void wrt_kobold_action( void )
{
	if	(free_space < 8+14)
		{
		free_space = 0L;
		return;
		}

	/* Alle Aktionen ab aktuellem Ordner, daher auf	*/
	/* root gehen!								*/

	strcpy(selpaths, "SRC_SELECT \\" "\r\n");
	free_space -= 14;
	selpaths += 14;

	if	(action == 'D')
		{
		strcpy(selpaths, "DELETE\r\n");
		free_space -= 8;
		}
	else
		{
		if	(action == 'M')
			strcpy(selpaths, "MOVE\r\n");
		else
			strcpy(selpaths, "COPY\r\n");
		free_space -= 6;
		}
}


#pragma warn -par
static int collect_objs(WINDOW *w, int obj, void *dummy)
{
	char	path[128];
	MYDTA *f;
	long err;
	long len,flen;
	int typ;
	static char last_drive;	/* fÅr Kobold-Jobs */
	char *quoting;			/* fÅr Kobold 3.5 */


	/* Lîschen auf dem Desktop: Objekt entfernen, auûer */
	/* bei Disks, die werden tatsÑchlich gelîscht */
	/* GEéNDERT ! */

/*
	if	((action == 'D') && (wnr == 0) &&
		 (icon[obj-1].icontyp >= ITYP_ORDNER))
*/
	if	((action == 'D') && (!w->handle))
		{
		kill_icon(obj);
		return(0);
		}

	/* Zugehîrigen Pfad des Objekts bestimmen */
	/* -------------------------------------- */

	if	(0 > (typ = obj_to_path(w, obj, path, &f)))
		return(0);	/* Objekt ungÅltig ? */
	len = strlen(path);
	if	(!len)
		return(0);

	if	(!path_cnt)
		last_drive = 0;	/* 1. Aufruf: last_drive ungÅltig */


	/* 1. Fall: Kobold benutzen */
	/* ------------------------ */

	if	(status.copy_use_kobold)
		{
		if	(free_space < 130L)
			return((int) ENSMEM);

		if	(path[len-1] == '\\')
			{
			path[len-1] = EOS;	/* trailing '\' killen */
			len--;
			}

		if	(last_drive && (path[0] != last_drive))
			wrt_kobold_action();	/* neues Laufwerk! */

		/* Workaround um KOBOLD Fehler */
		if	((action == 'D') || (action == 'M'))
			set_dirty(E_OK, path, -1, 1);

		if	(path[0] != last_drive)
			{
			strcpy(selpaths, "SRC_SELECT ");
			selpaths += 11;
			*selpaths++ = path[0];
			*selpaths++ = ':';
			*selpaths++ = '\r';
			*selpaths++ = '\n';
			free_space -= 15;
			last_drive = path[0];
			}

		if	(!path[2])			/* X: */
			{
			strcpy(selpaths, "CHOOSE *+\r\n");
			len = 11;
			}
		else	{

			len += 13;	/* LÑnge inkl. Kommando und crlf */
			if	(len > free_space)
				return((int) ENSMEM);

			strcpy(selpaths, "SRC_SELECT + ");

			/* FÅr Kobold 3.5 brauchen wir Quoting */
			/* ----------------------------------- */

			quoting = strchr(path+2, ' ');
			if	(quoting)
				{
				strcat(selpaths, "'");
				strcat(selpaths, path+2);	/* ohne Laufwerk! */
				strcat(selpaths, "'\r\n");
				len += 2;					/* 2 Quotes! */
				}
			else	{
				strcat(selpaths, path+2);	/* ohne Laufwerk! */
				strcat(selpaths, "\r\n");
				}
			}
		}


	/* 2. Fall: MGCOPY benutzen */
	/* ------------------------ */

	else	{
		len++;			/* LÑnge inkl. EOS */
		if	(len > free_space)
			{
			err = resize_sel_mem( len - free_space );
			if	(err)
				return((int) err);
			}
		memcpy(selpaths, path, len);
		selpaths += len;
		free_space -= len;
		path_cnt++;
	
		/* DateilÑnge des Objekts bestimmen */
		/* -------------------------------- */
	
		if	(f)				/* im Fenster */
			{
			if	(f->is_alias)
				flen = -2L;		/* Alias ! */
			else
			if	(f->icontyp == ITYP_DEVICE)
				flen = -3L;		/* Device ! */
			else
			if	(!typ)		/* Datei */
				flen = f->filesize;
			else	flen = -1L;		/* Ordner */
			}
		else	flen = -4L;			/* Objekt auf dem Desktop */
		ltoa(flen, path, 10);
		len = strlen(path)+1;	/* LÑnge inkl. EOS */
		if	(len > free_space)
			{
			err = resize_sel_mem( len - free_space );
			if	(err)
				return((int) ENSMEM);
			}
		memcpy(selpaths, path, len);
		}

	path_cnt++;
	selpaths += len;
	free_space -= len;
	return(0);
}
#pragma warn +par


/****************************************************************
*
* Alle selektierten Icons von <wnr> sind in den
* <destpath> bzw. in den Papierkorb (destpath = NULL)
* geschoben worden.
*
****************************************************************/

static void wait_kobold_answer(int *msg)
{
	WINDOW *w;

	do	{
		evnt_mesag(msg);
/*
		if	(msg[0] == SH_WDRAW)
			{
			register int i;
			if	((msg[3] >= 0) &&
				 (msg[3] < ANZDRIVES))
				dirty_drives[msg[3]] = TRUE;
			else	{
				for	(i = 0; i < ANZDRIVES; i++)
					dirty_drives[i] = TRUE;
				}
			}
*/
		if	(msg[0] == WM_TOPPED)
			{
			w = whdl2window(msg[3]);
			if	(w)
		 		w->topped(w);
			}
		else
		if	(msg[0] == WM_REDRAW)
			{
			wind_update(BEG_UPDATE);
			redraw(whdl2window(msg[3]),
				(GRECT *) (msg+4));
			wind_update(END_UPDATE);
			}
		} while(msg[0] != KOBOLD_ANSWER);
}


void cpmvdl_icns(WINDOW *w, char *destpath, int kbsh)
{
	long len;
	char apname[9];
	int	dst_apid;
	char *kobold_path;
	int	msg[8];


	if	(destpath)
		{
		if	(kbsh & K_CTRL)
			action = 'M';			/* move */
		else
		if	(kbsh & K_ALT)
			action = 'A';			/* alias */
		else	action = 'C';			/* copy */
		}
	else	action = 'D';

	path_cnt = 0;
	sel_mem_len = free_space = 10240L;
	sel_mem = Malloc(sel_mem_len);
	if	(!sel_mem)
		{
		err_alert(ENSMEM);
		return;
		}

	selpaths = sel_mem;
	msg[1] = ap_id;
	msg[2] = 0;


	/* 1. Fall: Kobold benutzen */
	/* ------------------------ */

	if	(status.copy_use_kobold)
		{
		kobold_path = getenv("KOBOLD");
		if	(!kobold_path)
			kobold_path = "KOBOLD_2";
		get_app_name(kobold_path, apname);

		dst_apid = appl_find(apname);
		if	(dst_apid < 0)
			dst_apid = appl_find("KOBOLD_3");

		if	(dst_apid < 0)
			{
			Rform_alert(1, ALRT_NO_KOBOLD);
			return;
			}
		strcpy(selpaths, "* MAGXDESK\r\n");
		free_space -= 12+100;	/* inkl. Kommando */
		selpaths += 12;
		if	(destpath)
			{

			/* Workaround um KOBOLD Fehler */
			set_dirty(E_OK, destpath, -1, 1);

			strcpy(selpaths, "DST_SELECT ");
			strcat(selpaths, destpath);
			strcat(selpaths, "\r\n");
			len = strlen(selpaths);
			selpaths += len;
			free_space -= len;
			}
		walk_sel(w, collect_objs, NULL);
		if	(path_cnt)
			{
			wrt_kobold_action();
			}
		msg[0] = KOBOLD_JOB_NO_WINDOW;	/* Message: Kopieren */

                                      		/* ohne Fenster      */
/*
          Cconws(mem);
          Cconin();
*/
		*((char **) &msg[3]) = sel_mem;	/* Zeiger auf Job	*/
		appl_write(dst_apid, 16, msg);	/* abschicken		*/

		wind_update(END_UPDATE);

		wait_kobold_answer(msg);

		Mfree(sel_mem);
		sel_mem = NULL;

		/* status = msg[3]; */               /* Abschluûstatus   */
		/* zeile = msg[4]; */                /* Letzte Zeile     */

		if	(msg[3] != FINISHED)   /* KOBOLD ist noch aktiv */
			{
		/*	msg[0] = KOBOLD_CLOSE;	*/
			msg[0] = KOBOLD_FREE_DRIVES;  /* Message: Beenden*/
			msg[1] = ap_id;       /* Eigene ID        */
			msg[2] = 0;             /* Keine öberlÑnge  */

			appl_write(dst_apid,16,msg);   /* abschicken       */

			wait_kobold_answer(msg);

			          /* ...und Freigabe von Speicher und Lauf-   */
				           /*    werken abwarten.                */

			}
		wind_update(BEG_UPDATE);
		return;
		}


	/* 2. Fall: MGCOPY benutzen */
	/* ------------------------ */

	/* Kommandozeilen-Schalter */

	strcpy(selpaths, "\xfe" "ARGV=MagX");
	selpaths += 11;
	strcpy(selpaths, "MGCOPY.APP");	/* arg[0] */
	selpaths += 11;
	*selpaths++ = '-';
	*selpaths++ = action;
	if	(action == 'D')
		{
		if	(status.cnfm_del)
			*selpaths++ = 'c';
		}
	else	{
		if	(status.cnfm_copy)
			*selpaths++ = 'c';
		if	(status.check_free)
			*selpaths++ = 'f';
		if	(status.mode_ovwr == OVERWRITE)
			*selpaths++ = 'o';
		else
		if	(status.mode_ovwr == BACKUP)
			*selpaths++ = 'u';
		}
			
	if	(!status.copy_resident)
		*selpaths++ = 'q';			/* nach Aktion terminieren */
	*selpaths++ = EOS;
	free_space -= (selpaths-sel_mem)+1;	/* Schalter + Ende-EOS */
	if	(destpath)
		{
		len = strlen(destpath) + 1;
		free_space -= len;
		}

	/* Hier werden alle selektierten Objekte erfaût */
	/* -------------------------------------------- */

	walk_sel(w, collect_objs, NULL);

	/* MGCOPY ausfÅhren */
	/* ---------------- */

	if	(path_cnt)
		{

		/* ggf. Zielpfad anfÅgen */
		/* --------------------- */

		if	(destpath)
			{
			memcpy(selpaths, destpath, len);
			selpaths += len;
			}
		*selpaths = EOS;	/* Ende der Parameterliste */
	
		if	((dst_apid = appl_find("MGCOPY  ")) > 0)
			{
			XAESMSG xmsg;

			msg[0] = VA_START;
			msg[3] = msg[4] = 0;	/* kein "normales" VA_START */
			msg[5] = 'XA';			/* Kennung fÅr erweitertes V.. */
			xmsg.dst_apid = dst_apid;
			xmsg.unique_flg = FALSE;
			xmsg.attached_mem = sel_mem;
			xmsg.msgbuf = msg;
			if	(0 >= appl_write(-2, 16, &xmsg))
				{
				Mfree(sel_mem);
				sel_mem = NULL;
				err_alert(ERROR);
				}
			return;
			}
		starte_dienstpgm("MGCOPY.APP", TRUE, TRUE, sel_mem,
						NULL, NULL);
		}
	Mfree(sel_mem);
	sel_mem = NULL;
}
