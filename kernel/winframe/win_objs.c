/*
*
* Dieser Quelltext enthÑlt die Routinen fÅr
* die USERDEFs
*
*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#if DEBUG
#include <stdio.h>
#endif
#include <string.h>
#include "globals.h"
#include "win_objs.h"
#include "winframe.h"

int border = 2;
int title_h = 16;
int winobjects_width = 18;		/* inkl. Rand */
int winobjects_width_m_1 = 17;	/* dito minus 1 */
int winobjects_height = 18;		/* inkl. Rand */
int winobjects_height_m_1 = 17;	/* dito minus 1 */


/***************************************************************
*
* globale Initialisierung
*
***************************************************************/

void global_init()
{
	register int i;
	register int *pi;
	int imgx[] = {
		O_UP_IMG,O_UP,
		O_DOWN_IMG,O_DOWN,
		O_LEFT_IMG,O_LEFT,
		O_RIGHT_IMG,O_RIGHT
		};
	int fix_width_objs[] = {
		O_UP,O_DOWN,
		O_VSCROLL,O_VSLIDE,
		O_LEFT,O_RIGHT,0
		};
	int fix_height_objs[] = {
		O_UP,O_DOWN,
		O_HSCROLL,O_HSLIDE,
		O_LEFT,O_RIGHT,0
		};


	adr_window[O_SIZER].ob_spec.iconblk->ib_wtext = 0;
	adr_window[O_CLOSER].ob_spec.iconblk->ib_wtext = 0;
	adr_window[O_FULLER].ob_spec.iconblk->ib_wtext = 0;
	adr_window[O_BDROP].ob_spec.iconblk->ib_wtext = 0;
	adr_window[O_ICONIFIER].ob_spec.iconblk->ib_wtext = 0;
	adr_window[O_NAME].ob_type = 36;
	for	(i = 0,pi = imgx; i < 4; i++,pi+=2)
		{
		objc_delete(adr_window, *pi);
		adr_window[*pi].ob_x = adr_window[*pi].ob_y = 0;
		objc_add(adr_window, pi[1], *pi);
		}
	for	(pi = fix_width_objs; *pi; pi++)
		adr_window[*pi].ob_width = winobjects_width;
	for	(pi = fix_height_objs; *pi; pi++)
		adr_window[*pi].ob_height = winobjects_height;
}

void global_init2()
{
	TEDINFO *te;

	adr_window[O_INFO].ob_height = h_inw;
	te = adr_window[O_INFO].ob_spec.tedinfo;
	te->te_just  = 3;	/* TE_SPECIAL */
	te->te_font  = 4;	/* PFINFO */
	te->te_junk1 = (WORD) (((LONG) (settings->finfo_inw)) >> 16L);
	te->te_junk2 = (WORD) (((LONG) (settings->finfo_inw)));
}

/***************************************************************
*
* Slidergrîûe bzw. -position berechnen
*
* promille:		0..1000
* maxpos:			tats. Bereich ist 0..maxpos-1
*
***************************************************************/

static WORD calc_slider( WORD promille, WORD maxpos )
{
	LONG u;

	promille <<= 1;
	u = ((LONG) promille) * ((LONG) maxpos);
	u /= 1000L;
	u += 1L;
	u >>= 1L;
	return((WORD) u);
}


/***************************************************************
*
* Berechnet fÅr wind_calc() die Grîûe des Rahmens.
* Der Rahmen kann dann entweder zur Innengrîûe addiert oder
* von der Auûengrîûe abgezogen werden.
*
***************************************************************/

static void wcalc_frame( WININFO *wi, WORD *fg )
{
	int minframe;

	minframe = border+4;
	if	(!wi->kind)
		minframe = 2;		/* nur 3D-Rand */

	*fg++ = minframe;		/* linker Rand */
	*fg = minframe;		/* oberer Rand */
	if	(wi->kind & TOP_WINOBJS)
		*fg += 14;
	if	(wi->is_info)
		*fg += h_inw+1;
	fg++;
	*fg = minframe;		/* rechter Rand */
	if	(wi->is_rgtobjects)
		*fg += winobjects_width_m_1;
	fg++;
	*fg = minframe;		/* unterer Rand */
	if	(wi->is_botobjects)
		*fg += winobjects_height_m_1;
}


/***************************************************************
*
* Verschiedenes
*
***************************************************************/

static void draw_greypixel( WORD x, WORD y )
{
	int pxy[4];

	pxy[0] = pxy[2] = x;
	pxy[1] = pxy[3] = y;
	vsl_color(vdi_handle, LWHITE);
	v_pline(vdi_handle, 2, pxy);
}

static void draw_blkframe( GRECT *g )
{
	int pxy[10];
	register int *p;


	p = pxy;
	*p++ = g->g_x;
	*p++ = g->g_y;
	*p++ = g->g_x + g->g_w-1;
	*p++ = g->g_y;
	*p++ = pxy[2];
	*p++ = g->g_y + g->g_h-1;
	*p++ = g->g_x;
	*p++ = pxy[5];
	*p++ = g->g_x;
	*p = g->g_y;
	vsl_color(vdi_handle, BLACK);
	v_pline(vdi_handle, 5, pxy);
}

static void draw_3dframe_lo( GRECT *g )
{
	int pxy[6];
	register int *p;


	p = pxy;
	*p++ = g->g_x;
	*p++ = g->g_y + g->g_h-2;
	*p++ = g->g_x;
	*p++ = g->g_y;
	*p++ = g->g_x + g->g_w-2;
	*p = g->g_y;
	vsl_color(vdi_handle, WHITE);
	v_pline(vdi_handle, 3, pxy);
}

static void draw_3dframe_ru( GRECT *g )
{
	int pxy[6];
	register int *p;


	p = pxy;
	*p++ = g->g_x+1;
	*p++ = g->g_y + g->g_h-1;
	*p++ = g->g_x + g->g_w-1;
	*p++ = pxy[1];
	*p++ = pxy[2];
	*p = g->g_y+1;
	vsl_color(vdi_handle, LBLACK);
	v_pline(vdi_handle, 3, pxy);
}


/***************************************************************
*
* Zeichenroutine fÅr das Rahmen-Objekt
*
***************************************************************/

static WORD cdecl frame_ubcode( PARMBLK *pb )
{
	WININFO *wi = (WININFO *) pb->pb_parm;
	int pxy[14];
	GRECT *g;
	int ob_rahmen;
	int npt;


	/* objc_change() bearbeiten */
	/* ------------------------ */

	if	(pb->pb_currstate != pb->pb_prevstate)
		goto ende;

	vswr_mode(vdi_handle, MD_REPLACE);

	/* Clipping setzen */
	/* --------------- */

	pxy[0] = pb->pb_xc;
	pxy[1] = pb->pb_yc;
	pxy[2] = pxy[0] + pb->pb_wc - 1;
	pxy[3] = pxy[1] + pb->pb_hc - 1;
	if	(pxy[2] < 0)
		goto ende;
	vs_clip(vdi_handle, TRUE, pxy);

	/* Ñuûeren Rand ausgeben (Schwarz) */
	/* ------------------------------- */

	g = (GRECT *) &pb->pb_x;
	draw_blkframe( g );
	g->g_x++;
	g->g_y++;
	g->g_w -= 2;
	g->g_h -= 2;
	draw_3dframe_lo( g );
	draw_3dframe_ru( g );
	draw_greypixel( g->g_x, g->g_y + g->g_h - 1);
	draw_greypixel( g->g_x + g->g_w - 1, g->g_y);
	g->g_x++;
	g->g_y++;
	g->g_w -= 2;
	g->g_h -= 2;

	/* grauen Rand ausgeben */
	/* -------------------- */

	if	(wi->kind)
		{
		vsf_color(vdi_handle, LWHITE);
		/* linker Streifen */
		pxy[0] = g->g_x;
		pxy[1] = g->g_y;
		pxy[2] = g->g_x + border - 1;
		pxy[3] = g->g_y + g->g_h - 1;
		vr_recfl(vdi_handle, pxy);
		/* rechter Streifen */
		pxy[0] += g->g_w - border;
		pxy[2] += g->g_w - border;
		vr_recfl(vdi_handle, pxy);
		/* unterer Streifen */
		pxy[0] = g->g_x + border;
		pxy[1] = g->g_y + g->g_h - border;
		pxy[2] = g->g_x + g->g_w - border - 1;
		vr_recfl(vdi_handle, pxy);
		/* oberer Streifen */
		ob_rahmen = (wi->kind & TOP_WINOBJS) ? title_h : border;
		if	(ob_rahmen > g->g_h)
			ob_rahmen = g->g_h;
		pxy[1] = g->g_y;
		pxy[3] = g->g_y + ob_rahmen - 1;
		vr_recfl(vdi_handle, pxy);

		g->g_x += border;
		g->g_y += ob_rahmen;
		g->g_w -= border + border;
		g->g_h -= border + ob_rahmen;
		}

	/* ggf. rechts unten ein Rechteck fÅr den SIZER */
	/* -------------------------------------------- */

	if	(wi->is_sizer)
		{
		pxy[0] = g->g_x + g->g_w - winobjects_width_m_1;
		pxy[1] = g->g_y + g->g_h - 19;
		pxy[2] = pxy[0] + 16;
		pxy[3] = pxy[1] + winobjects_height;
		vr_recfl(vdi_handle, pxy);
		}

	/* inneren Rahmen zeichnen */
	/* ----------------------- */

	if	((wi->kind) && !(wi->state & SHADED)
		/* && (wi->work.g_w) && (wi->work.g_h) */)
		{
		vsl_color(vdi_handle, LBLACK);
		/* links: dunkelgrau */
		pxy[0] = g->g_x;
		pxy[1] = g->g_y + 1;
		pxy[2] = g->g_x;
		pxy[3] = g->g_y + g->g_h - 2;
		v_pline(vdi_handle, 2, pxy);
		/* oben: dunkelgrau */
		pxy[0] = g->g_x+1;
		pxy[1] = g->g_y;
		pxy[2] = g->g_x + g->g_w - 2;
		pxy[3] = g->g_y;
		v_pline(vdi_handle, 2, pxy);
		draw_greypixel( g->g_x, g->g_y);
		draw_greypixel( g->g_x, g->g_y + g->g_h - 1);
		draw_greypixel( g->g_x + g->g_w - 1, g->g_y);
	
		vsl_color(vdi_handle, WHITE);
		/* unten: weiû */
		pxy[0] = g->g_x + 1;
		pxy[1] = pxy[3] = g->g_y + g->g_h - 1;
		pxy[2] = g->g_x + g->g_w - 1;
		if	(wi->is_sizer)
			pxy[2] -= winobjects_width_m_1;
		v_pline(vdi_handle, 2, pxy);
		/* rechts: weiû */
		pxy[0] = pxy[2] = g->g_x + g->g_w - 1;
		pxy[1] = g->g_y + 1;
		pxy[3] = g->g_y + g->g_h - 1;
		if	(wi->is_sizer)
			{
			pxy[3] -= winobjects_height_m_1;
			pxy[4] = pxy[2] - winobjects_width_m_1;
			pxy[5] = pxy[3];
			pxy[6] = pxy[4];
			pxy[7] = pxy[5] + 16;
			npt = 4;
			}
		else	{
			npt = 2;
			}
		v_pline(vdi_handle, npt, pxy);
	
		g->g_x++;
		g->g_y++;
		g->g_w -= 2;
		g->g_h -= 2;
	
		/* schwarzer innerer Rahmen */
		/* ------------------------ */
	
		vsl_color(vdi_handle, BLACK);
		pxy[0] = g->g_x;
		pxy[1] = g->g_y+g->g_h - 1;
		pxy[2] = g->g_x;
		pxy[3] = pxy[5] = g->g_y;
		pxy[4] = pxy[6] = g->g_x + g->g_w - 1;
		pxy[7] = g->g_y + g->g_h - 1;
		if	(wi->is_sizer)
			{
			pxy[7] -= winobjects_height_m_1;
			pxy[8] = pxy[6] - winobjects_width_m_1;
			pxy[9] = pxy[7];
			pxy[10] = pxy[8];
			pxy[11] = pxy[9] + winobjects_height_m_1;
			pxy[12] = pxy[0];
			pxy[13] = pxy[1];
			npt = 7;
			}
		else	{
			pxy[8] = g->g_x;
			pxy[9] = pxy[1];
			pxy[10] = pxy[0];
			pxy[11] = pxy[1];
			npt = 5;
			}
		v_pline(vdi_handle, npt, pxy);
		}

	/* Linie unter der Info-Zeile */
	/* -------------------------- */

	if	(wi->is_info)
		{
		pxy[0] = g->g_x + 1;
		pxy[1] = pxy[3] = g->g_y + h_inw+1;
		pxy[2] = g->g_x + g->g_w - 2;
		v_pline(vdi_handle, 2, pxy);
		}

ende:
	return(pb->pb_currstate);
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Initialisiert ein Fenster, d.h. erstellt den Objektbaum
*
***************************************************************/

void wbm_create( WININFO *wi )
{
	/* Objektbaum kopieren */
	/* ------------------- */

	vmemcpy(wi->tree, adr_window, N_OBJS*sizeof(OBJECT));
	vmemcpy(&(wi->ted_name),
			adr_window[O_NAME].ob_spec.tedinfo,
			sizeof(TEDINFO));
	vmemcpy(&(wi->ted_info),
			adr_window[O_INFO].ob_spec.tedinfo,
			sizeof(TEDINFO));

	wi->ted_name.te_ptext = wi->name;
	wi->ted_info.te_ptext = wi->info;
	wi->tree[O_NAME].ob_spec.tedinfo = &wi->ted_name;
	wi->tree[O_INFO].ob_spec.tedinfo = &wi->ted_info;
	wi->frame_userblk.ub_parm = (LONG) wi;
	wi->frame_userblk.ub_code = frame_ubcode;
	wi->tree[O_FRAME].ob_spec.userblk = &wi->frame_userblk;
	wi->tree[O_FRAME].ob_type = G_USERDEF;
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Initialisiert ein Fenster, dessen Typ feststeht.
* D.h. der Objektbaum wird verkettet.
* Dabei erhalten alle unverrÅckbaren Objekte bereits ihre
* korrekte Position
*
***************************************************************/

void wbm_skind( WININFO *wi )
{
	register int i;
	register OBJECT *tree;
	WORD xl,yo;


	/* Minimalgrîûe berechnen */
	/* ---------------------- */

	wi->min.g_w = wi->min.g_h = border + border + 6;
	if	(wi->kind & TOP_WINOBJS)
		wi->min.g_h += 14;
	if	(wi->kind & INFO)
		wi->min.g_h += h_inw + 1;
	if	(wi->kind & UPARROW)
		wi->min.g_h += winobjects_height_m_1;
	if	(wi->kind & DNARROW)
		wi->min.g_h += winobjects_height_m_1;
	if	(wi->kind & VSLIDE)
		wi->min.g_h += 4;
	if	(wi->kind & SIZER)
		wi->min.g_h += winobjects_height_m_1;

	i = wi->min.g_w;
	if	(wi->kind & SIZER)
		wi->min.g_w += winobjects_width_m_1;
	if	(wi->kind & LFARROW)
		wi->min.g_w += winobjects_width_m_1;
	if	(wi->kind & RTARROW)
		wi->min.g_w += winobjects_width_m_1;
	if	(wi->kind & HSLIDE)
		wi->min.g_w += 4;
	if	((wi->kind & TOP_WINOBJS) && !(settings->flags & NO_BDROP))
		i += 14;
	if	(wi->kind & CLOSER)
		i += 14;
	if	(wi->kind & ICONIFIER)
		i += 14;
	if	(wi->kind & FULLER)
		i += 14;
	if	(i > wi->min.g_w)
		wi->min.g_w = i;

	/* erstmal alle Objekte entfernen */
	/* ------------------------------ */

	for	(i = 0, tree = wi->tree; i <= 15; i++,tree++)
		{
		tree->ob_next = -1;
		if	((i != O_UP) && (i != O_DOWN) &&
			 (i != O_LEFT) && (i != O_RIGHT))
			tree->ob_head = tree->ob_tail = -1;
		}
	tree = wi->tree;
	
	/* Fall: Ikonifiziertes Fenster */
	/* ---------------------------- */

	if	(wi->state & ICONIFIED)
		{
		tree[O_NAME].ob_x = 2;
		objc_add(tree, O_FRAME, O_NAME);
		wi->is_rgtobjects = wi->is_botobjects =
			wi->is_sizer = wi->is_info = FALSE;
		return;
		}


	if	(wi->state & SHADED)
		wi->is_rgtobjects = wi->is_sizer =
				wi->is_botobjects = wi->is_info = FALSE;
	else	{
		wi->is_rgtobjects = (wi->kind & RGT_WINOBJS) ||
				((wi->kind & SIZER) && !(wi->kind & BOT_WINOBJS));
		wi->is_sizer = (wi->kind & SIZER) ||
			 ((wi->kind & RGT_WINOBJS) && (wi->kind & BOT_WINOBJS));
		wi->is_botobjects = (wi->kind & BOT_WINOBJS);
		wi->is_info = (wi->kind & INFO);
		}

	/* Rand berÅcksichtigen */
	/* -------------------- */

	xl = yo = border+3;	/* 2 Pixel auûen + grauer Bereich + 1 Pixel innen */

	/* obere Elemente */
	/* -------------- */

	if	(wi->kind & TOP_WINOBJS)
		{

		/* linke obere Elemente */
		/* -------------------- */

		if	(wi->kind & CLOSER)
			{
			xl += 14;
			objc_add(tree, O_FRAME, O_CLOSER);
			}
		else	xl -= 2;	/* Fenstertitel ganz nach links ziehen */

		/* rechte obere Elemente */
		/* --------------------- */

		if	(wi->kind & FULLER)
			{
			objc_add(tree, O_FRAME, O_FULLER);
			}
		if	(wi->kind & ICONIFIER)
			{
			objc_add(tree, O_FRAME, O_ICONIFIER);
			}
		if	(!(settings->flags & NO_BDROP))
			objc_add(tree, O_FRAME, O_BDROP);

		/* obere zentrierte Elemente */
		/* ------------------------- */

		tree[O_NAME].ob_x = xl;
		objc_add(tree, O_FRAME, O_NAME);
		yo += 14;
		}

	/* INFO */
	/* ---- */

	if	(wi->is_info)
		{
		tree[O_INFO].ob_y = yo + 1;
		objc_add(tree, O_FRAME, O_INFO);
		yo += h_inw+1;
		}

	/* rechte Elemente */
	/* --------------- */

	if	(wi->is_rgtobjects)
		{
		if	(wi->kind & UPARROW)
			{
			tree[O_UP].ob_y = yo;
			objc_add(tree, O_FRAME, O_UP);
			yo += winobjects_height_m_1;
			}
		if	(wi->kind & DNARROW)
			{
			objc_add(tree, O_FRAME, O_DOWN);
			}

		tree[O_VSCROLL].ob_y = yo;
		objc_add(tree, O_FRAME, O_VSCROLL);

		if	(wi->kind & VSLIDE)
			{
			objc_add(tree, O_VSCROLL, O_VSLIDE);
			i = LBLACK;
			}
		else	{
			i = LWHITE;
			}
		tree[O_VSCROLL].ob_spec.obspec.interiorcol = i;
		}

	/* untere Elemente */
	/* --------------- */

	if	(wi->is_botobjects)
		{
		xl = border+3;

		if	(wi->kind & LFARROW)
			{
			tree[O_LEFT].ob_x = xl;
			objc_add(tree, O_FRAME, O_LEFT);
			xl += winobjects_width_m_1;
			}
		if	(wi->kind & RTARROW)
			{
			objc_add(tree, O_FRAME, O_RIGHT);
			}

		tree[O_HSCROLL].ob_x = xl;
		objc_add(tree, O_FRAME, O_HSCROLL);

		if	(wi->kind & HSLIDE)
			{
			objc_add(tree, O_HSCROLL, O_HSLIDE);
			i = LBLACK;
			}
		else	{
			i = LWHITE;
			}
		tree[O_HSCROLL].ob_spec.obspec.interiorcol = i;
		}

	/* SIZER */
	/* ----- */

	if	(wi->is_sizer && (wi->kind & SIZER))
		{
		objc_add(tree, O_FRAME, O_SIZER);
		}
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Legt Sliderposition und -grîûe fest.
* Wird nur aufgerufen, wenn ein ensprechender VSLIDE/HSLIDE
* angemeldet ist.
*
***************************************************************/

void wbm_sslid( WININFO *wi, WORD vertical )
{
	WORD i,j;
	register OBJECT *tree = wi->tree;

	if	(vertical)
		{
		j = tree[O_VSCROLL].ob_height;
		if	(wi->vslsize < 0)
			i = winobjects_height;
		else	i = calc_slider(wi->vslsize, j);
		if	(i < winobjects_height)
			i = winobjects_height;
		if	(i >= j)
			i = j;
		tree[O_VSLIDE].ob_height = i;

		j -= i;		/* minimale Sliderbreite abziehen */
		if	(j < 0)
			j = 0;
		i = calc_slider(wi->vslide, j);
		tree[O_VSLIDE].ob_y = i;
		}

	else	{
		j = tree[O_HSCROLL].ob_width;
		if	(wi->hslsize < 0)
			i = winobjects_width;
		else	i = calc_slider(wi->hslsize, j);
		if	(i < winobjects_width)
			i = winobjects_width;
		if	(i >= j)
			i = j;
		tree[O_HSLIDE].ob_width = i;

		j -= i;		/* minimale Sliderbreite abziehen */
		if	(j < 0)
			j = 0;
		i = calc_slider(wi->hslide, j);
		tree[O_HSLIDE].ob_x = i;
		}
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Fensterposition und/oder -grîûe hat sich geÑndert.
*
***************************************************************/

void wbm_ssize( WININFO *wi )
{
	WORD frame[4];
	register int i,xl,xr,yo,yu;
	register OBJECT *tree = wi->tree;
	register GRECT *og;
	GRECT g;


	/* Fensterstruktur updaten */
	/* ----------------------- */

	wi->overall = wi->curr;

	if	(wi->state & SHADED)
		{
		i = (wi->state & ICONIFIED) ? NAME+MOVER : wi->kind;
		wbm_calc(i, frame);
		}
	else	wcalc_frame(wi, frame);

	wi->work.g_x = wi->curr.g_x + frame[0];
	wi->work.g_y = wi->curr.g_y + frame[1];
	frame[0] += frame[2];
	frame[1] += frame[3];
	wi->work.g_w = wi->curr.g_w - frame[0];
	if	(wi->work.g_w < 0)
		wi->work.g_w = 0;
	wi->work.g_h = wi->curr.g_h - frame[1];
/*
	if	(wi->work.g_h < 0)
		wi->work.g_h = 0;
*/
	og = (GRECT *) &(tree[O_FRAME].ob_x);
	og->g_x = wi->curr.g_x;
	og->g_y = wi->curr.g_y;
	if	((og->g_w == wi->curr.g_w) && (og->g_h == wi->curr.g_h))
		return;
	og->g_w = wi->curr.g_w;
	og->g_h = wi->curr.g_h;

	/* Fall: Ikonifiziertes Fenster */
	/* ---------------------------- */

	if	(wi->state & ICONIFIED)
		{
		tree[O_NAME].ob_width = wi->curr.g_w - 4;
		return;
		}

	/* Rand berÅcksichtigen */
	/* -------------------- */

	g = wi->curr;
	i = border+3;	/* 2 Pixel auûen + grauer Bereich + 1 Pixel innen */
	g.g_x = i;
	g.g_y = i;
	g.g_w -= i+i;
	g.g_h -= i+i;

	/* obere Elemente */
	/* -------------- */

	if	(wi->kind & TOP_WINOBJS)
		{

		/* linke obere Elemente */
		/* -------------------- */

		xl = g.g_x;
		if	(wi->kind & CLOSER)
			{
			xl += 14;
			}
		else	xl -= 2;

		/* rechte obere Elemente */
		/* --------------------- */

		xr = g.g_x+g.g_w;
		if	(wi->kind & FULLER)
			{
			xr -= 14;
			tree[O_FULLER].ob_x = xr;
			}
		if	(wi->kind & ICONIFIER)
			{
			xr -= 16;
			tree[O_ICONIFIER].ob_x = xr;
			}
		if	(!(settings->flags & NO_BDROP))
			{
			xr -= 16;
			tree[O_BDROP].ob_x = xr;
			}

		/* obere zentrierte Elemente */
		/* ------------------------- */

		xr += 2;

		xr -= xl;
		if	(xr < 0)
			xr = 0;
		tree[O_NAME].ob_width = xr;
		g.g_y += 14;
		g.g_h -= 14;
		}

	/* INFO */
	/* ---- */

	if	(wi->is_info)
		{
		tree[O_INFO].ob_width = g.g_w - 2;
		g.g_y += h_inw+1;
		g.g_h -= h_inw+1;
		}

	/* rechte Elemente */
	/* --------------- */

	if	(wi->is_rgtobjects)
		{
		i = g.g_x + g.g_w - winobjects_width;
		yo = g.g_y;
		yu = g.g_y + g.g_h;
		if	(wi->is_sizer)
			yu -= winobjects_height_m_1;

		if	(wi->kind & UPARROW)
			{
			tree[O_UP].ob_x = i;
			yo += winobjects_height_m_1;
			}
		if	(wi->kind & DNARROW)
			{
			yu -= winobjects_height;
			tree[O_DOWN].ob_x = i;
			tree[O_DOWN].ob_y = yu;
			yu++;
			}

		tree[O_VSCROLL].ob_x = i;
		yu -= yo;
		if	(yu < 0)
			yu = 0;
		tree[O_VSCROLL].ob_height = yu;

		if	(wi->kind & VSLIDE)
			{
			if	(wi->vslsize < 0)
				i = winobjects_height;
			else	i = calc_slider(wi->vslsize, yu);
			if	(i < winobjects_height)
				i = winobjects_height;
			if	(i >= yu)
				i = yu;
			tree[O_VSLIDE].ob_height = i;

			yo = yu - i;		/* minimale Sliderbreite abziehen */
			if	(yo < 0)
				yo = 0;
			i = calc_slider(wi->vslide, yo);
			tree[O_VSLIDE].ob_y = i;
			}
		}

	/* untere Elemente */
	/* --------------- */

	if	(wi->is_botobjects)
		{
		i = g.g_y + g.g_h - winobjects_height;
		xl = g.g_x;
		xr = g.g_x + g.g_w;
		if	(wi->is_sizer)
			xr -= winobjects_width_m_1;

		if	(wi->kind & LFARROW)
			{
			tree[O_LEFT].ob_y = i;
			xl += winobjects_width_m_1;
			}
		if	(wi->kind & RTARROW)
			{
			xr -= winobjects_width;
			tree[O_RIGHT].ob_x = xr;
			tree[O_RIGHT].ob_y = i;
			xr++;
			}

		tree[O_HSCROLL].ob_y = i;
		xr -= xl;
		if	(xr < 0)
			xr = 0;
		tree[O_HSCROLL].ob_width = xr;

		if	(wi->kind & HSLIDE)
			{
			if	(wi->hslsize < 0)
				i = winobjects_width;
			else	i = calc_slider(wi->hslsize, xr);
			if	(i < winobjects_width)
				i = winobjects_width;
			if	(i >= xr)
				i = xr;
			tree[O_HSLIDE].ob_width = i;

			xl = xr - i;		/* minimale Sliderbreite abziehen */
			if	(xl < 0)
				xl = 0;
			i = calc_slider(wi->hslide, xl);
			tree[O_HSLIDE].ob_x = i;
			}
		}

	/* SIZER */
	/* ----- */

	if	(wi->kind & SIZER)
		{
		tree[O_SIZER].ob_x = tree->ob_width - 20;
		tree[O_SIZER].ob_y = tree->ob_height - 20;
		}
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Der Text fÅr INFO oder NAME hat sich geÑndert.
*
***************************************************************/

void wbm_sstr( WININFO *wi )
{
	wi->ted_name.te_ptext = wi->name;
	wi->ted_info.te_ptext = wi->info;
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Das Attribut-Bit hat sich geÑndert, d.h.
* SHADED, ACTIVE oder ICONIFIED
*
***************************************************************/

void wbm_sattr( WININFO *wi, WORD chbits )
{
	WORD newfont;


	if	(chbits & ACTIVE)
		{
		if	(wi->state & ACTIVE)
			{
			wi->ted_name.te_color |= 0x80;
			wi->ted_name.te_color &= ~0x800;
			wi->ted_info.te_color &= ~0x800;
			if	(wi->kind & VSLIDE)
				wi->tree[O_VSCROLL].ob_spec.obspec.interiorcol = LBLACK;
			if	(wi->kind & HSLIDE)
				wi->tree[O_HSCROLL].ob_spec.obspec.interiorcol = LBLACK;
			}
		else	{
			wi->ted_name.te_color &= ~0x80;
			wi->ted_name.te_color |= 0x800;
			wi->ted_info.te_color |= 0x800;
			if	(wi->kind & VSLIDE)
				wi->tree[O_VSCROLL].ob_spec.obspec.interiorcol = LWHITE;
			if	(wi->kind & HSLIDE)
				wi->tree[O_HSCROLL].ob_spec.obspec.interiorcol = LWHITE;
			}
		}

	if	(chbits & ICONIFIED)
		{
		if	(wi->state & ICONIFIED)
			{
			newfont = SMALL;
			}
		else	{
			newfont = IBM;
			}
		wi->ted_name.te_font = newfont;
		wbm_skind(wi);
		}

	if	(chbits & SHADED)
		wbm_skind(wi);
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Gibt fÅr den Fenstertyp <kind> den Rand zurÅck.
*
***************************************************************/

void wbm_calc( WORD kind, WORD *fg )
{
	int minframe;
	WORD is_rgtobjects,is_botobjects;


	is_rgtobjects = (kind & RGT_WINOBJS) ||
			((kind & SIZER) && !(kind & BOT_WINOBJS));
	is_botobjects = (kind & BOT_WINOBJS);


	minframe = border+4;
	if	(!kind)
		minframe = 2;		/* nur 3D-Rand */

	*fg++ = minframe;		/* linker Rand */
	*fg = minframe;		/* oberer Rand */
	if	(kind & TOP_WINOBJS)
		*fg += 14;
	if	(kind & INFO)
		*fg += h_inw+1;
	fg++;
	*fg = minframe;		/* rechter Rand */
	if	(is_rgtobjects)
		*fg += winobjects_width_m_1;
	fg++;
	*fg = minframe;		/* unterer Rand */
	if	(is_botobjects)
		*fg += winobjects_height_m_1;
}


/***************************************************************
*
* MANAGER-FUNKTION
*
* Gibt fÅr die Mausposition (x,y) das zugehîrige Objekt
* zurÅck.
*
***************************************************************/

WORD wbm_obfind( WININFO *wi, WORD x, WORD y )
{
	WORD obj;
	int i;

	if	(wi->is_sizer)
		{
		i = border+3;
		if	((x >= wi->tree->ob_x+wi->tree[O_SIZER].ob_x) &&
			 (y >= wi->tree->ob_y+wi->tree[O_SIZER].ob_y))
			return(O_SIZER);
		}
	if	(wi->kind & MOVER)
		{
		i = border+3;
		if	(x < wi->tree->ob_x+i)
			return(O_NAME);
		if	(x > wi->tree->ob_x+wi->tree->ob_width-i)
			return(O_NAME);
		if	(y > wi->tree->ob_y+wi->tree->ob_height-i)
			return(O_NAME);
		}
	obj = objc_find(wi->tree, 0, 8, x, y);
	if	(obj == O_UP_IMG)
		obj = O_UP;
	else
	if	(obj == O_DOWN_IMG)
		obj = O_DOWN;
	if	(obj == O_LEFT_IMG)
		obj = O_LEFT;
	if	(obj == O_RIGHT_IMG)
		obj = O_RIGHT;
	return(obj);
}
