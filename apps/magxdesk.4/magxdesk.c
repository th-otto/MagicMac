/*********************************************************************
*
* Beginn der Programmierung: 14.3.89
*
* Dieses Modul enthÑlt die Hauptsteuerung von KAOSDESK, also die
* event_multi - Schleife.
*
*********************************************************************/

#include <tos.h>
#include "k.h"
#include <vdi.h>
#include <limits.h>
#include <string.h>
#include <stdlib.h>
#include <toserror.h>
#include "pattern.h"


WINDOW		fenster0;		/* fÅr den Desktop-Hintergrund */
WINDOW 		*fenster[ANZFENSTER+1];
GRECT		fensterg[ANZFENSTER+1];
ICON   		*icon;
char			*gmemptr = NULL;
int			n_deskicons;
MENUPROGRAM	menuprograms[ANZPROGRAMS];

char *kachel_1;			/* Kachel 1 Plane (monochrom) */
char *kachel_4;			/* Kachel 4 Planes (16 Farben) */
char *kachel_8;			/* Kachel 8 Planes (256 Farben) */
char *kachel_m;			/* Kachel > 256 Farben */
MENUPROGRAM	**kachel_path;
char *desk_col;
char *desk_patt;

char ext_bat[4];			/* Dateityp .BAT */
char ext_btp[4];			/* Dateityp .BTP */

char 	dirty_drives	[ANZDRIVES];
DISKINFO 	dinfo		[ANZDRIVES];

char const pgm_ver[] = "4.10";

int message[16];
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
int text_attrib[10];			 /* Default- Textattribute */

int ap_id;
int isfirst;					/* MAGXDESK gebootet */
int is_primary_shell;			/* Haupt-Shell */

int	aes_handle;
int	vdi_handle;
int	vdi_device;
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
GRECT desk_g,screen_g;				/* Maûe fÅr Hintergrund */
int	char_w,char_h;
int	spaltenabstand;				/* FÅr Textausgabe */
int	dirty_applicat_dat;

/* Einstellungen */

DEFAULTS status;

OBJECT *adr_hauptmen;
OBJECT *adr_laufwe;
OBJECT *adr_icons;
OBJECT *adr_einst;
OBJECT *adr_ttppar;
OBJECT *adr_about;
OBJECT *adr_cpmvdl;
OBJECT *adr_datinf;
OBJECT *adr_ordinf;

static MFDB folder_mfdb,parentfolder_mfdb;
static int folder_y_offs;
int folder_w;

static int key_2_action( int key, char ascii, int kstate );


void main()
{
	EVNTDATA ev;
	int  ev_mwhich, butt_nclicks, keycode, ascii,
		mbuttons;
	int	waitfor,mbmask,drv,client;
	register int i;
	WINDOW **pw;
	WINDOW *w;
	register WINDOW *w2;


	anfang();
	Mgraf_mouse(ARROW);
	for  (;;)
		{
		upd_drives();
		upd_infos();
		modify_menu();

		/* Wenn ein Laufwerk mit Tastatur selektiert wurde, wird 200ms	*/
		/* lang auf den zweiten Klick gewartet						*/
		/* ------------------------------------------------------------- */

		waitfor = MU_KEYBD+MU_BUTTON+MU_MESAG;

		if	(status.rtbutt_dclick)
			{
			butt_nclicks = 0x102;	/* NOT und Doppelklicks */
			mbuttons = 0;		/* keine Maustaste gedrÅckt */
			mbmask = 3;		/* beide Maustasten */
			}
		else	{
			butt_nclicks = 2;	/* Doppelklicks erkennen 	*/
			mbuttons = 1;		/* linke Maustaste gedrÅckt	*/
			mbmask = 1;		/* nur linke Maustaste		*/
			}
		
		ev_mwhich = evnt_multi(waitfor,
						  butt_nclicks,
						  mbmask,			
						  mbuttons,
						  0,0,0,0,0,		/* kein 1. Rechteck			*/
						  0,0,0,0,0,		/* kein 2. Rechteck			*/
						  message,
						  0L,	/* ms */
						  &ev.x,
						  &ev.y,
						  &ev.bstate,
						  &ev.kstate,
						  &keycode, &butt_nclicks
						  );

		/* Abfrage auf BetÑtigung einer Taste */
		/* ---------------------------------- */

		if	(ev_mwhich & MU_KEYBD)
			{
			register int i, scancode;
			int title, entry;


		 do_key:

			scancode	= (keycode >> 8) & 0xff;
			if	(ev.kstate & K_ALT)
				ascii = alt_keycode_2_ascii(keycode);
			else ascii = keycode & 0xff;
			if	(ev.kstate & (K_RSHIFT + K_LSHIFT))
				{
				ev.kstate |= K_LSHIFT;
				}
			ev.kstate &= (K_LSHIFT+K_CTRL+K_ALT);

			/* 1. Fall: Alt-Shift-[A..Z] (Fenster îffnen) */
			/* ----------------------------------------- */

			if	(ev.kstate == (K_ALT+K_LSHIFT))
				{
				drv = toupper(ascii);
				if	(drive_from_letter(drv) >= 0)
					{
					if	(0 > (i = drv_to_icn(drv)))
						goto weiter_mesag;	/* Taste verarbeitet */

					/* gefunden: Doppelklick simulieren */

					wind_update(BEG_UPDATE);
					dsel_all();
					ob_sel(fenster[0]->pobj, i+1);	/* ??? */
					obj_malen(fenster[0], i+1);
					dclick(fenster[0], i+1, 0);
					wind_update(END_UPDATE);
					goto weiter_mesag;	/* Taste verarbeitet */
					}
				}

			/* 2. Fall: Alt-1 .. Alt-9 (Auflîsungswechsel) */
			/* ------------------------------------------- */
#if 0
			if	((ev.kstate & K_ALT) &&
				 !(ev.kstate & (K_LSHIFT+K_RSHIFT+K_CTRL)) &&
				 (unsigned int) keycode >= 0x7800 &&
				 (unsigned int) keycode <= 0x8100)
				{
				i = scancode - 0x77;
				if	(i != vdi_device);
					shutdown(i, 0);
				goto weiter_mesag;	/* Taste verarbeitet */
				}
#endif

			/* 3. Fall: Ctrl-Fn (MenÅprogramm ausfÅhren) */
			/* ----------------------------------------- */

			if	((ev.kstate & K_CTRL) &&
					keycode >= 0x3b00 &&
					keycode <= 0x4600)
				{
				wind_update(BEG_UPDATE);
				start_path(menuprograms[scancode - 0x3b + INDEX_USER].path,
							NULL, ev.kstate & K_ALT);
				wind_update(END_UPDATE);
				goto weiter_mesag;	/* Taste verarbeitet */
				}

			/* 4. Fall: MenÅeintrag Åber Tastatur angewÑhlt */
			/* -------------------------------------------- */

			if	(key_2_menu( keycode, ev.kstate, &title, &entry ))
				{
				if	((title >= 0) && 
					 !(((adr_hauptmen + entry) -> ob_state) & DISABLED)
					)
					{
					wind_update(BEG_UPDATE);
					menu_tnormal(adr_hauptmen, title, FALSE);
					do_menu(title, entry, 0);
					wind_update(END_UPDATE);
					}
				goto weiter_mesag;	/* Taste verarbeitet */
				}

			/* 5. Fall: Aktion durchfÅhren */
			/* --------------------------- */

			if	(key_2_action( keycode, ascii, ev.kstate))
				goto weiter_mesag;	/* Taste verarbeitet */


			/* letzer Fall: Tastencode an Fenster durchreichen */
			/* ----------------------------------------------- */

			w = top_window();
			if	(w)
				{
				wind_update(BEG_UPDATE);
				w->key(w, ev.kstate, keycode);
				wind_update(END_UPDATE);
				}

			}


		weiter_mesag:

		/* Abfrage auf Nachricht im Nachrichtenpuffer */
		/* ------------------------------------------ */

		if	(ev_mwhich & MU_MESAG)
			{
			wind_update(BEG_UPDATE);

			if	(message[0] == MN_SELECTED)
				do_menu(message[3], message[4], ev.kstate);
			else {
				switch(message[0])
					{
					case 'AK':
						switch(message[3])
							{
						 case 0:
							re_read_icons(*(char **)(message+6));
							break;
						 case 1:
						 	status.mode_ovwr = message[4];
							break;
							}
						break;
					case AV_PATH_UPDATE:
						message[3] = drive_from_letter((**(char **)(message+3)));
				     case SH_WDRAW:
				     	if	((message[3] >= 0) &&
				     		 (message[3] < ANZDRIVES))
				     		{
							dirty_drives[message[3]] = TRUE;
							for	(i = 1,pw = fenster+1;
								i <= ANZFENSTER;
								i++,pw++)
								{
								w = *pw;
								if	((w) && (drive_from_letter(w->path[0]) == message[3]))
									dirty_drives[w->real_drive] = TRUE;
								}
							}
						else	{

							for	(i = 0; i < ANZDRIVES; i++)
								dirty_drives[i] = TRUE;
							}
						break;

					case AV_PROTOKOLL:
						client = message[1];
						message[0] = VA_PROTOSTATUS;
						message[1] = ap_id;
						message[2] =
						message[4] = message[5] = 0;
						message[3] =
							1 +		/* AV_SENDKEY */
							16 +		/* AV_OPENWIND */
							32 +		/* AV_STARTPROG */
							512 +	/* AV_PATH_UPDATE,
									   AV_WHAT_IZIT,
									   AV_DRAG_ON_WINDOW */
							1024 +	/* AV_EXIT */
							2048 +	/* AV_XOPENWIND */
							8192;	/* AV_STARTED */
						(*(char **)(message+6)) = "MAGXDESK";
						appl_write(client, 16, message);
						break;
/*
					case AV_EXIT:
						break;
*/
					case AV_SENDKEY:
						wind_update(END_UPDATE);
						ev.kstate = message[3];
						keycode = message[4];
						ev_mwhich &= ~MU_MESAG;	/* bearbeitet */
						goto do_key;

					case AV_WHAT_IZIT:
						client = message[1];
						w = whdl2window(wind_find(message[3],
											message[4]));
						if	(w)
							{
							if	(w->handle)
								{
								message[4] = VA_OB_WINDOW;
								}
							else {
								/* hier erweitern! */
								message[4] = VA_OB_UNKNOWN;
								}

							message[0] = VA_THAT_IZIT;
							message[1] = ap_id;
							message[2] =
							message[7] = 0;
							message[3] = ap_id;
							(*(char **)(message+5)) = NULL;
							appl_write(client, 16, message);
							}
						break;

					case AV_DRAG_ON_WINDOW:
						client = message[1];
						message[0] = VA_DRAG_COMPLETE;
						message[1] = ap_id;
						message[2] =
						message[3] =
						message[4] =
						message[5] =
						message[6] =
						message[7] = 0;
						appl_write(client, 16, message);
						break;

					case AV_STARTED:
						Mfree((*(char **)(message+3))-1);
						break;

					case AV_STARTPROG:
						client = message[1];
						i = start_path(*(char **)(message+3),
								*(char **)(message+5),
								-1);
						message[0] = VA_PROGSTART;
						message[1] = ap_id;
						message[2] = message[4] =
						message[5] = message[6] = 0;
						message[3] = i;
						appl_write(client, 16, message);
						if	(i == -1)
							res_exec();
						break;
					case AV_OPENWIND:
						message[7] = 0;
					case AV_XOPENWIND:
						if	(message[7] & 2)
							open_window(*(char **)(message+3),	/* path */
									  "*",				/* mask */
									  *(char **)(message+5),	/* selmask */
									  ((message[7]&1) == 0));	/* new */
						else	open_window(*(char **)(message+3),
									  *(char **)(message+5),
									  NULL,
									  ((message[7]&1) == 0));

						client = message[1];
						message[0] += (VA_WINDOPEN-AV_OPENWIND);
						message[1] = ap_id;
						message[2] = message[4] =
						message[5] = message[6] = 0;
						message[3] = 1;	/* Erfolg */
						appl_write(client, 16, message);

						break;

					case AP_DRAGDROP:
						{
						char *s;

						s = "U:\\PIPE\\DRAGDROP.AA";
						s[17] = ((char *) (message+7))[0];
						s[18] = ((char *) (message+7))[1];
						i = (int) Fopen(s, O_WRONLY);
						if	(i >= 0)
							{
							s[17] = DD_NAK;
							Fwrite(i, 1L, &s[17]);
							Fclose(i);
							}
						}
						break;

					case AP_TERM:
						wind_update(END_UPDATE);
						shutdown(-1, 0);
						wind_update(BEG_UPDATE);
						break;

					default:
						w = whdl2window(message[3]);
						if	(w)
							switch(message[0])
								{
							 case WM_REDRAW:
									redraw(w, (GRECT *) (message+4));
									break;
							 case WM_TOPPED:
							 		w->topped(w);break;
							 case WM_CLOSED:
							 	   	w->closed(w, ev.kstate);break;
							 case WM_ALLICONIFY:
									for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
										{
										w2 = *pw;
										if	((w2) && (w2->handle > 0) && (w2 != w))
											w2->iconified(w2, NULL, ICONIFIED_MODE_HIDE);
										}
									w->iconified(w, (GRECT *) (message+4), ICONIFIED_MODE_ALL);
									break;
							 case WM_ICONIFY:
							 	    w->iconified(w, (GRECT *) (message+4), ICONIFIED_MODE_NORMAL);
							 	    break;
							 case WM_UNICONIFY:
									for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
										{
										w2 = *pw;
										if	((w2) && (w2->path[0]) && (w2->handle < 0) && (w2 != w) && (w2->flags & WFLAG_ALLICONIFIED))
											w2->uniconified(w2, NULL, TRUE);
										}
							 		if	(w->flags & WFLAG_ALLICONIFIED)
								 		w->topped(w);
							 		w->uniconified(w, (GRECT *) (message+4), FALSE);
							 		break;
							 case WM_FULLED:	w->fulled(w);break;
							 case WM_ARROWED:	w->arrowed(w, message[4]);break;
							 case WM_HSLID:		w->hslid(w, message[4]);break;
							 case WM_VSLID:		w->vslid(w, message[4]);break;
							 case WM_SIZED:		w->sized(w, (GRECT *) (message+4));break;
							 case WM_MOVED:		w->moved(w, (GRECT *) (message+4));break;
						      case WM_NEWTOP:
							 case WM_UNTOPPED:	w->message(w, ev.kstate, message);break;
						     	}
						break;
					}
				}
			wind_update(END_UPDATE);
			}

		/* Abfrage auf BetÑtigung eines Mausknopfs */
		/* --------------------------------------- */

		if	(ev_mwhich & MU_BUTTON)
			{
			if	(status.rtbutt_dclick && (ev.bstate == 2))
				{
				butt_nclicks = 2;
				ev.bstate = 1;		/* Doppelklick simulieren */
				}
			mausknopf(butt_nclicks, &ev);
			}



		} /* END FOREVER */
}


/****************************************************************
*
* FÅhrt auf Tastencodes Aktionen durch.
*
* RÅckgabe 1, falls Code verarbeitet.
*
****************************************************************/

static int key_2_action( int key, char ascii, int kstate )
{
	WINDOW *w;

#if 0
/* SH-INS	*/
	if	(key == 0x5230)
		{
		status.resident = TRUE;
		return(1);
		}

/* SH-DEL	*/
	if	(key == 0x537f)
		{
		status.resident = FALSE;
		return(1);
		}
#endif

	if	((kstate == K_LSHIFT+K_ALT) && (ascii == '<'))
		{
		int  dst_apid;
		int	msg[8];

		dst_apid = appl_find("START   ");
		if	(dst_apid >= 0)
			{
			msg[0] = VA_START;
			msg[1] = ap_id;
			msg[2] = msg[3]=msg[4]=msg[5]=msg[6]=msg[7]=0;
			appl_write(dst_apid, 16, msg);
			}
		return(1);
		}

	if	(kstate & (K_LSHIFT + K_RSHIFT + K_ALT))
		return(0);

/* SPACE	*/

	if	(key == 0x3920)
		{
		w = whdl2window(top_whdl());
		if	((w) && (w->sel_maske[0]))
			return(0);	/* sonst -> Auswahl */
		}

	wind_update(BEG_UPDATE);
	switch(key)
		{

/* SPACE  */
		case 0x3920:	dsel_all();
					break;

/* Ctrl-B */
		case 0x3002:	start_path(menuprograms[INDEX_CMD].path,
					NULL, 0);
					break;

/* Ctrl-E */
		case 0x1205:	start_path(menuprograms[INDEX_EDIT].path,
					NULL, 0);
					break;

/* Ctrl-W */
		case 0x1117:	{
					WINDOW *tw;
					int i;

					tw = top_window();
					if	((!tw) || (!tw->handle))
						break;
					i = tw->wnr;
					do	{
						i++;
						if	(i > ANZFENSTER)
							i = 1;
						w = fenster[i];
						if	(w)
							{
							w->topped(w);
							break;
							}
						}
					while(i != tw->wnr);
					}
					break;

		default: 	wind_update(END_UPDATE);
						return(0);
		}
	wind_update(END_UPDATE);
	return(1);
}


/****************************************************************
*
* Initialisiert ein Popup-Objekt
*
****************************************************************/

void init_popup(OBJECT *dialog, int objnr,
			POPINFO *pop, int rscpop, int defobj)
{
	rsrc_gaddr(0, rscpop,  &(pop->tree));
	pop->obnum = defobj;
	dialog += objnr;
	dialog->ob_spec.free_string = (char *) pop;
	dialog->ob_type = G_POPUP;
}


/****************************************************************
*
* DurchlÑuft alle selektierten Objekte eines Fensters.
* Wenn die Funktion "tue" < 0 liefert, wird abgebrochen.
*
* tue == NULL:		Anzahl Objekte zÑhlen
*
* RÅckgabe: letzter Fehlercode von "tue" oder 0.
*
****************************************************************/

int walk_sel(WINDOW *w, int (*tue)(WINDOW *w, int obj, void *par), void *par)
{
	register int i,tail,ret;
	register OBJECT *tree = w->pobj;


	if	((i = (tree -> ob_head)) <= 0)
		return(0);
	tail = (tree++ -> ob_tail);
	ret = 0;
	for	(; i <= tail; i++,tree++)
		{
		if	(!(SELECTED&(tree->ob_state)) || (HIDETREE&(tree->ob_flags)))
			continue;
		if	(tue)
			{
			ret = (*tue)(w, i, par);
			if	(ret < 0)
				return(ret);
			}
		else	ret++;
		}
	return(ret);
}


/****************************************************************
*
* Bestimmt die Begrenzung aller selektierten Unterobjekte
* in absoluten Bildschirmkoordinaten.
* (rechteckige HÅlle aller selektierten Unterobjekte).
*
****************************************************************/

void tree_sel_grect(OBJECT *tree, GRECT *g)
{
	register int i,rx,ry;
	register int mx,my,mrx,mry;	/* Maxima */
	int ox,oy,tail;


	ox = tree->ob_x;
	oy = tree->ob_y;
	mx = my = INT_MAX;		/* Ecke links oben */
	mrx = mry = -INT_MAX;	/* Ecke rechts unten (auûerhalb) */

	if	((i = (tree -> ob_head)) > 0)
		{
		tail = (tree++ -> ob_tail);
		for	(; i <= tail; i++,tree++)
			{
			if	((SELECTED&(tree->ob_state)) && !(HIDETREE&(tree->ob_flags)))
				{
				rx = tree->ob_x;
				ry = tree->ob_y;
				if	(rx < mx)
					mx = rx;
				if	(ry < my)
					my = ry;
				rx += tree->ob_width;
				ry += tree->ob_height;
				if	(rx > mrx)
					mrx = rx;
				if	(ry > mry)
					mry = ry;
				}
			}
		}
	g -> g_x = mx + ox;
	g -> g_y = my + oy;
	g -> g_w = mrx - mx;
	g -> g_h = mry - my;
}



/****************************************************************
*
* Setzt die Zeichenhîhe
*
****************************************************************/

void set_char_dim( void )
{
	int dummy;
/*	unsigned int flags;
	XFNT_INFO info;	*/
	BITBLK *folder_image, *parentfolder_image;
	int folder_index,parentfolder_index;
	int out[8];


	if	(vq_gdos())
		vst_font(vdi_handle, status.fontID);
	vst_point(vdi_handle, status.fontH, &dummy, &dummy,
			&char_w, &char_h);
	/* linksbÅndig, Zeichenzellenoberkante */
	vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);

	/* Spaltenabstand fÅr Textmodus */
	vqt_extent(vdi_handle, "M", out);
	spaltenabstand = out[2] - out[0];

	if	(char_h >= 24)
		{
		folder_index = I_ORD24;
		parentfolder_index = I_PAR24;
		}
	else
	if	(char_h >= 16)
		{
		folder_index = I_ORD16;
		parentfolder_index = I_PAR16;
		}
	else	{
		folder_index = I_ORD08;
		parentfolder_index = I_PAR08;
		}

	folder_image = (adr_icons + folder_index)->ob_spec.bitblk;
	parentfolder_image = (adr_icons + parentfolder_index)->ob_spec.bitblk;

	folder_mfdb.fd_addr = folder_image->bi_pdata;
	parentfolder_mfdb.fd_addr = parentfolder_image->bi_pdata;
	folder_mfdb.fd_w = folder_image->bi_wb << 3;
	parentfolder_mfdb.fd_w = parentfolder_image->bi_wb << 3;
	folder_mfdb.fd_h = folder_image->bi_hl;
	parentfolder_mfdb.fd_h = parentfolder_image->bi_hl;
	folder_mfdb.fd_wdwidth = folder_image->bi_wb >> 1;
	parentfolder_mfdb.fd_wdwidth = parentfolder_image->bi_wb >> 1;
	folder_mfdb.fd_stand =
	parentfolder_mfdb.fd_stand = 1;
	folder_mfdb.fd_nplanes =
	parentfolder_mfdb.fd_nplanes = 1;
	/* vertikal zentrieren */
	folder_y_offs = (char_h - folder_mfdb.fd_h) >> 1;
	folder_w = folder_image->bi_hl; 	/* Breite wie Hîhe */
}


/****************************************************************
*
* Malt das Fenster <w> im Bereich
* neu_x,neu_y,neu_b,neu_h  nach.
*
****************************************************************/

void redraw( WINDOW *w, GRECT *neu)
{
	if	(w->handle > 0 && !w->path[0])
		return;						/* Fenster geschlossen */
	objc_wdraw( w->pobj, 0, 1, neu, w->handle);
}


/****************************************************************
*
* gibt Nummer des "Fensters" zurÅck, in dem selektierte Objekte
* liegen.
*
* RÅckgabe : *rw = WINDOW *
*		   	  = NULL			kein Objekt selektiert
*		   *objn =  Nummer des 1. selekt. Objekts oder undef.
*
*            icsel = 0	kein Objekt selektiert
*			    = 1   genau ein Objekt selektiert
*                  = -1  mehrere Objekte selektiert
*
****************************************************************/

int icsel(WINDOW **rw, int *objn)
{
	OBJECT *tree;
	register WINDOW **pw;
	register WINDOW *w;
	register int wnr,i;


	*rw = NULL;
	for	(wnr = 0,pw = fenster; wnr <= ANZFENSTER; wnr++,pw++)
		{
		w = *pw;
		if	(!w)
			continue;				/* Fenster unbenutzt */
		if	(!w->pobj)
			continue;				/* auch unbenutzt */
		tree = w->pobj;
		if	((i = (tree -> ob_head)) > 0)
			{
			for	(; i <= (tree -> ob_tail); i++)
				{
				if	(!((tree+i)->ob_flags & HIDETREE) && selected(tree, i))
					{
					if	(*rw)	/* noch einer ! */
						return(-1);
					*rw = w;		/* erster gefundener */
					*objn = i;
					}
				}
			}
		}
	return(*rw != NULL);		/* nix gefunden */
}


/****************************************************************
*
* Ermittelt das Icon zu Laufwerk <drv> ('A'..'Z')
*
****************************************************************/

int drv_to_icn(int drv)
{
	register int i;

	for	(i = 0; i < n_deskicons; i++)
		if	(icon[i].isdisk == drv)
			return(i);
	return(-1);
}


/****************************************************************
*
* Rechnet Fensterhandle in WINDOW um.
*
****************************************************************/

WINDOW *whdl2window(int whdl)
{
	register int i;
	register WINDOW **pw,*w;


	for	(i = 0,pw = fenster; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && ((w)->handle == whdl))
			return(w);
		}
	return(NULL);
}


/****************************************************************
*
* Gibt an, ob ein Objekt ein Ziel fÅr ein Verschieben von Icons
* sein kann.
* GÅltiges Ziel sind Ordner (O_), Laufwerke (?D), Programme bzw.
* angemeldete Dateien (?P), Batchprogramme (?B),
* Papierkorb und Drucker.
*
****************************************************************/

int is_dest(WINDOW *w, int objnr)
{
	int obtyp,config;
	MYDTA *dummy;

	obj_typ(w, objnr, NULL, &dummy, &obtyp, &config, NULL);
	return((obtyp == '_X') || (obtyp == 'BX') ||
		  (obtyp == 'DO') || (obtyp == '_O') ||
		  (obtyp == 'P_') || (obtyp == 'D_'));
}


/****************************************************************
*
* Zeichnet den Ausschnitt x,y,b,h des Fensters
* neu.
*
****************************************************************/

/*
void zeichne( WINDOW *w, int gx, int gy, int gw, int gh)
{
		objc_draw(w->pobj,0,1,gx,gy,gw,gh);
}
*/


/****************************************************************
*
* Zeichnet die benutzerdefinierten Objekte (Texte verschiedener
* Grîûe). Textgrîûe und Ausrichtung auf Zellenoberkante ist schon
* eingestellt.
* Der Clippingbereich wird nur dann neu gesetzt, wenn sich dieser
* geÑndert hat, dadurch werden einige vs_clip()'s gespart.
*
****************************************************************/

int clip_rect[4];

int cdecl draw_userdef(PARMBLK *p)
{
	char *s,*t,*fname;
	register int wnr;
	register WINDOW **pw,*w;
	register MYDTA *m;
	int	isalias,isdir,isparentdir;
	int	dummy;
	int	pxy[4];
	char buf[256];
	static int last_cursive = FALSE;
	int pos,offs;


	for	(wnr = 0,pw = fenster; wnr <= ANZFENSTER; wnr++,pw++)
		{
		w = *pw;
		if	((w) && (w->pobj == p->pb_tree))
			goto found;
		}
	return(0);
	found:
	pxy[0] = p->pb_xc;
	pxy[1] = p->pb_yc;
	pxy[2] = pxy[0] + p->pb_wc - 1;
	pxy[3] = pxy[1] + p->pb_hc - 1;
	m = (w->pmydta)[p->pb_obj - 1];
	if	(pxy[0] != clip_rect[0] || pxy[1] != clip_rect[1] ||
		 pxy[2] != clip_rect[2] || pxy[3] != clip_rect[3])
		{
		clip_rect[0] = pxy[0];
		clip_rect[1] = pxy[1];
		clip_rect[2] = pxy[2];
		clip_rect[3] = pxy[3];
		vs_clip(vdi_handle, TRUE, pxy);
		}
	fname = m -> filename;
	isdir = ((m -> attrib) & FA_SUBDIR);
	isparentdir = (isdir) && (!strcmp(fname, ".."));
	isalias = (int) m->is_alias;
	if	(isalias != last_cursive)
		{
		vst_effects(vdi_handle, isalias << 2);	/* kursiv! */
		last_cursive = isalias;
		}

	pos = p->pb_x;

	/* FÅr den Fall, daû nicht der Systemfont verwendet wird,	*/
	/* muû fÅr Ordner ein Icon ausgegeben werden				*/
	/* -------------------------------------------------------- */

	offs = 0;
	if	((status.fontID != 1) && (isdir))
		{	/* G_IMAGE fÅr Ordner ausgeben */
		int col[2] = {BLACK,WHITE};
		MFDB mfdb_scr;
		MFDB *mfdb_ic;
		int pxy[8];


		mfdb_ic = (isparentdir) ? &parentfolder_mfdb : &folder_mfdb;

		pxy[0] = pxy[1] = 0;
		pxy[2] = mfdb_ic->fd_w - 1;
		pxy[3] = mfdb_ic->fd_h - 1;
		pxy[4] = pos;
		pxy[5] = p->pb_y + folder_y_offs;
		pxy[6] = pos + pxy[2];
		pxy[7] = p->pb_y + pxy[3];

		mfdb_scr.fd_addr = NULL;

		vrt_cpyfm(vdi_handle, MD_TRANS, pxy,
				mfdb_ic, &mfdb_scr, col);
		if	(!status.font_is_prop)
			{
			pos += 3 * char_w;
			offs = 3;
			}
		}

	/* 1. Fall: proportionaler Font			*/
	/* Die Ausgabe erfolgt einzeln in Spalten	*/
	/* ----------------------------------------- */

	if	(status.font_is_prop)
		{
		pos += folder_w + 4;

		if	(w->dos_mode && status.show_8p3 && (!isparentdir))
			{
			t = strchr(fname, '.');
			if	(t)
				*t = EOS;
			v_gtext(vdi_handle, pos, p->pb_y, fname);
			pos += 8 + w->xtab_namelen;
			if	(t)
				{
				*t++ = '.';
				v_gtext(vdi_handle, pos, p->pb_y, t);
				}
			pos += spaltenabstand + w->xtab_typelen;
			}
		else	{
			v_gtext(vdi_handle, pos, p->pb_y, fname);
			pos += 8 + w->xtab_namelen;
			}

		if	(isparentdir)
			goto ende;		/* keine weitere Ausgabe */

		if	(status.is_groesse)
			{
			pos += w->xtab_sizelen;
			if	(!isdir)
				{
				if	(m->filesize > 9999999L)
					{
					ultoa((m -> filesize) >> 10L, buf, 10);
					strcat(buf, "k");
					}
				else	ultoa(m -> filesize, buf, 10);
				/* Ausrichtung rechts */
				vst_alignment(vdi_handle, 2, 5, &dummy, &dummy);
				v_gtext(vdi_handle, pos,	p->pb_y, buf);
				vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);
				}
			pos += spaltenabstand;
			}

		if	(status.is_datum)
			{
			date_to_str(buf, m -> date);
			v_gtext(vdi_handle, pos,	p->pb_y, buf);
			pos += spaltenabstand + w->xtab_datelen;
			}

		if	(status.is_zeit)
			{
			time_to_str(buf, m -> time);
			buf[5] = EOS;
			v_gtext(vdi_handle, pos,	p->pb_y, buf);
			}
		}

	/* 2. Fall: nichtproportionaler Font		*/
	/* Die Ausgabe erfolgt in einem Rutsch		*/
	/* ----------------------------------------- */

	else	{
		s = t = buf;

		*s++ = ' ';
		if	((m -> icontyp == ITYP_ORDNER) && (status.fontID == 1))
			*s++ = '\7';		/* Zeichen fÅr Ordner */
		else if	(m->icontyp == ITYP_PROGRA)
				*s++ = '.';
			else *s++ = ' ';
		*s++ = ' ';
		if	(w->dos_mode && status.show_8p3 && (!isparentdir))
			{
			if	(*fname == '.' && fname[1] == EOS)
				*s++ = *fname++;
			else while(*fname != '.' && *fname != EOS)
					*s++ = *fname++;
			if	(*fname == '.')
				fname++;
			t += 12;
			while(s < t)
				*s++ = ' ';
			t += 3;
			}
		else	{
			strcpy(s, fname);
			t += 3+w->max_fname;
			}

		if	(isparentdir)
			goto gtext;		/* keine weitere Ausgabe */

		while(*fname)
			*s++ = *fname++;
		while(s < t)
			*s++ = ' ';

		if	(status.is_groesse)
			{
			char gr[10],*g;

			if	(isdir)
				gr[0] = EOS;
			else {
				if	(m->filesize > 9999999L)
					{
					ultoa((m -> filesize) >> 10L, gr, 10);
					strcat(gr, "k");
					}
				else	ultoa(m -> filesize, gr, 10);
				}
			for	(wnr = 8 - (int) strlen(gr); wnr > 0; wnr--)
				*s++ = ' ';
			g = gr;
			while(*g)
				*s++ = *g++;
			}
		if	(status.is_datum)
			{
			*s++ = ' ';
			*s++ = ' ';
			date_to_str(s, m -> date);
			s += 8;
			}
		if	(status.is_zeit)
			{
			*s++ = ' ';
			*s++ = ' ';
			time_to_str(s, m -> time);
			s += 5;
			}
		*s = EOS;
	    gtext:
		v_gtext(vdi_handle, pos, p->pb_y, buf+offs);
		}
    ende:
	return(p -> pb_currstate);
}

USERBLK userblk = {draw_userdef, 0L};


/****************************************************************
*
* Setzt den Clippingbereich auf die Bildschirmgrîûe.
*
****************************************************************/

void set_deflt_clip( void )
{
	clip_rect[0] = desk_g.g_x;
	clip_rect[1] = desk_g.g_y;
	clip_rect[2] = desk_g.g_x + desk_g.g_w-1;
	clip_rect[3] = desk_g.g_y + desk_g.g_h-1;
	vs_clip	(vdi_handle, TRUE, clip_rect);
}


/*********************************************************************
*
* Allgemeine Routinen
*
*********************************************************************/


void open_work(void)
{
	register int i;


	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);
	vswr_mode(vdi_handle,MD_REPLACE);      /* Replace- Modus */
	vsf_color(vdi_handle,WHITE);           /* FÅllfarbe weiû */
	vsf_interior(vdi_handle,SOLID);        /* komplett ausfÅllen */
	vqt_attributes(vdi_handle, text_attrib);
	Cursconf(0,0);
	if	(vq_gdos())
		vst_load_fonts(vdi_handle, 0);
	/* set_char_dim(); */
}


/****************************************************************
*
* MenÅzeile abschalten
* Speicher fÅr Fenster freigeben
* Desktop- Hintergrund abmelden
* Fenster schlieûen und lîschen
*
****************************************************************/

int deflt_topwnr = -1;

void close_all_wind( void )
{
	register int i;
	register WINDOW **pw,*w;
		    /* int dummy; */


	/* Default- Zeichengrîûe wieder einstellen */
/*
	vst_height(vdi_handle, text_attrib[7], &char_w, &char_h, &dummy, &dummy);
*/
	w = top_window();
	deflt_topwnr = (w) ? w->wnr : -1;
	menu_bar(adr_hauptmen, FALSE);
	wind_set_ptr_int(SCREEN, WF_NEWDESK, NULL, 0);	/* Desktop- Hintergrund */
	for	(i = 1,pw=fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	(w)         /* wenn Fenster existiert... */
			{
			if	(w->flags & WFLAG_ICONIFIED)
				{
				wind_get_grect(w->handle, WF_UNICONIFY, &w->out);
				}
			wind_close(w->handle);  /* ...dann schlieûen */
			wind_delete(w->handle); /* ...und immer lîschen!  */
			fensterg[i] = w->out;
			Mfree(w);
			*pw = NULL;
			}
		}
}


/****************************************************************
*
* Macht einen Shutdown
*
* dev == -1:		Shutdown
* sonst:			Auflîsungswechsel mit dev/txt
*
* Wird beim MenÅpunkt "Ende" mit (-1,0) aufgerufen.
* Wird beim MenÅpunkt "Alt-Ende" mit (-2,0) aufgerufen.
* Wird beim MenÅpunkt "Auflîsung wechseln" mit (0,0) aufgerufen.
*
****************************************************************/

#pragma warn -par
void shutdown( int dev, int txt )
{
	char shutdown_prg[128];


	if	(is_primary_shell)
		{
		strcpy(shutdown_prg, desk_path);
		if	(dev >= 0)
			strcat(shutdown_prg, "chgres.prg");
/*
			{
#if			COUNTRY==COUNTRY_DE
			if	(1 != form_alert(1, "[2][Auflîsungswechsel ?][ OK | Abbruch ]"))
				return;
#elif		COUNTRY==COUNTRY_US
			if	(1 != form_alert(1, "[2][Change resolution ?][ OK | Cancel ]"))
				return;
#endif
			}
		itoa(dev, tail+1, 10);
		strcat(tail+1, " ");
		itoa(txt, tail+1+strlen(tail+1), 10);
		tail[0] = (char) strlen(tail+1);
*/
		else	strcat(shutdown_prg, "shutdown.prg");

		if	(status.save_on_exit)
			save_status(TRUE);		/* VOR close_all_wind() */

		close_all_wind();
		if	(vq_gdos())
			vst_unload_fonts(vdi_handle, 0);
		v_clsvwk(vdi_handle);
		/* Pfade an den Parent weiterreichen: */
		Dsetdrv(drive_from_letter(desk_path[0]));
		Dsetpath(desk_path);
		shel_write(TRUE, TRUE, SHW_SINGLE, shutdown_prg, "");
		/* und Programm aufrufen */
		shel_write(TRUE, TRUE, SHW_CHAIN, shutdown_prg,
			(dev == -2) ? "\1""1" : "");
		}
	else
	if	(status.save_on_exit)
		save_status(TRUE);

	rsrc_free();
	appl_exit();
	Pterm0();
}
#pragma warn +par


/****************************************************************
*
* Ein Tastencode fÅr Fenster 0 muû verarbeitet werden.
* Er wird einfach ignoriert.
*
****************************************************************/

#pragma warn -par
static void wind0_keyed( WINDOW *w, int kstate, int key )
{
}
static void wind0_fulled( WINDOW *w )
{
}
static void wind0_closed( WINDOW *w, int kstate )
{
}
#pragma warn +par


/****************************************************************
*
* Initialisierung aller Fenster, ggf. îffnen
*
****************************************************************/

void open_all_wind( void )
{
	register int i,j,set;
	long ret;


	Mgraf_mouse(HOURGLASS);
	for	(i = 0; i < ANZDRIVES; i++)
		dinfo[i].b_clsiz = 0L;		/* ungÅltig */

	/* MenÅzeile auf den Bildschirm */
	/* ---------------------------- */

	menu_bar(adr_hauptmen, TRUE);

	/* Icons installieren und malen */
	/* ---------------------------- */

	fenster0.wnr = fenster0.handle = 0;
	fenster0.key = wind0_keyed;
	fenster0.fulled = wind0_fulled;
	fenster0.closed = wind0_closed;
	*((GRECT *) &(fenster0.pobj->ob_x)) = screen_g;
	wind_set_ptr_int(SCREEN, WF_NEWDESK, fenster0.pobj, 0);
	form_dial_grect(FMD_FINISH, NULL, &screen_g);

	/* Fenster îffnen */
	/* -------------- */

	set_char_dim();		/* Zeichengrîûe einstellen */

#if 0
	for	(i = 1; i <= ANZFENSTER; i++)
		{
		fenster[i].handle = -1;			/* unbenutzt			*/
		fenster[i].memblk = NULL; 		/* kein allozierter Speicher */
		}
#endif

	for	(set = FALSE,i = 1; i <= ANZFENSTER; i++)
		{
		j = i;
		if	(i == deflt_topwnr)
			{
			j = ANZFENSTER;
			set = TRUE;
			}
		if	(set && i == ANZFENSTER)
			j = deflt_topwnr;
		if	(fenster[j])
			{
			ret = opn_wnd(fenster[j], TRUE);
			if	(ret == ENOWND)
				ret = ENSMEM;
			err_alert(ret);
			}
		}
	set_deflt_clip();
	Mgraf_mouse(ARROW);
}


/****************************************************************
*
* Laden und Initialisieren der Ressource- Datei.
*
****************************************************************/

static void _rsrc_load( char *fname )
{
	if	(!rsrc_load(fname))
		{
		form_xerr(EFILNF, fname);
		appl_exit();
		Pterm((int) EFILNF);
		}
}

void get_rsc(void)
{
	register int i;
	register OBJECT *image;
	int      isfirst;

	isfirst = (*((void **) (aes_global+7)) == NULL);
	if	(isfirst)								/* erster Start */
		{
		OBJECT *tree;

		desk_path[0] = letter_from_drive(Dgetdrv());
		desk_path[1] = ':';
		Dgetpath(desk_path+2, 0);
		strcat(desk_path, "\\");

		_rsrc_load("magxdesk.rsc");
		rsrc_gaddr(0, HAUPTMEN, &adr_hauptmen);
		rsrc_gaddr(0, T_ICONS,  &adr_icons);
		rsrc_gaddr(0, T_EINST, &adr_einst);
		rsrc_gaddr(0, T_TTPPAR, &adr_ttppar);
		rsrc_gaddr(0, T_ABOUT,  &adr_about);
		rsrc_gaddr(0, T_DATINF, &adr_datinf);
		rsrc_gaddr(0, T_ORDINF, &adr_ordinf);
		tree = adr_hauptmen;
#define fix_menu(obj) \
		if ((tree[obj].ob_x + tree[obj].ob_width + 2) > (desk_g.g_x + desk_g.g_w)) \
			tree[obj].ob_x = desk_g.g_x + desk_g.g_w - tree[obj].ob_width - 2
		if ((tree[MM_OBJS].ob_x + tree[MM_OBJS].ob_width) > (desk_g.g_x + desk_g.g_w))
		{
			tree[MM_ANZEI].ob_spec.free_string = Rgetstring(STR_SHORT_VIEW);
			tree[MM_ANZEI].ob_width = ((WORD)strlen(tree[MM_ANZEI].ob_spec.free_string) + 1) * gl_hwchar;
			tree[MM_OPTIO].ob_x = tree[MM_ANZEI].ob_x + tree[MM_ANZEI].ob_width;
			tree[MM_OBJS].ob_x = tree[MM_OPTIO].ob_x +tree[MM_OPTIO].ob_width;
		}
		fix_menu(M_FILE_BOX);
		fix_menu(M_DISPLAY_BOX);
		fix_menu(M_OPTION_BOX);
		fix_menu(M_OBJ_BOX);
#undef fix_menu
		load_app_icons();
		}

	/* Icongrîûen fÅr Auflîsungen korrigieren */
#if 0
	for	(i = I_FLPDSK; i <= I_BTCHDA; i++)
		{
		(adr_icons+i) -> ob_width  = 72;
		(adr_icons+i) -> ob_height = 36;
		}
#endif

	if	(!isfirst)
		return;
	/* Gruppenrahmen anpassen */
#if 0
	i = gl_hhchar >> 1;
	(adr_einste+EINST_S1)->ob_y		+= i;
	(adr_einste+EINST_S1)->ob_height	+= i;
	(adr_einste+EINST_S2)->ob_y		+= i;
	(adr_einste+EINST_S2)->ob_height	+= i;
	(adr_einste+EINST_R1)->ob_y -= i;
	(adr_einste+EINST_R2)->ob_y -= i;
	(adr_cpmvdl+CPMVD_R1)->ob_y -= i;
	(adr_datinf+FI_R1   )->ob_y -= i;
	(adr_ordinf+OI_R1   )->ob_y -= i;
#endif
	image = adr_about + ABOU_IMG;
	image->ob_height = image->ob_spec.bitblk->bi_hl;
	while((image->ob_y + image->ob_height > (adr_about + ABOU_OS) -> ob_y) &&
		 (image->ob_y > 0))
		image->ob_y--;

	strcpy ((adr_about + ABOU_VER)->ob_spec.tedinfo->te_ptext+11, pgm_ver);
	(adr_about + ABOU_OS)->ob_spec.free_string = os_ver_s;
	i = adr_about->ob_width;
	i -= (int) strlen(os_ver_s) * gl_hwchar;
	i /= 2;
	if	(i < 0)
		i = 0;
	(adr_about + ABOU_OS)->ob_x = i;

	allg_init();
	menu_init();
	dialogs_init();
	windows_init();
}


/****************************************************************
*
* Initialisierung von MAGIXDESK (AES,RSC,VDI,Fenster,Icons,MenÅ).
* MAGIXDESK wird immer im eigenen Verzeichnis gestartet.
*
****************************************************************/

void anfang(void)
{
	register int i;
	char srcmd[128],srtail[128];
	SHELTAIL *sht;


	Pdomain(1);

	for	(i = 0; i < ANZDRIVES; i++)
		dirty_drives[i] = FALSE;

	/* Applikation beim AES anmelden und Version feststellen */
	/* ----------------------------------------------------- */

	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);

	aes_handle = vdi_handle =
	graf_xhandle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox,
						 &vdi_device);
	wind_get_grect(SCREEN, WF_WORKXYWH, &desk_g);
	screen_g.g_x = screen_g.g_y = 0;
	screen_g.g_w = desk_g.g_x+desk_g.g_w;
	screen_g.g_h = desk_g.g_y+desk_g.g_h;

	/* TOS- Version und GEM- Variablen fÅr spÑter merken */
	/* ------------------------------------------------- */

	get_syshdr();		/* bestimmt aesvars, inf_name[0] (drv) */
	shel_read(srcmd, srtail);

	is_primary_shell = FALSE;
	isfirst = FALSE;

	if	(!srcmd[0])	/* Name muû leer sein */
		{
		sht = (SHELTAIL *) srtail;
		if	(sht->dummy == 0 && sht->magic == 'SHEL')
			is_primary_shell = TRUE;
		isfirst = sht->isfirst;
		}

	get_rsc();

	/* VDI - Workstationhandle holen */
	/* ----------------------------- */

	open_work();

	wind_update(BEG_UPDATE);

	/* Koordinaten des Desktop- Fensters initialisieren */
	/* ------------------------------------------------ */

	fenster[0] = &fenster0;		/* alle anderen Zeiger sind NULL */
	fenster0.handle = SCREEN;
	fenster0.in = fenster0.out = desk_g;
	fenster0.pmydta	= NULL;

	/* numplanes-abhÑngige Variablen */
	/* ----------------------------- */

	kachel_1 = kachel_4 = kachel_8 = kachel_m = NULL;
	if	(aes_global[10] < 4)	/* 2,4 oder 8 Farben */
		{
		kachel_path = (MENUPROGRAM **) (&kachel_1);
		desk_col = &(status.desk_col_1);
		desk_patt = &(status.desk_patt_1);
		}
	else	{
		desk_col = &(status.desk_col_4);
		desk_patt = &(status.desk_patt_4);
		if	(aes_global[10] < 8)	/* 16 Farben */
			kachel_path = (MENUPROGRAM **) (&kachel_4);
		else
		if	(aes_global[10] == 8)	/* 256 Farben */
			kachel_path = (MENUPROGRAM **) (&kachel_8);
		else	kachel_path = (MENUPROGRAM **) (&kachel_m);
		}
	

	/* INF- Datei laden oder Defaults setzen */
	/* ------------------------------------- */

	load_status(0);
	load_status(1);

	open_all_wind();

	/* Wenn keine Laufwerke da sind, "Laufwerke finden" */
	/* ------------------------------------------------ */

	for	(i = 0; i < n_deskicons; i++)
		{
		if	(icon[i].isdisk)
			goto disk_found;
		}

	dial_laufwe();		/* Laufwerke anmelden */
	disk_found:

	/* ggf. Disknamen initialisieren */
	/* ----------------------------- */

	if	(status.dnam_init)
		{
		for	(i = 0; i < n_deskicons; i++)
			{
			register int j;
			int  drv;
			static char *pth = "X:\\";
			char name[65];
	
			if	(!icon[i].isdisk)
				nexticn:
				continue;
			drv = icon[i].isdisk;
			for	(j = 1; j <= ANZFENSTER; j++)
				{
				if	((fenster[j]) && (fenster[j]->path[0] == drv))
					goto nexticn;
				}
			if	(drv == 'A' || drv == 'B')		/* nicht fÅr A: und B: */
				continue;
			name[0] = EOS;
			pth[0] = drv;
			Dreadlabel(pth, name, 65);
			set_dname(drive_from_letter(drv), name);
			}
		}

	wind_update(END_UPDATE);

	/* Wenn APPLICAT.INF verÑndert wurde, muû	*/
	/* APPLICAT.DAT neu aufgebaut werden		*/
	/* ----------------------------------------- */

	if	(dirty_applicat_dat)
		{
		starte_dienstpgm("APPLICAT.APP", FALSE, FALSE,
						"-c", NULL, NULL );
		dirty_applicat_dat = FALSE;
		}
}
