/*******************************************************************
*
*             MGVIEW.C                             7.7.96
*             ========
*                                 letzte énderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: MGVIEW.PRJ
*
* Modul zum Anzeigen von ASCII-Dateien.
*
* ParameterÅbergabe Åber:
*	Kommandozeile
*	ARGV
*	VA_START
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "mgview.h"
#include "gemut_mt.h"
#include "globals.h"
#include "windows.h"
#include "mgwind.h"

#define DEBUG 0


/*	int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;	*/
int	ap_id;
int text_attrib[10];			 /* Default- Textattribute */
GRECT scrg;
void close_work     (void);
WORD global[15];
int nwindows = 0;				/* Anzahl geîffneter Fenster */


/*************************************************/
/**************** HAUPTPROGRAMM ******************/
/*************************************************/

int main( int argc, char *argv[] )
{
	int i,dummy;
	WINDOW *w;
	EVNT w_ev;
	register char *s;
	register char *p,*p2;
	int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
	char path[256];



	/* Initialisierung */
	/* --------------- */

	if   ((ap_id = MT_appl_init(global)) < 0)
		Pterm(-1);
	graf_mouse(ARROW, NULL);
	wind_get_grect(SCREEN, WF_WORKXYWH, &scrg);
	vdi_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);
	open_work();
	vsf_color(vdi_handle,WHITE);           /* FÅllfarbe weiû */
	/* linksbÅndig, Zeichenzellenoberkante */
	vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);
	vqt_attributes(vdi_handle, text_attrib);
/*
	vswr_mode(vdi_handle,MD_REPLACE);      /* Replace- Modus */
	vsf_interior(vdi_handle,SOLID);        /* komplett ausfÅllen */
	Cursconf(0,0);
	if	(vq_gdos())
		vst_load_fonts(vdi_handle, 0);
*/

/*	Mrsrc_load("mgview.rsc", global);	*/

	/* Kommandozeile abarbeiten */
	/* ------------------------ */

	for	(i = 1,argv++; i < argc; i++,argv++)
		{
		open_textwind(*argv);
		}

	/* Event-Schleife */
	/* -------------- */

	while(nwindows)
		{
		w_ev.mwhich = evnt_multi(MU_KEYBD+MU_MESAG,
			  2,			/* Doppelklicks erkennen 	*/
			  1,			/* nur linke Maustaste		*/
			  1,			/* linke Maustaste gedrÅckt	*/
			  0,NULL,		/* kein 1. Rechteck			*/
			  0,NULL,		/* kein 2. Rechteck			*/
			  w_ev.msg,
			  0L,	/* ms */
			  (EVNTDATA*) &(w_ev.mx),
			  &w_ev.key,
			  &w_ev.mclicks
			  );


		if	(w_ev.mwhich & MU_KEYBD)
			{
			w = whdl2window(top_whdl());

			if	(w_ev.key == 0x1011)
				break;		/* ^Q */

			else
			if	((w_ev.key == 0x1117) && (w))
				{
				int wnr;

				wnr = (int) (find_slot_window(w) - windows);
				i = wnr;
				do	{
					i++;
					if	(i >= NWINDOWS)
						i = 0;
					if	(windows[i])
						{
						wind_set(windows[i]->handle,
								WF_TOP, 0, 0, 0, 0);
						break;
						}
					}
				while(i != wnr);
				}
			else	{
				if	(w)
					{
					w->key(w, w_ev.kstate, w_ev.key);
					w_ev.mwhich &= ~MU_KEYBD;	/* bearbeitet */
					}
				}
			}

		if	(w_ev.mwhich & MU_MESAG)
			{

			/* Fenster-Nachricht empfangen */
			/* --------------------------- */
	
			if	(((w_ev.msg[0] >= 20) &&
					(w_ev.msg[0] < 40)) ||		/* WM_XX */
				 	(w_ev.msg[0] >= 1040))
				{
				w = whdl2window(w_ev.msg[3]);
				if	(w)
					{
					w->message(w, w_ev.kstate, w_ev.msg);
					w_ev.mwhich &= ~MU_MESAG;	/* bearbeitet */
					}
				}

			if	(w_ev.mwhich & MU_MESAG)
				{
				switch(w_ev.msg[0])
					{
					case AP_TERM:
					case PA_EXIT:
						goto ende;

					/* MultiTOS-Drag&Drop empfangen */
					/* ---------------------------- */

					case AP_DRAGDROP:
						s = "U:\\PIPE\\DRAGDROP.AA";
						s[17] = ((char *) (w_ev.msg+7))[0];
						s[18] = ((char *) (w_ev.msg+7))[1];
						i = (int) Fopen(s, O_WRONLY);
						if	(i >= 0)
							{
							s[17] = DD_NAK;
							Fwrite(i, 1L, &s[17]);
							Fclose(i);
							}
						break;

					/* Kommandozeile empfangen */
					/* ----------------------- */

					case VA_START:
						s = *((char **)(w_ev.msg+3));
						while((s) && (*s))
							{
							p = path;
							p2 = p+255;
							while(*s == ' ')
								s++;		/* leading blanks */
							if	(*s == '\'')
								{
								s++;
								while((*s) && (p < p2))
									{
									if	(*s == '\'')
										{
										if	(s[1] != '\'')
											break;
										s++;		/* Doppelte ' entfernen */
										}
									*p++ = *s++;
									}
								if	(*s)
									s++;
								}
							else	{
								while(*s && (*s != ' ') && (p < p2))
									*p++ = *s++;
								}
							*p = '\0';
							if	(*s)
								s++;
							if	(path[0])
								open_textwind(path);
							}
		
						i = w_ev.msg[1];		/* Absender */
		
						w_ev.msg[0] = AV_STARTED;
						w_ev.msg[1] = ap_id;
						w_ev.msg[2] = 0;		/* keine öberlÑnge */
						/* Wort 3 und 4 unverÑndert */
						w_ev.msg[5] =
						w_ev.msg[6] =
						w_ev.msg[7] = 0;
		
						appl_write(i, 16, w_ev.msg);
						break;
					}	/* end switch */
				w_ev.mwhich &= ~MU_MESAG;
				}
			}
		}

ende:

	v_clsvwk(vdi_handle);
/*	MT_rsrc_free(global);	*/
	appl_exit();
	return(0);
}
