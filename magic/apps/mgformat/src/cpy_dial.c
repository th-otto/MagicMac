/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Disketten kopieren"
*
*/

#include <mgx_dos.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include <country.h>
#include "mgformat.h"
#include "gemut_mt.h"
#include "globals.h"


#define TRUE   1
#define FALSE  0
#define EOS    '\0'
#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif

OBJECT *adr_cpydsk;
static int is_iconified = FALSE;
static struct fmt_parameter fmt_parameter;


/*********************************************************************
*
* Initialisierung der Objektklasse "Disk-Kopierdialog"
*
*********************************************************************/

void cpy_dial_init_rsc( int src_dev, int dst_dev )
{
	extern int gl_hhchar;


	MT_rsrc_gaddr(0, T_CPYDSK, &adr_cpydsk, global);
	(adr_cpydsk+CPYDS_R1)->ob_y -= gl_hhchar >> 1;
	*((adr_cpydsk + CPYDS_QU)->ob_spec.free_string) = src_dev + 'A';
	*((adr_cpydsk + CPYDS_ZI)->ob_spec.free_string) = dst_dev + 'A';
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Diskettenkopierdialogs
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*		-2:	Nachricht int data[8] wurde Åbergeben
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/

static void fmt_feedb(void *d, char *action, int n)
{
	MYsubobj_wdraw(d, CPYDS_DO, -1, action);
	MYsubobj_wdraw(d, CPYDS_DT,  n, NULL);
}

#pragma warn -par

WORD	cdecl hdl_cpydsk( void *d, EVNT *events,
				WORD exitbutton, WORD clicks, void *data )
{
	OBJECT *tree;
	char newlw[2];
	int	source_drv, dest_drv;
	extern int disk_type(int drvnr);


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_cpydsk;

	if	(exitbutton == HNDL_INIT)
		{
		if	(d_cpydsk)			/* Dialog ist schon geîffnet ! */
			return(0);			/* create verweigern */

		objs_hide(adr_cpydsk, CPYDS_SI, CPYDS_TR, CPYDS_SC, CPYDS_DO, CPYDS_DT,
					  CPYDS_H1, CPYDS_H2, CPYDS_H3, CPYDS_H4,  0);

		d_cpydsk = d;
		return(1);
		}

	/* 2. Fall: Fensternachricht empfangen */
	/* ----------------------------------- */

	if	(exitbutton == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		switch(events->msg[0])
			{
			int action;

			 case WM_ALLICONIFY:
	
			 case WM_ICONIFY:
			 	wdlg_set_iconify(d, (GRECT *) (events->msg+4),
			 							" MGFORMAT ",
			 							adr_iconified, 1);
			 	is_iconified = TRUE;
			 	break;
	
			 case WM_UNICONIFY:
			 	wdlg_set_uniconify(d, (GRECT *) (events->msg+4),
			 							"DISKCOPY",
			 							adr_cpydsk);
			 	is_iconified = FALSE;
				break;

			case 1040:
					if	(is_iconified)
						break;

					if	(events->msg[5])
						action = (events->msg[5] == 1) ? STR_WRITE : STR_FORMAT;
					else action = STR_READ;
					if	(wind_update(BEG_UPDATE | 0x100))
						{
						fmt_feedb(d, Rgetstring(action, global),
								events->msg[4]);
						wind_update(END_UPDATE);
						}
					break;
			case 1041:
					if	(events->msg[4] == 0)
						Rform_alert(1, AL_DISKCP_COMPL, global);
					goto abbruch;
			case 1042:
					Rform_alert(1, AL_DISKCP_BREAK, global);
					abbruch:
					wind_update(BEG_UPDATE);
					objs_hide(tree, CPYDS_SI, CPYDS_TR, CPYDS_SC, CPYDS_DO, CPYDS_DT,
						           CPYDS_H1, CPYDS_H2, CPYDS_H3, CPYDS_H4,  0);
					if	(!is_iconified)
						{
						MYsubobj_wdraw(d, CPYDS_SI, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_TR, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_SC, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_DO, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_DT, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_H1, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_H2, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_H3, -1, NULL);
						MYsubobj_wdraw(d, CPYDS_H4, -1, NULL);
						}

					if	(selected(tree, CPYDS_OK))	/* Kopieren aktiv */
						{
						ob_dsel(tree, CPYDS_OK);
						(tree+CPYDS_OK)->ob_state &= ~DISABLED;

						if	(!is_iconified)
							MYsubobj_wdraw(d, CPYDS_OK,  -1, NULL);
						}
					wind_update(END_UPDATE);
					break;
			case 1043:
					if	(is_iconified)
						break;

					wind_update(BEG_UPDATE);
					MYsubobj_wdraw(d, CPYDS_SI, events->msg[4], NULL);
					MYsubobj_wdraw(d, CPYDS_TR, events->msg[5], NULL);
					MYsubobj_wdraw(d, CPYDS_SC, events->msg[6], NULL);
					wind_update(END_UPDATE);

					break;
			}
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(exitbutton == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		d_cpydsk = NULL;
		send_message_break(wdlg_get_handle( d ));
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(exitbutton < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(clicks != 1)
		goto ende;

	if	(exitbutton == CPYDS_EX)
		{
		open_format_options();
		goto ende;
		}

	if	(exitbutton == CPYDS_AB)			/* Abbruch */
		{
		if	(selected(tree, CPYDS_OK))		/* Kopieren aktiv */
			{
			send_message_break(wdlg_get_handle( d ));	/* Aktion abbrechen */
			goto ende;
			}
		goto close_dialog;
		}

	source_drv = *((tree + CPYDS_QU)->ob_spec.free_string) - 'A';
	dest_drv   = *((tree + CPYDS_ZI)->ob_spec.free_string) - 'A';

	if	(exitbutton == CPYDS_ZI)			/* Ziel- Laufwerk */
		{
		lw_anzeig:

		do	{
			dest_drv++;				/* nÑchstes Laufwerk */
			dest_drv %= 32;			/* maximal 32 Laufwerke */
			}
		while(dest_drv != 0 && dest_drv > 1 /* && disk_type(dest_drv) != 'FD'*/ );

		newlw[0] = dest_drv + 'A';
		newlw[1] = EOS;
		MYsubobj_wdraw(d, exitbutton, -1, newlw);
		return(1);
		}
		
	if	(exitbutton == CPYDS_QU)			/* Quell- Laufwerk */
		{
		dest_drv = source_drv;
		goto lw_anzeig;
		}

	objs_unhide(tree, CPYDS_SI, CPYDS_TR, CPYDS_SC, CPYDS_DO, CPYDS_DT,
				   CPYDS_H1, CPYDS_H2, CPYDS_H3, CPYDS_H4,  0);

	if	(!is_iconified)
		{
		MYsubobj_wdraw(d, CPYDS_H1, -1, NULL);
		MYsubobj_wdraw(d, CPYDS_H2, -1, NULL);
		MYsubobj_wdraw(d, CPYDS_H3, -1, NULL);
		MYsubobj_wdraw(d, CPYDS_H4, -1, NULL);
		}

	fmt_parameter.action = action_copydisk;
	fmt_parameter.apid = ap_id;
	fmt_parameter.do_format = selected(tree, CPYDS_FM);
	fmt_parameter.whdl = wdlg_get_handle( d );
	fmt_parameter.src_dev = source_drv;
	fmt_parameter.dst_dev = dest_drv;
	start_format(&fmt_parameter);

	(tree+CPYDS_OK)->ob_state |= DISABLED;
	if	(!is_iconified)
		MYsubobj_wdraw(d, CPYDS_OK,  -1, NULL);
	return(1);

	ende:
	ob_dsel(tree, exitbutton);
	MYsubobj_wdraw(d, exitbutton,  -1, NULL);
	return(1);		/* weiter */
}
#pragma warn +par
