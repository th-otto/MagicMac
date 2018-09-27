/****************************************************************
*
*             MMXDAEMON.PRG                             28.12.03
*             =============
*                                 letzte énderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: MMXDAEMON.PRJ
*
* Fragt Apple-Events 'odoc' ab, d.h. Atari-Programme sind
* doppelgeklickt oder auf das MagicMacX-Programm-Icon
* gezogen worden.
*
****************************************************************/

#define DEBUG 0

#include <tos.h>
#include <aes.h>
/*
#include <vdi.h>
*/
#include <string.h>
#include <stdlib.h>
#include "mmxdaemn.h"
#include "toserror.h"
#include "av.h"
#if DEBUG
#include <stdio.h>
#endif

/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;

#define SHUTDOWNPRG "C:\\GEMSYS\\GEMDESK\\SHUTDOWN.PRG"

typedef unsigned long UINT32;
typedef long INT32;
typedef unsigned char UINT8;
typedef unsigned int UINT16;
#include "mmx_xcmd.h"


#define POLL_INTERVAL	500L		/* milliseconds */

/*
static XCMD_CMD *pXCMD_CMD;
static XCMD_EXEC *pXCMD_EXEC;
*/
static MMX_DAEMN *pMMX_DAEMN;
static int ap_id;


/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

static COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}


/*********************************************************************
*
* Initialisieren der beiden Funktionszeiger.
* Der erste verwaltet die Bibliothek, der zweite ruft
* Bibliotheksfunktionen auf.
*
*********************************************************************/

static long init(void)
{
	COOKIE *pMMXCookie;
	struct MgMxCookieData *pMMXCookieData;


	pMMXCookie = getcookie('MgMx');
	if	(!pMMXCookie)
	{
/*
		printf("MgMx-Cookie nicht gefunden");
*/
		return(-1);
	}

	pMMXCookieData = (struct MgMxCookieData *) pMMXCookie->value;
	if	(pMMXCookieData->mgmx_magic != 'MgMx')
		return(-2);

/*
	pXCMD_CMD = pMMXCookieData->mgmx_xcmd;
	pXCMD_EXEC = pMMXCookieData->mgmx_xcmd_exec;
*/
	pMMX_DAEMN = pMMXCookieData->mgmx_daemon;

	return(0);
}


/*********************************************************************
*
* Sendet AV_STARTPROG an die Shell.
*
*********************************************************************/

static void SendStartprog(char *cmd)
{
	WORD	msg[16];


	msg[0] = AV_STARTPROG;
	msg[1] = ap_id;	/* Absender */
	msg[2] = 0;		/* keine öberlÑnge */
	/* Wort 3 und 4: Zeiger auf Programmnamen */
	*((char **)(msg+3)) = cmd;
	/* Wort 5 und 6: Zeiger auf Kommandozeile */
	*((char **)(msg+5)) = "\0";
	msg[7] = 0;
	msg[8] = 0;
	msg[9] = 0;
	msg[10] = 0;
	msg[11] = 0;
	msg[12] = 0;
	msg[13] = 0;
	msg[14] = 0;
	msg[15] = 0;
	/* Nachricht an App #0 (Shell)*/
	appl_write(0, 16, msg);
}

/*********************************************************************
*
* Sendet MN_SELECTED an MAGXDESK
*
*********************************************************************/

static void SendMnSelected(void)
{
	WORD	msg[16];


	msg[0] = MN_SELECTED;
	msg[1] = ap_id;	/* Absender */
	msg[2] = 0;		/* keine öberlÑnge */
	msg[3] = 6;		/* MenÅbaum */
	msg[4] = 59;		/* MenÅ-Eintrag */
	msg[5] = 0;
	msg[6] = 0;
	msg[7] = 0;
	msg[8] = 0;
	msg[9] = 0;
	msg[10] = 0;
	msg[11] = 0;
	msg[12] = 0;
	msg[13] = 0;
	msg[14] = 0;
	msg[15] = 0;
	/* Nachricht an App #0 (Shell)*/
	appl_write(0, 16, msg);
}


/*************************************************/
/**************** HAUPTPROGRAMM ******************/
/*************************************************/

int main(void)
{
	char buf[256];
	EVNT w_ev;
	int bShutdown = 0;


	Pdomain(1);

	if   ((ap_id = appl_init()) < 0)
	{
		Pterm(-1);
	}

	/* verstehe AP_TERM */
	shel_write(SHW_INFRECGN, 1, 0, (void * )0, (void *) 0);

	if	(init())
	{
		appl_exit();
		Pterm((int) EFILNF);
	}

	/* Endlosschleife */

	buf[0] = '\0';
	for	(;;)
	{
		w_ev.mwhich = evnt_multi(MU_TIMER+MU_MESAG,
			  2,			/* Doppelklicks erkennen 	*/
			  1,			/* nur linke Maustaste		*/
			  1,			/* linke Maustaste gedrÅckt	*/
			  0,0,0,0,0,		/* kein 1. Rechteck			*/
			  0,0,0,0,0,		/* kein 2. Rechteck			*/
			  w_ev.msg,
			  POLL_INTERVAL,	/* ms */
			  &w_ev.mx,
			  &w_ev.my,
			  &w_ev.mbutton,
			  &w_ev.kstate,
			  &w_ev.key,
			  &w_ev.mclicks
			  );

		/* Timer */
		/* ----- */

		if	(w_ev.mwhich & MU_TIMER)
		{
			/* PrÅfung auf shutdown */

			if	((!bShutdown) && (pMMX_DAEMN(2, NULL)))
			{
				/* Shutdown vom MacOS aus initiiert */
/*
				shel_write(1, 1, SHW_PARALLEL, SHUTDOWNPRG, "\0");
*/
				if	(0 == appl_find("MAGXDESK"))
					SendMnSelected();
				else
					SendStartprog(SHUTDOWNPRG);

				bShutdown = 1;
			}

			/* Solange buf[0] noch ungleich 0 ist, warten wir
			   auf VA_PROGSTART */

			if	((!buf[0]) && (!pMMX_DAEMN(1, buf)) && (buf[0]))
			{
				SendStartprog(buf);
			}
		}

		/* Nachricht */
		/* --------- */

		if	(w_ev.mwhich & MU_MESAG)
		{
			if	(w_ev.msg[0] == VA_PROGSTART)
			{
				/* Antwort auf AV_STARTPROG */
				buf[0] = '\0';
			}
			if	(w_ev.msg[0] == AP_TERM)
				break;
		}
	}
	appl_exit();
	return(0);
}
