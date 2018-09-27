/* * Demo-Programm zum Gebrauch der "Men XCMD" * */
#include <stdio.h>#include <stddef.h>#include <stdlib.h>#include <string.h>#include <tos.h>
#include <aes.h>#include "MGMC_API.H"
#include "MEN_XCMD.H"
#include "MAC_MENU.H"
MgMcCookie *gMgMcCookie;int apid;
OBJECT *tree;
OBJECT *ob;
USERBLK userblk_macmenu;
XCMDMgrRec *xcmd;XCMDHdl hdl;
int mbar_h;
WORD whdl;


/* Hintergrund */
USERBLK userblk_bg;
static OBJECT bg =
{
	-1,-1,-1,
	G_USERDEF,
	LASTOB,
	NORMAL,
	(LONG) &userblk_bg,
	0,	/* x */
	0,	/* y */
	0,	/* w */
	0	/* h */
};

/* temporÑr */
static OBJECT o =
{
	-1,-1,-1,
	G_BOX,
	LASTOB,
	NORMAL,
	0L,
	0,	/* x */
	0,	/* y */
	0,	/* w */
	0	/* h */
};
/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;

/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}


static int cdecl draw_macmenu( PARMBLK *p )
{
	xcmd->call (hdl, xcmdDrawMenu, NULL);
	return(p->pb_currstate);
}

static int cdecl draw_bg( PARMBLK *p )
{
	xcmd->call (hdl, xcmdRedrawBg, &p->pb_xc);
	return(p->pb_currstate);
}

/*********************************************************************
*
* Event-Schleife
*
*********************************************************************/

void do_menu( void )
{
	EVNT w_ev;
	SelectMenuParm sparm;
	HiliteMenuParm hparm = {0};
	unsigned long ret;
	int h;


	do	{
		w_ev.mwhich = evnt_multi(
						MU_KEYBD+MU_BUTTON+MU_MESAG,
						1,		/* Einfachklicks */
						1,		/* Linke Maustaste */
						1,		/* Linke Maustaste */
						0,NULL,		/* kein 1. Rechteck			*/
						0,NULL,		/* kein 2. Rechteck			*/
						w_ev.msg,
						0,		/* ms */
						(EVNTDATA*) &(w_ev.mx),
						&w_ev.key,
						&w_ev.mclicks
						);


		/* Abfrage auf Nachricht im Nachrichtenpuffer */
		/* ------------------------------------------ */

		if	(w_ev.mwhich & MU_MESAG)
			{
				switch(w_ev.msg[0])
					{
					case AP_TERM:
						return;
					case WM_REDRAW:
						wind_update(BEG_UPDATE);
						wind_get_grect(w_ev.msg[3], WF_WORKXYWH,
							(GRECT *) &o.ob_x);
						objc_wdraw(&o, 0, 8, NULL, w_ev.msg[3]);
						wind_update(END_UPDATE);
/*
						redraw(w, (GRECT *) (w_ev.msg+4));
*/
						break;
					case WM_TOPPED:
						wind_set_int(w_ev.msg[3], WF_TOP, 0);
				 		break;
					case WM_MOVED:
						wind_set_grect(w_ev.msg[3], WF_CURRXYWH, (GRECT *) (w_ev.msg+4));
						break;
					case WM_CLOSED:
				 	   	wind_close(w_ev.msg[3]);
				 	   	wind_delete(w_ev.msg[3]);
				 	   	return;
					}
			}


		/* Abfrage auf Tastatur */
		/* -------------------- */

		if	(w_ev.mwhich & MU_KEYBD)
			{
			printf("key = %04x\n", w_ev.key);
			if	((w_ev.key & 0xff) == 'q')
				break;
			}

		/* Abfrage auf Mausklick */
		/* --------------------- */

		if	(w_ev.mwhich & MU_BUTTON)
			{
			if	(w_ev.my < mbar_h)
				{
				EVNTDATA ev;

				sparm.x = w_ev.mx;
				sparm.y = w_ev.my;
				graf_mkstate(&ev.x, &ev.y, &ev.bstate, &ev.kstate);
				sparm.mbutstate = (ev.bstate & 1);
				graf_mouse(M_OFF, NULL);
				ret = xcmd->call (hdl, xcmdSelectMenu, &sparm);
				graf_mouse(M_ON, NULL);
				printf("MenÅ = %d Eintrag = %d\n",
							(int) (ret >> 16), (int) ret);
				xcmd->call( hdl, xcmdHiliteMenu, &hparm);
					if	(ret == 0x0002000aL)
				break;
				}
			else	{
				h = wind_find(w_ev.mx, w_ev.my);
				if	(h <= 0)
					{
					EVNTDATA evb;
					SwitchToMacOSParm swparm;

					/* Warte auf Loslassen der Maustaste */
					evnt_button(1, 3, 0, &evb);
					/* Auf MacOS umschalten */
					Cconws("Schalte auf MacOS um\r\n");
					swparm.x = w_ev.mx;
					swparm.y = w_ev.my;
					xcmd->call( hdl, xcmdSwitchToMacOS, &swparm);
/*
					byte = 2;
					gMgMcCookie->configKernel (5, &byte);*/
					}
				}
			}		}
	while(1);

}


/*********************************************************************
*
* Aktiviert ein Mac-MenÅ
*
*********************************************************************/
int main (void){
	COOKIE *cookie;	OpenMenuParm mparm;
	unsigned char buf[256];
	long ret;
	GRECT desk_g;
	GRECT g = {10, 30, 300, 100};


	cookie = getcookie('MgMc');	if	(!cookie)
		return(-1);
	apid = appl_init();
	if	(apid < 0)
		return(-1);

	if	(!rsrc_load("MAC_MENU.RSC"))
		return(-2);

	wind_get_grect(0, WF_WORKXYWH, &desk_g);
	mbar_h = desk_g.g_y;

	/* MenÅ anmelden */
	rsrc_gaddr(0, T_MENU, &tree);
	tree[1].ob_type = G_IBOX;
	ob = tree + T_MENU_M_DESK;
	userblk_macmenu.ub_parm = 0;
	userblk_macmenu.ub_code = draw_macmenu;
	ob->ob_type = G_USERDEF;
	ob->ob_spec.userblk = &userblk_macmenu;

	/* Hintergrund */

	userblk_bg.ub_parm = 0;
	userblk_bg.ub_code = draw_bg;
	*((GRECT *) &bg.ob_x) = desk_g;
	wind_set_ptr_int(0, WF_NEWDESK, &bg, 0);	/* Desktop- Hintergrund */

	/* Schnittstellen */

	gMgMcCookie = (MgMcCookie *) cookie->value;		/* find and open the XCMD */
	xcmd = gMgMcCookie->xcmdMgrPtr;	if	(!xcmd)
		return(-1);
	/* MEN XCMD */
	Cconws("Mac MenÅ laden...\r\n");
	hdl = xcmd->open("Men XCMD");
	if	((long)hdl < 0)
		{
		Cconws("Mac MenÅ XCMD ist nicht installiert.\r\n");
		return(-1);		/* Men XCMD ist nicht installiert */
		}
	strcpy((char *) buf, "pDaten:Dokumente:MagicMacMenu:Testmenu.rsrc");
	*buf = (unsigned char) strlen((char *) (buf+1));	/* Pascal- String */
	mparm.rsc_filename = buf;
	mparm.rsc_mbar_rscno = 128;	ret = xcmd->call (hdl, xcmdOpenMenu, &mparm);

	if	(!ret)
		{
		Cconws("MenÅ installiert");
		menu_bar(tree, 1);
		}
	else	{
		ltoa(ret, (char *) buf, 10);
		Cconws("Fehlercode ");
		Cconws((char *) buf);
		}
	Cconws("\r\n");
/*	Cconin();	*/
	whdl = wind_create(MOVER+CLOSER, &desk_g);
	if	(whdl >= 0)
		wind_open(whdl, &g);

	do_menu();

	Cconws("Hintergrund abschalten...\r\n");
	wind_set_ptr_int(0, WF_NEWDESK, NULL, 0);

	Cconws("MenÅ abschalten...\r\n");
	ret = xcmd->call (hdl, xcmdCloseMenu, NULL);

	Cconws("XCMD freigeben...\r\n");

/*	Cconin();	*/

	xcmd->close (hdl);
	return(0);}