/* * Schnittstelle zur Spezialversion von MagiCMac
 * (Åber "Men XCMD" und "Nav XCMD". *
 * bietet:
 *	- MenÅs
 *	- Hintergrund
 *	- Dateiauswahl */
#include <stddef.h>#include <stdlib.h>#include <string.h>#include <mgx_dos.h>
#include <mt_aes.h>
#include "MM7.H"#include "MGMC_API.H"
#include "MEN_XCMD.H"
#include "NAV_XCMD.H"

static MgMcCookie *gMgMcCookie;static XCMDMgrRec *xcmd;static XCMDHdl men_hdl = -1;		/* fÅr Men XCMD */
static XCMDHdl nav_hdl = -1;		/* fÅr Nav XCMD */
static USERBLK userblk_macmenu;
static WORD mbar_h;


/* Hintergrund */
static USERBLK userblk_bg;
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
/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

static COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}

#pragma warn -par
static int cdecl draw_macmenu( PARMBLK *p )
{
	xcmd->call (men_hdl, xcmdDrawMenu, NULL);
	/* Aus unerfindlichen GrÅnden wird das linke MenÅ mitunter
	selektiert, daher RÅckgabe 0, um den schwarzen Balken zu
	verhindern */
/*	return(p->pb_currstate);	*/
	return(0);
}
#pragma warn .par

static int cdecl draw_bg( PARMBLK *p )
{
	xcmd->call (men_hdl, xcmdRedrawBg, &p->pb_xc);
	return(p->pb_currstate);
}


/*********************************************************************
*
* Initialisierung der Bibliothek.
* Aufrufen nach appl_init().
* Installiert den Desktop-Hintergrund.
*
*********************************************************************/
LONG MgMc7Init (void){
	COOKIE *cookie;	GRECT desk_g;



	if	(gMgMcCookie)
		return(-2);	/* schon initialisiert */

	cookie = getcookie('MgMc');	if	(!cookie)
		return(-1);
	/* Schnittstellen */

	gMgMcCookie = (MgMcCookie *) cookie->value;	xcmd = gMgMcCookie->xcmdMgrPtr;	if	(!xcmd)
		{
		err:
		gMgMcCookie = NULL;
		return(-1);
		}	men_hdl = xcmd->open("Men XCMD");	if	((long) men_hdl < 0)
		goto err;			/* Men XCMD ist nicht installiert */
	nav_hdl = xcmd->open("Nav XCMD");	if	((long) nav_hdl < 0)
		goto err;			/* Nav XCMD ist nicht installiert */
	wind_get_grect(0, WF_WORKXYWH, &desk_g);
	mbar_h = desk_g.g_y;

	/* Hintergrund */

	userblk_bg.ub_parm = 0;
	userblk_bg.ub_code = draw_bg;
	*((GRECT *) &bg.ob_x) = desk_g;
	wind_set_ptr_int(0, WF_NEWDESK, &bg, 0);	/* Desktop- Hintergrund */
	wind_update(BEG_UPDATE);
	objc_wdraw(&bg, 0, 1, &desk_g, 0);
	wind_update(END_UPDATE);
	return(0);}

/*********************************************************************
*
* Exitialisierung der Bibliothek.
*
*********************************************************************/
LONG MgMc7Exit (void){
	if	(!gMgMcCookie)
		return(-1);	/* nicht initialisiert */

	wind_set_ptr_int(0, WF_NEWDESK, NULL, 0);
	(void) xcmd->call(men_hdl, xcmdCloseMenu, NULL);
	if	(men_hdl >= 0)
		xcmd->close(men_hdl);
	if	(nav_hdl >= 0)
		xcmd->close(nav_hdl);
	return(0);}


/*********************************************************************
*
* MenÅ anmelden.
*
*********************************************************************/
LONG MgMc7InitMenuBar( char *fname, short rscno, OBJECT *tree ){
	OpenMenuParm mparm;
	OBJECT *ob;
	long ret;
	register int i;


	if	(!gMgMcCookie)
		return(-1);	/* nicht initialisiert */

	/* weiûe Box (MenÅtitel) wird leer */
	tree[1].ob_type = G_IBOX;
	/* erster MenÅtitel wird USERDEF */
	i = 3;
	ob = tree + i;
	userblk_macmenu.ub_parm = 0;
	userblk_macmenu.ub_code = draw_macmenu;
	ob->ob_type = G_USERDEF;
	ob->ob_spec.userblk = &userblk_macmenu;
	/* weitere MenÅtitel werden HIDDEN */
	for	(;;)
		{
		i = ob->ob_next;
		if	(i == 2)	/* ist wieder parent */
			break;
		ob = tree+i;
		ob->ob_flags |= HIDETREE;
		}

	mparm.rsc_filename = fname;
	mparm.rsc_mbar_rscno = rscno;	ret = xcmd->call (men_hdl, xcmdOpenMenu, &mparm);

	if	(ret)
		return(ret);

	menu_bar(tree, 1);
	return(0);
}


/*********************************************************************
*
* MenÅ zeichnen.
*
*********************************************************************/
LONG MgMc7DrawMenuBar( void ){
	return(xcmd->call (men_hdl, xcmdDrawMenu, NULL));
}


/*********************************************************************
*
* Bestehende Datei auswÑhlen.
* 0 = Objekt ausgewÑhlt.
* 1 = kein Objekt ausgewÑhlt.
* sonst Fehlercode
*
*********************************************************************/

LONG MgMc7NavGetFile( char *buf, int buflen )
{
	NGetFileParm gparm;

	gparm.buflen = buflen;
	gparm.buf = (char *) buf;	return(xcmd->call (nav_hdl, xcmdGetFile, &gparm));
}


/*********************************************************************
*
* Neue Datei auswÑhlen.
* 0 = Objekt ausgewÑhlt.
* 1 = kein Objekt ausgewÑhlt.
* sonst Fehlercode
*
*********************************************************************/

LONG MgMc7NavPutFile( char *buf, int buflen )
{
	NPutFileParm pparm;


	pparm.buflen = buflen;
	pparm.buf = (char *) buf;	return(xcmd->call (nav_hdl, xcmdPutFile, &pparm));
}


/*********************************************************************
*
* Mausklick behandeln.
*
*********************************************************************/

LONG MgMc7DoMouseClick(int mx, int my, int *menu, int *entry)
{
	SelectMenuParm sparm;
	int h;
	long ret;


	*menu = *entry = 0;
	if	(my < mbar_h)
		{
		EVNTDATA ev;

		sparm.x = mx;
		sparm.y = my;
		graf_mkstate(&ev.x, &ev.y, &ev.bstate, &ev.kstate);
		sparm.mbutstate = (ev.bstate & 1);
		graf_mouse(M_OFF, NULL);
		ret = xcmd->call (men_hdl, xcmdSelectMenu, &sparm);
		graf_mouse(M_ON, NULL);
		*menu = (int) (ret >> 16);
		*entry = (int) (ret & 0xffff);
		return(1);		/* MenÅ verarbeitet */
		}
	else	{
		h = wind_find(mx, my);
		if	(h <= 0)
			{
			EVNTDATA evb;
			SwitchToMacOSParm swparm;

			/* Warte auf Loslassen der Maustaste */
			evnt_button(1, 3, 0, &evb);
			/* Auf MacOS umschalten */
/*			Cconws("Schalte auf MacOS um\r\n");	*/
			swparm.x = mx;
			swparm.y = my;
			xcmd->call( men_hdl, xcmdSwitchToMacOS, &swparm);
/*
			byte = 2;
			gMgMcCookie->configKernel (5, &byte);*/
			return(2);	/* Hintergrund verarbeitet */
			}
		}
	return(0);		/* unverarbeitet */
}


/*********************************************************************
*
* MenÅtitel Hilite.
*
*********************************************************************/

LONG MgMc7MenuHilite(int menu)
{
	HiliteMenuParm hparm;

	hparm.id = menu;
	return(xcmd->call( men_hdl, xcmdHiliteMenu, &hparm));
}

/*********************************************************************
*
* MenÅtitel Enable.
*
*********************************************************************/

LONG MgMc7EnableItem(int menu, int item)
{
	EnableDisableMenuParm eparm;

	eparm.id = menu;
	eparm.item = item;
	return(xcmd->call( men_hdl, xcmdEnableItem, &eparm));
}

/*********************************************************************
*
* MenÅtitel Disable.
*
*********************************************************************/

LONG MgMc7DisableItem(int menu, int item)
{
	EnableDisableMenuParm eparm;

	eparm.id = menu;
	eparm.item = item;
	return(xcmd->call( men_hdl, xcmdDisableItem, &eparm));
}

/*********************************************************************
*
* Programm beenden.
*
*********************************************************************/

void MgMc7Shutdown( void )
{
	xbios(39, 'AnKr', 0);	/* Beendet MagicMac */
}
