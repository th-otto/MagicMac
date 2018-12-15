/*********************************************************************
*
* Dieses Modul enthÑlt die MenÅbearbeitung
*
*********************************************************************/

#include <tos.h>
#include "k.h"
#include <stdlib.h>
#include <string.h>

int dirty_win = TRUE;
int dirty_pgm = TRUE;
int wndobj_len;	/* LÑnge fÅr MenÅeintrag */


/****************************************************************
*
* Initialisierung
*
****************************************************************/

void menu_init( void )
{
	ob_dsel(adr_hauptmen, MM_DATEI);
	wndobj_len = (int) strlen(adr_hauptmen[M_WIND1].ob_spec.free_string) - 2;
}


/****************************************************************
*
* Rechnet Tastencodes in MenÅeintrÑge um.
*
* RÅckgabe 1, falls Code verarbeitet.
*
****************************************************************/

int key_2_menu( int key, int kstate, int *t, int *e )
{
	register int title, entry;
	int ascii;


	if	(kstate & (K_LSHIFT + K_RSHIFT))
		return(0);

	/* Ctrl- Kombinationen */
	/* ------------------- */

	title = -1;
	ascii = (key & 0xff);
	if	((ascii >= 1) && (ascii <= 26))	/* Ctrl-A .. Ctrl-Z */
		{
		ascii = alt_keycode_2_ascii(key & 0xff00);
		switch(ascii)
			{

/* ^A    */	case 'A':	title = MM_DATEI; entry = M_SELALL;break;
/* ^F    */	case 'F':	title = MM_DATEI; entry = M_SEARCH;break;
/* ^I    */	case 'I':	key = 0x0f09 /* Tab */ ; break;
/* ^J    */	case 'J':	title = MM_DATEI; entry = M_EJECT; break;
/* ^K    */	case 'K':	title = MM_DATEI; entry = M_DCOPY;	break;
/* ^N    */	case 'N':	title = MM_DATEI; entry = M_NEUORD;break;
/* ^O    */	case 'O':	key = 0x1c0d /* Return */ ; break;
/* ^Q    *//*	case 'Q':	title = MM_DATEI; entry = M_ENDE;	break; */
/* ^U    */	case 'U':	title = MM_DATEI; entry = M_SCHLFN;break;
/* ^Z    */	case 'Z':	title = MM_ANZEI; entry = M_FONT;	break;

			}
		}

	if	(title < 0)
	switch(key)
		{

/* Retrn */		case 0x1c0d:
/* Enter */		case 0x720d:	title = MM_DATEI; entry = M_OPEN;	break;
/* Tab   */		case 0x0f09:	title = MM_DATEI; entry = M_INFO;	break;
/* ^Del  */		case 0x531f:	title = MM_DATEI; entry = M_LOESCH;break;

/* Alt-B */		case 0x3000:	title = MM_ANZEI; entry = M_ABILDR;break;
/* Alt-T */		case 0x1400:	title = MM_ANZEI; entry = M_ATEXT;	break;

#if 0
/* Alt-H */		case 0x2300:	title = MM_ANZEI; entry = M_SPALTN;break;
/* Alt-G */		case 0x2200:	title = MM_ANZEI; entry = M_ZGROES;break;
/* Alt-D */		case 0x2000:	title = MM_ANZEI; entry = M_ZDATUM;break;
/* Alt-Z */		case 0x1500:	title = MM_ANZEI; entry = M_ZZEIT;	break;
#endif

/* F1 */			case 0x3B00:	title = MM_ANZEI; entry = M_SNAME;	break;
/* F2 */			case 0x3C00:	title = MM_ANZEI; entry = M_SDATUM;break;
/* F3 */			case 0x3D00:	title = MM_ANZEI; entry = M_SGROES;break;
/* F4 */			case 0x3E00:	title = MM_ANZEI; entry = M_STYP;	break;
/* F5 */			case 0x3F00:	title = MM_ANZEI; entry = M_SNICHT;break;
/* Alt-M */		case 0x3200:	title = MM_ANZEI; entry = M_MASKE;	break;

/* Alt-L */		case 0x2600:	title = MM_OPTIO; entry = M_LAUFWE;break;
/* Alt-A */		case 0x1E00:	title = MM_OPTIO; entry = M_ANWNDG;break;
/* Alt-I */		case 0x1700:	title = MM_OPTIO; entry = M_ICASGN;break;
/* Alt-E */		case 0x1200:	title = MM_OPTIO; entry = M_EINSTE;break;
/* Alt-R */		case 0x1300:	title = MM_OPTIO; entry = M_CHGRES;break;
/* Alt-S */		case 0x1F00:	title = MM_OPTIO; entry = M_ARBSIC;break;
				default: return(0);
	}

	*t = title;
	*e = entry;
	return(1);
}


/****************************************************************
*
* FÅhrt Reaktionen auf AnwÑhlen von MenÅeintrÑgen aus.
*
****************************************************************/

void do_menu(int title, int entry, int kbsh)
{
	char path[128];
	int wnr,obj;
	WINDOW **pw,*w,*tw;
	MENUPROGRAM *mp;


	if	((entry >= M_WIND1) && (entry <= M_WIND6))
		{
		w = fenster[entry - M_WIND1 + 1];
		if	(w)
			{
			if	(kbsh & K_CTRL)
				w->closed(w, kbsh);
			else	w->topped(w);
			}
		goto ende;
		}

	if	((entry >= M_PGM1) && (entry <= M_PGM10))
		{
		mp = menuprograms + entry - M_PGM1 + INDEX_USER;
		if	((kbsh & K_CTRL) || !(mp->path[0]))
			new_program(mp, NULL, TRUE);
		else	{
			/* damit bei "single mode" Titel weiû wird: */
		     menu_tnormal(adr_hauptmen, title, 1);
			start_path(mp->path, NULL, 0);
			return;
			}
		goto ende;
		}

	tw = top_window();

     switch(entry)
     	{
     	case M_ABOUT:	dial_about();break;
     	case M_OPEN:	if	(1 == icsel(&w, &obj))
     					dclick(w, obj, /* K_CTRL*/ 0);
					break;
		case M_INFO:	obj = 0;
					for	(wnr = 0,pw = fenster;
						 wnr <= ANZFENSTER; wnr++,pw++)
						{
						w = *pw;
						if	(w)
							obj += walk_sel(w, 0L, NULL);	/* zÑhlen! */
						}
					for	(wnr = 0,pw = fenster;
						 wnr <= ANZFENSTER; wnr++,pw++)
						{
						w = *pw;
						if	(w)
							{
							if	(0 > walk_sel(w, dial_info, &obj))
								break;
							}
						}
					break;
		case M_LOESCH: if	(tw)
						cpmvdl_icns(tw, NULL, 0);
					break;
		case M_NEUORD: dial_neuord();break;
		case M_SEARCH: dial_search();break;
		case M_SCHL:	if	(tw)
						tw->key(tw, K_CTRL, 0x0e08);	/* ^H */
					break;
		case M_SCHLFN: if	(tw)
						tw->closed(tw,
							(status.use_pp) ? 0 : K_CTRL);
					break;
		case M_EJECT:	if	((1 == icsel(&w, &obj)) &&
						 (1 == obj_to_path(w, obj, path, NULL)))
						eject_medium(path);
					else
						{
						if	(tw)
							eject_medium(tw->path);
						}
					break;
		case M_SELALL: if	(tw)
						sel_all(tw);
					break;
		case M_DCOPY:  dial_deskfmt(FALSE);break;
		case M_FORMAT:	dial_deskfmt(TRUE);break;
          case M_ENDE:	wind_update(END_UPDATE);
          			shutdown((kbsh & K_ALT) ? -2 : -1, 0);
          			wind_update(BEG_UPDATE);
          			break;
          case M_ABILDR:
          case M_ATEXT:	if	(status.showtyp != entry)
          				{
          				status.showtyp = entry;
          				upd_show();
          				}
          			break;
          case M_FONT:	dial_fontsel();break;
		case M_SPALTN: status.is_1col = !status.is_1col;
					upd_col();break;
          case M_ZGROES: status.is_groesse = !status.is_groesse;
          			upd_is();break;
          case M_ZDATUM: status.is_datum = !status.is_datum;
          			upd_is();break;
          case M_ZZEIT:  status.is_zeit = !status.is_zeit;
          			upd_is();break;
          case M_SNAME:
		case M_SDATUM:
		case M_SGROES:
		case M_STYP:
		case M_SNICHT: if	(status.sorttyp != entry)
						{
						status.sorttyp = entry;
						upd_sort();
						}
					break;
		case M_MASKE:  dial_maske();break;
		case M_LAUFWE: dial_laufwe();break;
		case M_ANWNDG: dial_anwndg();break;
		case	M_ICASGN: dial_assign_icon();break;
		case M_EINSTE: dial_einste();break;
		case M_CHGRES: dial_chgres();break;
		case M_ARBSIC: dial_arbsic();break;
          }

	ende:
     menu_tnormal(adr_hauptmen, title, 1);
}


/****************************************************************
*
* Aktiviert/Desaktiviert MenÅeintrÑge je nach Kontext.
* Und zwar "zeige Info" und "formatiere"
*
****************************************************************/

void modify_menu( void )
{
	static int last_top = -1;
	static int last_sorttyp = -1;
	static int last_showtyp = -1;
	static int last_info = -1;		/* Informationen/ôffnen */
	static int last_loesch = -1;		/* lîschen */
	static int last_search = -1;		/* suchen */
	static int last_format = -1;
	static int last_eject = -1;		/* Medium auswerfen */
	static int last_1col = -1;
	static int last_isg = -1;
	static int last_isd = -1;
	static int last_isz = -1;
	static int last_mytop = -1;
	static int last_mytop0 = -1;
	static int last_anw = -1;
	static int last_asgn_icon = -1;
	int top;
	int icn,info,loesch,eject,format,search,sicn,mytop,mytop0,
		anw,typ,config,asgn_icon;
	WINDOW *w,*topw;


	if	(dirty_win || dirty_pgm)
		{
		change_objs_menu( dirty_win, dirty_pgm );
		dirty_win = dirty_pgm = FALSE;
		}

	topw = top_window();
	top = (topw) ? topw->wnr : -1;

	if	(top != last_top)
		{
		if	(last_top > 0)
			menu_icheck(adr_hauptmen, last_top+M_WIND1-1, FALSE);
		if	(top > 0)
			menu_icheck(adr_hauptmen, top+M_WIND1-1, TRUE);
		last_top = top;
		}

	icn = icsel(&w,&sicn);
	info = (icn != 0);		/* wenn irgendwas selektiert ist */
	eject = (top > 0);		/* wenn oberstes Fenster gÅltig */

	/* 1. Fall: kein oder mehrere Objekte selektiert */
	/* --------------------------------------------- */

	if	(icn != 1)
		{
			/* nix selektiert: suche im obersten Fenster */
		search = ((!icn) && (top > 0));
		format = anw = asgn_icon = FALSE;
		if	((icn) && (!w->handle))	/* mehrere Objekte in Fenster 0 */
			{
			obj_typ(fenster[0], sicn, NULL, NULL, &typ, &config, NULL);
			if	(icon[sicn-1].icontyp == ITYP_DISK)
				search = TRUE;
			}
		}

	/* 2. Fall: genau ein Objekt selektiert */
	/* ------------------------------------ */

	else {
		search = (obj_typ(w, sicn, NULL, NULL, &typ, &config, NULL)) == 1;

		/*
		{
			char s[100];
		
			strcpy(s, "\x1b" "Htyp = xx ");
			s[8] = typ >> 8;
			s[9] = typ;
			Cconws(s);
			Cnecin();
		}
		*/

		format = (typ == 'DO');
		if	(format)
			eject = TRUE;
		anw = (typ == '_X') || (typ == 'TX');
		asgn_icon = TRUE;
		}

	mytop = (0 < top);
	mytop0 = (0 <= top);

	if	(mytop != last_mytop)
		{
		menu_ienable(adr_hauptmen, M_NEUORD, mytop);
		menu_ienable(adr_hauptmen, M_SCHL, mytop);
		menu_ienable(adr_hauptmen, M_SCHLFN, mytop);
		menu_ienable(adr_hauptmen, M_MASKE, mytop);
		last_mytop = mytop;
		}

	loesch = (mytop && icn != 0 && w == topw);
	if	(loesch != last_loesch)
		{
		menu_ienable(adr_hauptmen, M_LOESCH, loesch);
		last_loesch = loesch;
		}

	if	(mytop0 != last_mytop0)
		{
		menu_ienable(adr_hauptmen, M_SELALL, mytop0);
		last_mytop0 = mytop0;
		}

	if	(anw != last_anw)
		{
		menu_ienable(adr_hauptmen, M_ANWNDG, anw);
		last_anw = anw;
		}

	if	(asgn_icon != last_asgn_icon)
		{
		menu_ienable(adr_hauptmen, M_ICASGN, asgn_icon);
		last_asgn_icon = asgn_icon;
		}

	if	(info != last_info)
		{
		menu_ienable(adr_hauptmen, M_INFO,   info);
		menu_ienable(adr_hauptmen, M_OPEN,   info);
		last_info = info;
		}

	if	(eject != last_eject)
		{
		menu_ienable(adr_hauptmen, M_EJECT, eject);
		last_eject = eject;
		}

	if	(format != last_format)
		{
		menu_ienable(adr_hauptmen, M_FORMAT, format);
		last_format = format;
		}

	if	(search != last_search)
		{
		menu_ienable(adr_hauptmen, M_SEARCH, search);
		last_search = search;
		}

	if	(status.is_1col != last_1col)
		{
		menu_icheck(adr_hauptmen, M_SPALTN, status.is_1col);
		last_1col = status.is_1col;
		}

	if	(status.is_groesse != last_isg)
		{
		menu_icheck(adr_hauptmen, M_ZGROES, status.is_groesse);
		last_isg = status.is_groesse;
		}

	if	(status.is_datum != last_isd)
		{
		menu_icheck(adr_hauptmen, M_ZDATUM, status.is_datum);
		last_isd = status.is_datum;
		}

	if	(status.is_zeit != last_isz)
		{
		menu_icheck(adr_hauptmen, M_ZZEIT,  status.is_zeit);
		last_isz = status.is_zeit;
		}

	if	(status.sorttyp != last_sorttyp)
		{
		int t;

		switch(status.sorttyp)
			{
			case M_SNAME:	t = STR_SRT_NAMES;	break;
			case M_SDATUM: t = STR_SRT_DATE;	break;
			case M_SGROES: t = STR_SRT_SIZE;	break;
			case M_STYP:	t = STR_SRT_TYPE;	break;
			case M_SNICHT: t = STR_SRT_UNSORTED;	break;
			}
		subobj_draw(adr_hauptmen, MM_SMODE, -1, Rgetstring(t));
		if	(last_sorttyp > 0)
			menu_icheck(adr_hauptmen, last_sorttyp, FALSE);
		menu_icheck(adr_hauptmen, status.sorttyp, TRUE);
		last_sorttyp = status.sorttyp;
		}

	if	(status.showtyp != last_showtyp)
		{
		if	(last_showtyp > 0)
			menu_icheck(adr_hauptmen, last_showtyp, FALSE);
		menu_icheck(adr_hauptmen, status.showtyp, TRUE);
		last_showtyp = status.showtyp;
		}
}


/****************************************************************
*
* Baut das MenÅ "Objekte" zusammen.
*
* updwin:		Fenster haben sich geÑndert.
* updpgm:		Programme haben sich geÑndert.
*
****************************************************************/

void change_objs_menu( int updwin, int updpgm )
{
	char buf[128];
	register int i;
	register OBJECT *o;
	register WINDOW *w;
	register MENUPROGRAM *mp;
	register char *s;
	int *prev;
	int last;
	int ftaste;
	int newpgm = FALSE;
	int hpos = 0;


	prev = &(adr_hauptmen[M_OBJ_BOX].ob_head);
	for	(i = M_WIND1, o = adr_hauptmen + M_WIND1;
			i <= M_PGM10; i++,o++)
		{

		/* Fenster */
		/* ------- */

		if	(i < M_TRENN)
			{
			w = fenster[i - M_WIND1 + 1];
			if	(!w)
				continue;
			if	(updwin)
				abbrev_path(o->ob_spec.free_string + 2,
						w->path, wndobj_len - 2);
			}
		else	

		/* Programme */
		/* --------- */

		if	(i > M_TRENN)
			{
			mp = menuprograms + INDEX_USER + i - M_PGM1;
			if	((!mp) || (!mp->path[0]))
				{
				if	(!newpgm)
					newpgm = i;	/* merken, daû nicht alle */
				continue;
				}
			if	(updpgm)
				{
				strcpy(buf, get_name(mp->path));
				if	(NULL != (s = strrchr(buf, '.')))
					*s = EOS;
				strcat(buf, "                    ");
				s = buf + wndobj_len-6;
				*s++ = ' ';
				*s++ = '^';
				*s++ = 'F';
				ftaste = i - M_PGM1 + 1;
				if	(ftaste < 10)
					*s++ = ftaste + '0';
				else	{
					*s++ = '1';
					*s++ = '0';
					}
				*s = EOS;
				strcpy(o->ob_spec.free_string + 2, buf);
				}
			}

		/* Trennzeichen und allg. */
		/* ---------------------- */

		*prev = i;
		prev = &(o->ob_next);
		o->ob_y = hpos;
		hpos += gl_hhchar;
		last = i;
		}

	/* ggf. neues Programm */

	if	(newpgm)
		{
		o = adr_hauptmen + newpgm;
		if	(updpgm)
			strcpy(o->ob_spec.free_string + 2,
					Rgetstring(STR_NEW));
		*prev = newpgm;
		prev = &(o->ob_next);
		o->ob_y = hpos;
		hpos += gl_hhchar;
		last = newpgm;
		}

	*prev = M_OBJ_BOX;
	adr_hauptmen[M_OBJ_BOX].ob_tail = last;
	adr_hauptmen[M_OBJ_BOX].ob_height = hpos;
}


