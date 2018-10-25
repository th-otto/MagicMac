/****************************************************************
*
*             WINFRAME                             1.7.98
*             ========
*                                 letzte Aenderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: WINFRAME.PRJ
*
* Alternativer Window-Frame-Manager (Beispiel) fuer MagiC 6.
* Das Programm ist als SharedLib ausgefuehrt.
*
****************************************************************/

#include <mgx_dos.h>
#include <aes.h>
#include <string.h>
#include "globals.h"
#include "win_objs.h"
#include "winframe.h"

extern char __text[];
typedef void *PD;

OBJECT *adr_window;

WINFRAME_HANDLER old_wfh,new_wfh;
WINFRAME_SETTINGS *settings;
WORD h_inw;


/*********************************************************************
*
* Fensterrahmen-Manager beim AES anmelden
*
*********************************************************************/

static WORD sys_set_winframe_manager( WINFRAME_HANDLER *old_wfh,
						WINFRAME_HANDLER *new_wfh,
						WINFRAME_SETTINGS **set )
{
	PARMDATA d;
	static WORD	c[] = { 0, 1, 1, 2 };

	d.intin[0] = 6;	/* Subcode 6: Fensterrahmen-Manager */
	d.addrin[0] = old_wfh;
	d.addrin[1] = new_wfh;
	_mt_aes( &d, c, NULL );
	if	(set)
		*set = d.addrout[0];
	return( d.intout[0] );
}


/*****************************************************************
*
* Bibliothek initialisieren.
* Die Bibliothek hat keine eigene ap_id. Trotzdem brauchen
* wir das appl_init() zur Initialisierung unseres global-Feldes.
*
*****************************************************************/

LONG cdecl slb_init( void )
{
	char *path,*name;


	/* Initialisierung */
	/* --------------- */

	if   ((appl_init()) < 0)
		return(ERROR);

	/* RSC-Datei im Pfad der SLB suchen */
	/* -------------------------------- */

	path = __text-128;
	name = strrchr(path, '\\');
	if	(name)
		name++;
	else	name = path;
	vstrcpy(name, "winframe.rsc");
	if	(!rsrc_load(path))
		{
		form_xerr(EFILNF, "winframe.rsc");
		return(EFILNF);
		}

	rsrc_gaddr(0, T_WINDOW, &adr_window);
	global_init();

	/* Manager konfigurieren */
	/* --------------------- */

	new_wfh.version = old_wfh.version = 2;
	new_wfh.wsizeof = sizeof(WININFO);
	new_wfh.whshade = 18;	/* Hoehe des ge-shade-ten Fensters */
	new_wfh.wbm_create = wbm_create;
	new_wfh.wbm_skind = wbm_skind;
	new_wfh.wbm_ssize = wbm_ssize;
	new_wfh.wbm_sslid = wbm_sslid;
	new_wfh.wbm_sstr = wbm_sstr;
	new_wfh.wbm_sattr = wbm_sattr;
	new_wfh.wbm_calc = wbm_calc;
	new_wfh.wbm_obfind = wbm_obfind;

	/* Manager anmelden */
	/* ---------------- */

	if	(!sys_set_winframe_manager(&old_wfh, &new_wfh,
					&settings))
		{
		form_xerr(ERROR, "winframe.slb");
		return(ERROR);
		}

	h_inw = settings->h_inw - 1;
	global_init2();
	return(E_OK);
}


/*****************************************************************
*
* Bibliothek aufraeumen.
* Wir duerfen kein appl_exit() machen, weil wir keine
* ap_id haben. rsrc_free() dagegen waere erlaubt, weil die
* RSC-Strukturen im global-Feld liegen.
*
*****************************************************************/

extern void cdecl slb_exit( void )
{

	/* AES-Funktionen wieder entfernen */
	/* ------------------------------- */

	sys_set_winframe_manager(&new_wfh, &old_wfh, NULL);

	rsrc_free();
}


/*****************************************************************
*
* Bibliothek oeffnen
*
*****************************************************************/

#pragma warn -par
extern LONG cdecl slb_open( PD *pd )
{
	return(E_OK);
}


/*****************************************************************
*
* Bibliothek schliessen
*
*****************************************************************/

extern void cdecl slb_close( PD *pd )
{
}
#pragma warn .par
