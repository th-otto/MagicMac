#define __WDIALOG_IMPLEMENTATION
#define __HNDL_OBJ
#define __MTDIALOG
#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "wdlgmain.h"

#ifdef BINEXACT
void *mmalloc(ULONG size);
#endif

#undef Mfree
#define	Mfree(addr) Mfree(addr)


WORD do_xfrm_popup(OBJECT *tree, WORD x, WORD y)
/*
	WORD firstscrlob, WORD lastscrlob,
	WORD nlines,
	void cdecl (*init)(OBJECT *tree, WORD scrollpos, WORD nlines, void *param),
	void *param, WORD *lastscrlpos
*/
{
	GRECT m1_gr;
	WORD flag;
	EVNTDATA ev;
	WORD pxy[8];
	WORD buf[8];
	WORD mox;
	WORD moy;
	WORD keycode;
	WORD clicks;
	MFDB fdb;
	MFDB screen;
	GRECT gr;
	WORD obj = NIL;
	WORD bstate;
	WORD bmask;
	WORD oldobj;
	WORD events;
#if BINEXACT
	WORD dummy;
#endif
	
	if (x != 0 || y != 0)
	{
		tree[ROOT].ob_x = x;
		tree[ROOT].ob_y = y;
	}
	vq_extnd(vdi_handle, 0, workout);
	mt_wind_get_grect(0, WF_WORKXYWH, &gr, NULL);
	if (tree[ROOT].ob_x < gr.g_x)
		tree[ROOT].ob_x = gr.g_x;
	if (tree[ROOT].ob_y < gr.g_y)
		tree[ROOT].ob_y = gr.g_y;
	if (gr.g_x + gr.g_w < tree[ROOT].ob_x + tree[ROOT].ob_width)
		tree[ROOT].ob_x += gr.g_x + gr.g_w - tree[ROOT].ob_x - tree[ROOT].ob_width;
	if (gr.g_y + gr.g_h < tree[ROOT].ob_y + tree[ROOT].ob_height)
		tree[ROOT].ob_y += gr.g_y + gr.g_h - tree[ROOT].ob_y - tree[ROOT].ob_height;
	x = tree[ROOT].ob_x;
	y = tree[ROOT].ob_y;
	mt_form_center_grect(tree, &gr, NULL);
	gr.g_x -= 2;
	gr.g_y -= 2;
	gr.g_w += 2 * 2;
	gr.g_h += 2 * 2;
	gr.g_x -= tree[ROOT].ob_x - x;
	gr.g_y -= tree[ROOT].ob_y - y;
	tree[ROOT].ob_x = x;
	tree[ROOT].ob_y = y;
	if (gr.g_x < 0)
		gr.g_x = 0;
	if (gr.g_y < 0)
		gr.g_y = 0;
	if (gr.g_x + gr.g_w - 1 > workout[0])
	{
		gr.g_w = workout[0] - gr.g_x + 1;
		if (gr.g_w < 0)
			gr.g_w = 0;
	}
	if (gr.g_y + gr.g_h - 1 > workout[1])
	{
		gr.g_h = workout[1] - gr.g_y + 1;
		if (gr.g_h < 0)
			gr.g_h = 0;
	}
	
	screen.fd_addr = NULL;
	fdb.fd_w = (gr.g_w + 15) & ~15;
	fdb.fd_h = gr.g_h;
	fdb.fd_wdwidth = fdb.fd_w / 16;
	fdb.fd_stand = 0;
	fdb.fd_nplanes = xworkout[4]; /* BUG: global workout queried above, but not xworkout */
	fdb.fd_addr = mmalloc(((long)fdb.fd_w * fdb.fd_h * fdb.fd_nplanes) / 8);
	if (fdb.fd_addr == NULL)
		return obj;
		
	mt_wind_update(BEG_MCTRL, NULL);
	mt_graf_mouse(M_OFF, NULL, NULL);
	pxy[0] = gr.g_x;
	pxy[1] = gr.g_y;
	pxy[2] = gr.g_x + gr.g_w - 1;
	pxy[3] = gr.g_y + gr.g_h - 1;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = gr.g_w - 1;
	pxy[7] = gr.g_h - 1;
	vs_clip(vdi_handle, 1, pxy);
	vro_cpyfm(vdi_handle, S_ONLY, pxy, &screen, &fdb);
	mt_graf_mouse(M_ON, NULL, NULL);
	mt_objc_draw_grect(tree, ROOT, MAX_DEPTH, &gr, NULL);
	mt_evnt_timer(10, NULL);
	
	mt_graf_mkstate_event(&ev, NULL);
	bstate = ev.bstate;
	if (bstate)
	{
		bmask = bstate;
		bstate = 0;
	} else
	{
		bmask = 1;
		bstate = bmask;
	}
	
	for (;;)
	{
		if (obj < 0)
		{
			m1_gr = gr;
			flag = 0;
		} else
		{
			mt_objc_offset(tree, obj, &m1_gr.g_x, &m1_gr.g_y, NULL);
			m1_gr.g_w = tree[obj].ob_width;
			m1_gr.g_h = tree[obj].ob_height;
			flag = 1;
		}
		events = MT_evnt_multi(MU_M1 | MU_BUTTON,
			1, bmask, bstate,
			flag, &m1_gr,
			0, NULL,
			buf,
			0L,
			&ev, &keycode, &clicks, NULL);
		mox = ev.x;
		moy = ev.y;
#if BINEXACT
		dummy = ev.bstate;
		dummy = ev.kstate;
		(void) dummy;
#endif
		if (events & MU_M1)
		{
			oldobj = obj;
			obj = mt_objc_find(tree, ROOT, MAX_DEPTH, mox, moy, NULL);
			if (obj != NIL)
			{
				if ((tree[obj].ob_state & DISABLED) || !(tree[obj].ob_flags & SELECTABLE))
					obj = NIL;
			}
			if (obj != oldobj)
			{
				if (oldobj >= 0)
				{
					mt_objc_offset(tree, oldobj, &m1_gr.g_x, &m1_gr.g_y, NULL);
					m1_gr.g_w = tree[oldobj].ob_width;
					m1_gr.g_h = tree[oldobj].ob_height;
					tree[oldobj].ob_state &= ~SELECTED;
					mt_objc_draw_grect(tree, ROOT, MAX_DEPTH, &m1_gr, NULL);
				}
				if (obj >= 0)
				{
					mt_objc_offset(tree, obj, &m1_gr.g_x, &m1_gr.g_y, NULL);
					m1_gr.g_w = tree[obj].ob_width;
					m1_gr.g_h = tree[obj].ob_height;
					tree[obj].ob_state |= SELECTED;
					mt_objc_draw_grect(tree, ROOT, MAX_DEPTH, &m1_gr, NULL);
				}
			}
		}
		if (events & MU_BUTTON)
		{
			if (bstate)
			{
				do
				{
					events = MT_evnt_multi(MU_BUTTON,
						1, 1, 0,
						0, NULL,
						0, NULL,
						buf,
						0L,
						&ev, &keycode, &clicks, NULL);
				} while (!(events & MU_BUTTON));
			}
			mt_graf_mouse(M_OFF, NULL, NULL);
			pxy[0] = 0;
			pxy[1] = 0;
			pxy[2] = gr.g_w - 1;
			pxy[3] = gr.g_h - 1;
			pxy[4] = gr.g_x;
			pxy[5] = gr.g_y;
			pxy[6] = gr.g_x + gr.g_w - 1;
			pxy[7] = gr.g_y + gr.g_h - 1;
			vs_clip(vdi_handle, 1, &pxy[4]);
			vro_cpyfm(vdi_handle, S_ONLY, pxy, &fdb, &screen);
			Mfree(fdb.fd_addr);
			mt_graf_mouse(M_ON, NULL, NULL);
			mt_wind_update(END_MCTRL, NULL);
			if (obj >= 0)
				tree[obj].ob_state &= ~SELECTED;
			break;
		}
	}
	
	return obj;
}
