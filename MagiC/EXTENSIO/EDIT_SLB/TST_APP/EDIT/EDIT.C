/****************************************************************
*
* EDIT
* ====
*
* Beginn der Programmierung:	20.7.97
* letzte énderung:
*
* Programm zur Entwicklung eines Mehrzeilen-Editfeldes mit
* GDOS-ZeichensÑtzen.
*
****************************************************************/

#include <mgx_dos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "edit.h"


#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif

#define TRUE   1
#define FALSE  0
#define EOS    '\0'
#define ABS(X) ((X>0) ? X : -X)


OBJECT *adr_dialog;
DIALOG *d_dialog;
WORD	cdecl hdl_dialog( DIALOG *d, EVNT *events,
				WORD exitbutton, WORD clicks, void *data );

int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int aes_handle;		/* Screen-Workstation des AES */

/* fÅr die SharedLib */
SLB_EXEC	slbexec;
SHARED_LIB  slb;

static char path[128];
static char fname[128];

/* editob */

XEDITINFO *xedit;
unsigned char *buf = NULL;
LONG buflen;

char _buf[1024] =
	"Hallo, ich bin es! Hier steht jetzt eine"
	" ganze Reihe Zeugs.\r\n"
	"Dies ist jetzt die zweite Zeile. Und auch hier steht was.";

int main( void )
{
	EVNT w_ev;
	WORD whdl_dialog;
	LONG err;


	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	if	(!rsrc_load("edit.rsc"))
		Pterm(-1);

	if	(!rsrc_gaddr(R_TREE, T_DIALOG, &adr_dialog))
		Pterm(-1);

	/* SharedLib laden */
	/* --------------- */

	err = Slbopen("EDITOBJC.SLB", NULL, 1L, &slb, &slbexec, 0L);
	if	(err < 0)
		Pterm((WORD) err);

	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	/* RSC initialisieren */

	xedit = edit_create();
	if	(!xedit)
		Pterm(-1);
	adr_dialog[EDITFELD].ob_type = G_EDIT;
	adr_dialog[EDITFELD].ob_spec.index = (long) xedit;
	edit_set_buf( adr_dialog, EDITFELD, _buf, sizeof(_buf));
	edit_open( adr_dialog, EDITFELD );

	/* END RSC */

	graf_mouse(ARROW, NULL);

	d_dialog = wdlg_create(hdl_dialog,
						adr_dialog,
						NULL,
						0,
						NULL,
						0);
	if	(!d_dialog)
		goto fehler;

	whdl_dialog = wdlg_open( d_dialog,
						"EDIT",
						NAME+CLOSER+MOVER,
						-1,-1,
						0,
						NULL );
	if	(!whdl_dialog)
		goto fehler;


	for	(;;)
		{
		w_ev.mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
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

		edit_evnt( adr_dialog, EDITFELD, whdl_dialog,
					&w_ev );

		if	(d_dialog && !wdlg_evnt(d_dialog, &w_ev))
			{
			wdlg_close(d_dialog, NULL, NULL);
			wdlg_delete(d_dialog);
			d_dialog = NULL;
			break;
			}

		if	(w_ev.mwhich & MU_MESAG)
			{
			if	(w_ev.msg[0] == AP_TERM)
				break;
			}
		} /* END FOREVER */

fehler:
	if	(slb)
		Slbclose( slb );
	rsrc_free();
	appl_exit();
	return(0);
}


/*********************************************************************
*
* Objekte deselektieren/selektieren/Status abfragen
*
*********************************************************************/

int selected(OBJECT *tree, int which)
{
	return( ((tree+which)->ob_state & SELECTED) ? 1 : 0 );
}

void ob_dsel(OBJECT *tree, int which)
{
	(tree+which)->ob_state &= ~SELECTED;
}

void ob_sel_dsel(OBJECT *tree, int which, int sel)
{
	if	(sel)
		(tree+which)->ob_state |=  SELECTED;
	else (tree+which)->ob_state &= ~SELECTED;
}

void ob_sel(OBJECT *tree, int which)
{
	(tree+which)->ob_state |= SELECTED;
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

void objc_grect(OBJECT *tree, int objn, GRECT *g)
{
	OBJECT *o;
	int x,y,nx,ny;

	o = tree + objn;
	objc_offset(tree, objn, &nx, &ny);
	if	(((o -> ob_type == G_BUTTON) || (o -> ob_type == G_FTEXT)) &&
		 (o-> ob_flags & FL3DMASK))
		{
		x = o->ob_x;
		y = o->ob_y;
		form_center(o, g);
		g->g_x += nx - o->ob_x;
		g->g_y += ny - o->ob_y;
		o->ob_x = x;
		o->ob_y = y;
		}
	else	{
		g -> g_x = nx;
		g -> g_y = ny;
		g -> g_w = o -> ob_width;
		g -> g_h = o -> ob_height;
		}
}


/*********************************************************************
*
* PrÅft, ob der Mausklick ins Objekt ging.
*
*********************************************************************/

WORD xy_in_grect( WORD x, WORD y, GRECT *g )
{
	return((x >= g->g_x) && (x < g->g_x+g->g_w) &&
		  (y >= g->g_y) && (y < g->g_y+g->g_h));
}


/*********************************************************************
*
* Ermittelt zu einem vollen Pfadnamen den Zeiger auf den
* reinen Dateinamen
*
*********************************************************************/

char *get_name(char *path)
{
	register char *n;

	n = strrchr(path, '\\');
	if	(!n)
		{
		if	((*path) && (path[1] == ':'))
			path += 2;
		return(path);
		}
	return(n + 1);
}


/****************************************************************
*
* Malt ein Unterobjekt eines Fensters
*
****************************************************************/

void subobj_wdraw(void *d, int obj, int startob, int depth)
{
	OBJECT *tree;
	GRECT g;


	wdlg_get_tree( d, &tree, &g );
	objc_grect(tree, obj, &g);
	wdlg_redraw( d, &g, startob, depth );
}



/****************************************************************
*
* WÑhlt einen Zeichensatz aus.
*
****************************************************************/

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )
#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE )

int dial_font( long *id, long *pt, int *mono, char *name )
{
	int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
	int	handle;
	register int i;
	FNT_DIALOG *fnt_dialog;
	int button,check_boxes;
	long ratio;
	int dummy;


	for( i = 1; i < 10 ; i++ )											/* work_in initialisieren */
		work_in[i] = 1;
	work_in[10] = 2;		/* Rasterkoordinaten benutzen */
	handle = aes_handle;
	v_opnvwk( work_in, &handle, work_out );

	ratio = (1L<<16L);
	fnt_dialog = fnts_create( handle, 0, FONT_FLAGS, FNTS_3D,
				  "Was Shumway Your favourite Gordon?", 0L );
	if	(!fnt_dialog )
		return(0);
	button = fnts_do( fnt_dialog, BUTTON_FLAGS, *id, *pt, ratio,
			&check_boxes, id, pt, &ratio );
	if	(button == FNTS_OK)
		{
/*
		char s[100];
		Cconws("\x1b" "Hid=");
		ltoa(*id, s, 16);
		Cconws(s);
		Cconws("        pt=");
		ltoa(*pt, s, 16);
		Cconws(s);
		Cconws("        ratio=");
		ltoa(ratio, s, 16);
		Cconws(s);
		Cconws("        ");
		Cnecin();
*/
		if	(!fnts_get_info(fnt_dialog, *id, mono, &dummy ))
			*mono = FALSE;
		if	(name)
			{
			fnts_get_name(fnt_dialog, *id, name, NULL, NULL);
			}
		}
	fnts_delete( fnt_dialog, handle );
	v_clsvwk(handle);
	return(button == FNTS_OK);
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs
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

#pragma warn -par

WORD	cdecl hdl_dialog( DIALOG *d, EVNT *events,
				WORD exitbutton, WORD clicks, void *data )
{
	OBJECT *tree;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_dialog;

	if	(exitbutton == HNDL_INIT)
		{
		if	(d_dialog)			/* Dialog ist schon geîffnet ! */
			return(0);			/* create verweigern */

		d_dialog = d;
		return(1);
		}

	/* 2. Fall: Fensternachricht empfangen */
	/* ----------------------------------- */

	if	(exitbutton == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(exitbutton == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(exitbutton < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(clicks != 1)
		goto ende;

	if	(exitbutton == LOAD)			/* Datei laden */
		{
		long ret;
		int ret2,file;
		char *s;
		XATTR xa;
		unsigned char *nbuf;


		s = get_name(path);
		*s = '\0';
		if	(fsel_exinput(path, fname, &ret2, "Datei laden..."))
			{
			if	(ret2)
				{
				s = get_name(path);
				strcpy(s, fname);

				ret = Fopen(path, RMODE_RD);
				if	(ret > 0)
					{
					file = (int) ret;

					ret = Fcntl(file, (long) (&xa), FSTAT);
					if	(ret < 0)
						goto errf;

					nbuf = Malloc(xa.size+1);
					if	(!nbuf)
						goto errf;

					ret = Fread(file, xa.size, nbuf);
					if	(ret != xa.size)
						{
						Mfree(nbuf);
						goto errf;
						}

					nbuf[xa.size] = '\0';
					edit_close( adr_dialog, EDITFELD );
					if	(buf)
						Mfree(buf);
					buf = nbuf;
					edit_set_buf(adr_dialog, EDITFELD,
								(char *) buf, xa.size);

					edit_open( adr_dialog, EDITFELD );
					subobj_wdraw(d, EDITFELD, EDITFELD, 1);
					errf:
					Fclose(file);
					}
				}
			}
		goto ende;
		}

	if	(exitbutton == SAVEAS)			/* Datei sichern */
		{
		long ret;
		int ret2,file;
		char *s;
		char *buf;
		long txtlen;


		s = get_name(path);
		*s = '\0';
		if	(fsel_exinput(path, fname, &ret2, "Datei sichern..."))
			{
			if	(ret2)
				{
				s = get_name(path);
				strcpy(s, fname);

				ret = Fcreate(path, 0);
				if	(ret > 0)
					{
					file = (int) ret;

					edit_get_buf(adr_dialog, EDITFELD,
								&buf, &ret, &txtlen);
					Fwrite(file, txtlen, buf);
					Fclose(file);
					}
				}
			}
		goto ende;
		}

	if	(exitbutton == AUTOWRAP)		/* Autom. Zeilenumbruch */
		{
		WORD autowrap;

		edit_close( adr_dialog, EDITFELD );

		autowrap = selected(adr_dialog, AUTOWRAP) ?
				adr_dialog[EDITFELD].ob_width : 0;
		edit_set_format(adr_dialog, EDITFELD, -1, autowrap);
		edit_open( adr_dialog, EDITFELD);
		subobj_wdraw(d, EDITFELD, EDITFELD, 1);
		return(1);
		}

	if	(exitbutton == FONT)				/* Zeichensatz */
		{
		long id,pt;
		WORD fid,fpt;
		WORD mono;

		edit_get_font(adr_dialog, EDITFELD,
						&fid, &fpt, &mono);
		id = fid;
		pt = (((long) fpt)<<16L);
		if	(dial_font(&id, &pt, &mono, NULL))
			{
			edit_close( adr_dialog, EDITFELD );

			edit_set_font(adr_dialog, EDITFELD, (WORD) id, (WORD) (pt>>16L), mono);

			edit_open( adr_dialog, EDITFELD );
			subobj_wdraw(d, EDITFELD, EDITFELD, 1);
			}
		goto ende;
		}

	if	(exitbutton == ENDE)				/* Abbruch */
		{
		goto close_dialog;
		}

	return(1);

	ende:
	ob_dsel(tree, exitbutton);
	subobj_wdraw(d, exitbutton, exitbutton, 1);
	return(1);		/* weiter */
}
#pragma warn +par
