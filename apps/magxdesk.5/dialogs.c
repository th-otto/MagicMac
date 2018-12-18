/*********************************************************************
*
* Dieses Modul enthÑlt alle Bearbeitung von Dialogen
*
*********************************************************************/

#include <tos.h>
#include <toserror.h>
#include "k.h"
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <sys/stat.h>
#include "pattern.h"
#include <wdlgfslx.h>


static POPINFO pop_kategorie;
static int curr_kat = EIN_GRP1;


/****************************************************************
*
* Initialisierung
*
****************************************************************/

void dialogs_init( void )
{
	init_popup(adr_einst, EIN_KAT, &pop_kategorie, T_POPKAT, 1);
	adr_einst[EIN_BAT].ob_spec.tedinfo->te_ptext = ext_bat;
	adr_einst[EIN_BTP].ob_spec.tedinfo->te_ptext = ext_btp;
	adr_einst[EIN_BAT].ob_spec.tedinfo->te_txtlen =
	adr_einst[EIN_BTP].ob_spec.tedinfo->te_txtlen = 4;

	objs_hide(adr_einst, EIN_GRP2, EIN_GRP3, EIN_GRP4, EIN_GRP5, 0);
	objs_uneditable(adr_einst, EIN_CMD, EIN_BAT, EIN_BTP,
					EIN_SHOW, EIN_PRNT, EIN_EDIT,
					EIN_KACH, 0);
	objs_unhide(adr_einst, EIN_GRP1, 0);

	adr_datinf[FI_FLDATTR].ob_x = adr_datinf[FI_DRIVEATTR].ob_x =
					adr_datinf[FI_FILEATTR].ob_x;
	adr_datinf->ob_width = 38 * gl_hwchar;
	adr_datinf->ob_height = 20 * gl_hhchar;
	objs_hide(adr_datinf, FI_CONTSTR, FI_DISKLETTER, 0);
}


/****************************************************************
*
* Initialisiert ein scrollbares Eingabefeld fÅr den Namen
* einer Datei oder eines Ordners.
*
* ob		Das Objekt
* path	Der Pfad fÅr den Dateinamen
* txt	der eigentliche Textpuffer (groû genug!)
* vislen	Anzahl sichtbarer Zeichen bzw. Ressource-x-Einheiten
*
*
****************************************************************/

long init_xted(OBJECT *ob, char *path, XTED *xted,
					char *txt, char *old, int *is_8_3,
					int vislen)
{
	long err;
	int maxnamelen;
	register TEDINFO *t;
	static char *tmplt_8_3 = "________.___";


	err = Dpathconf(path, DP_NAMEMAX);
	if	(err > 0L)
		{
		maxnamelen = (int) err;
		*is_8_3 = (Dpathconf(path, DP_TRUNC) == DP_DOSTRUNC);
		}
	else	{
		*is_8_3 = TRUE;
		if	(err != EINVFN)
			return(err_alert(err));
		}

	t = ob->ob_spec.tedinfo;
	t->te_ptext = txt;
	if	(*is_8_3)
		{
		t->te_txtlen = 12;
		t->te_ptmplt = tmplt_8_3;
		t->te_pvalid = "f";
		vislen = 13;
		}
	else	{
		t->te_tmplen = t->te_txtlen = maxnamelen + 1;
		xted->xte_pvalid = "m";
		xted->xte_scroll = 0;
		xted->xte_ptmplt =	"________________________________"
						"________________________________";
		t->te_ptmplt = NULL;
		t->te_pvalid = (void *) xted;
		xted->xte_vislen = maxnamelen;
		if	(xted->xte_vislen > vislen)
			xted->xte_vislen = vislen;
		}
	ob->ob_width =	vislen*gl_hwchar;

	if	(*is_8_3)
		fname_int(old, txt);
	else	strcpy(txt, old);

	return(E_OK);
}


/****************************************************************
*
* Der Dialog "Neues Programm in MenÅleiste eintragen".
* oder "IMG fÅr Kachel anwÑhlen"
*
****************************************************************/

int new_program( MENUPROGRAM *mp, char *type, int ispgm )
{
	char *s;
	char c;
	char	path[128];
	char	fname[64+2];	/* ggf. lange Namen! */
	int ret;
	char *title;


	fname[0] = path[0] = EOS;
	if	(mp->path[0])
		{
		s = get_name(mp->path);
		if	(strlen(s) < 64)
			{
			strcpy(fname, s);
			c = *s;
			*s = EOS;
			strcpy(path, mp->path);
			*s = c;
			}
		}
	if	(type)
		strcat(path, type);

	title = Rgetstring((ispgm) ? STR_INST_NEW_PGM : STR_CHOOSE_PATTN);
	if	(!fsel_exinput(path, fname, &ret, title))
		return(-1);	/* Fehler */

	if	(!ret)
		return(1);	/* Abbruch */

	if	(!fname[0])			/* kein Programm eingetragen */
		mp->path[0] = EOS;
	else	{
		*get_name(path) = EOS;		/* "*.*" wegmachen */
		strcpy(mp->path, path);
		strcat(mp->path, fname);
		}
	if	(ispgm)
		dirty_pgm = TRUE;
	return(0);
}


/****************************************************************
*
* Der Dialog "Arbeit sichern".
*
****************************************************************/

void dial_arbsic(void)
{
	if	(1 == Rxform_alert(1, ALRT_SAVE_WORK, 0, inf_name))
		save_status(TRUE);
}


/****************************************************************
*
* Der Eintrag "Åber MagiC..." ist angewÑhlt worden.
*
****************************************************************/

void dial_about(void)
{
	do_dialog(adr_about);
}


/****************************************************************
*
* Der Eintrag "Informationen..." ist angewÑhlt worden.
*
* RÅckgabe:	< 0		abbrechen
*
****************************************************************/

static int info_spec(int typ, int weiter)
{
	int id;


	switch(typ)
		{
		case 'P_':
			id = ALRT_TRASH_INFO;
			break;
		case 'D_':
			id = ALRT_PRINTR_INFO;
			break;
		default:
			err_alert(EINTRN);
			return(0);
		}

	if	(2 == Rxform_alert(1, id, 0,
				(weiter) ? Rgetstring(STR_STOP) : ""))
		return(-1);
	return(0);
}


/*
*
* is_weiter ist ein Zeiger auf int und zeigt auf
* die Anzahl der selektierten Objekte. dial_info()
* dekrementiert diese Zahl bei jedem Aufruf und
* weiû daher, wann das letzte Objekt kommt.
*
*/

int dial_info(WINDOW *w, int obj, void *is_weiter)
{
	int typ,ret,config,mal;
	char	path[256+2];
	int drv;
	long err;
	MYDTA *file;
	XATTR xa;
	OBJECT *o;
	int weiter,number;
	static int hinum;	/* Gesamtanzahl Infos */
	extern CICONBLK *std_dat_icon;
	int isfolder,isdrive,isdeskalias;



	mal = FALSE;

	if	((*((int *) is_weiter)) > hinum)
		hinum = (*((int *) is_weiter));

	(*((int *) is_weiter))--;
	weiter = *((int *) is_weiter);
	number = hinum - weiter - 1;
	if	(!weiter)
		hinum = 0;

	ret = obj_typ(w, obj, path, &file, &typ, &config, NULL);

	/* ret: 0 = Datei, 1 = Pfad, -1 = sonstiges */
	/* tatsÑchliches Laufwerk bestimmen fÅr korrektes set_dirty */
	drv = (w->handle) ? w->real_drive : -1;

	/* spezielles Objekt: Papierkorb oder Drucker */
	/* ------------------------------------------ */

	if	(ret == -1)
		{
		return(info_spec(typ, weiter));
		}

	if	(ret)
		{
		isfolder = TRUE;
		if	(typ == 'DO')
			isdrive = TRUE;
		else	isdrive = FALSE;
		path[strlen(path) - 1] = EOS;		/* abschl. '\' weg */
		}
	else	isfolder = isdrive = FALSE;


	/* Datei oder Ordner auf dem Desktop */
	/* --------------------------------- */

	if	(file == NULL && !isdrive &&
				((typ & 0xff) == 'O' || ret == 0))
		{
		file = Malloc(sizeof(MYDTA) + strlen(path) + 2);
		if	(!file)
			{
			err_alert(ENSMEM);
			return(-1);
			}
		mal = TRUE;
		Mgraf_mouse(HOURGLASS);
		err = Fxattr(1, path, &xa);	/* Symlinks nicht folgen */
		if	(!err && ((xa.st_mode & S_IFMT) == S_IFLNK))
			{
			XATTR xa2;

			file->is_alias = TRUE;
			err = Fxattr(0, path, &xa2);
			if	(!err)
				xa = xa2;
			else	err = E_OK;
			}
		else	file->is_alias = FALSE;

		Mgraf_mouse(ARROW);
		if	(err != E_OK)
			{
			Mfree(file);
			err_alert(err);
			return(0);
			}
		file->time = xa.st_mtim.u.d.time;
		file->date = xa.st_mtim.u.d.date;
		file->filesize = xa.st_size;
		strcpy(file->filename, get_name(path));
		file->attrib   = xa.st_attr;
		file->mode = xa.st_mode;

		o = w->pobj+obj;
		if	(o->ob_type == G_CICON)
			file->ciconblk = *(o->ob_spec.ciconblk);
		else	file->ciconblk = *std_dat_icon;
		isdeskalias = TRUE;
		}
	else	isdeskalias = FALSE;

	ret = info_file(path, drv, file, isfolder, isdrive,
					isdeskalias, weiter, number);
	if	(mal)
		Mfree(file);
	return(ret);
}


/****************************************************************
*
* Der Eintrag "Maske setzen..." ist angewÑhlt worden.
*
****************************************************************/

void dial_maske(void)
{
	OBJECT *adr_maske;
	char	oldmask[20];
	register char *quel,*ziel;
	int ret;
	WINDOW *w;


	w = top_window();
	if	(!w)
		return;
	rsrc_gaddr(0, T_MASKE, &adr_maske);
	ziel = ((adr_maske+MASKE_TX)->ob_spec.tedinfo)->te_ptext;
	quel = w->maske;
	strcpy(ziel, quel);
	ret = do_dialog(adr_maske);
	if	(ret != MASKE_OK && ret != MASKE_AL)
		return;
	strcpy(oldmask, quel);
	if	(ret == MASKE_AL)
		strcpy(quel, "*");
	else	strcpy(quel, ziel);
	if	(strcmp(oldmask, quel))
		upd_mask(w);
}


/****************************************************************
*
* Der Eintrag "Neuer Ordner..." ist angewÑhlt worden.
*
****************************************************************/

void dial_neuord(void)
{
	char	all[258];
	char txt[65];
	char *name;
	XTED xted;
	OBJECT *adr_neuord;
	WINDOW *w;
	int   ret;
	long  doserr;
	int is_8_3;


	w = top_window();
	if	(!w)
		return;
	strcpy(all, w->path);
	rsrc_gaddr(0, T_NEUORD, &adr_neuord);
	if	(init_xted(adr_neuord+NEUORD_T, all, &xted, txt,
				"", &is_8_3, 25))
		return;
	ret = do_dialog(adr_neuord);
	if	(ret != NEORD_OK || !txt[0])
		return;
	name = all+strlen(all);
	if	(is_8_3)
		fname_ext(txt, name);
	else	strcpy(name, txt);
	Mgraf_mouse(HOURGLASS);
	doserr = Dcreate(all);
	set_dirty(doserr, NULL, w->real_drive, 1);
	err_alert(doserr);
	Mgraf_mouse(ARROW);
	if	(doserr == EPTHNF)
		{
		w->path[3] = EOS;	/* zurÅck zur Root */
		upd_path(w, FALSE);
		}
}


/****************************************************************
*
* Der "Dialog" "Formatieren".
* Der "Dialog" "Diskette kopieren".
*
* Es wird ein externes Programm gestartet, das unter dem Eintrag
* DESKFMT= im Environment angemeldet ist.
*
****************************************************************/

void dial_deskfmt( int is_fmt )
{
	char *arg1,*arg2,*arg3;
	char	tail[128];
	register char	*pgm;
	int config;
	WINDOW *w;



	if	(is_fmt)
		{
		char path2[128];
		int ret,obj,typ;


		/* Feststellen, welches Laufwerk formatiert werden soll */
		/* ---------------------------------------------------- */

		if	(1 != icsel(&w, &obj))
			return;
		ret = obj_typ(w, obj, path2, NULL, &typ, &config, NULL);
		if	((ret != 1) || (typ != 'DO'))	/* nur, wenn Disk- Icon */
			return;

		if	(path2[0] <= 'B')
			arg1 = "-f";
		else	arg1 = "-fh";		/* Harddisks mit Flag "-fh" formatieren */

		arg2 = "X:";
		arg2[0] = path2[0];	/* "pgmname -f[H] X:" fÅr Laufwerk X: */
		arg3 = NULL;
		}
	else	{
		arg1 = "-c";
		arg2 = "A:";
		arg3 = "A:";	/* Immer von A: nach A: kopieren */
		}

	pgm = getenv("DESKFMT");
	if	(pgm)
		{
		strcpy(tail+1, arg1);
		if	(arg2)
			{
			strcat(tail+1, " ");
			strcat(tail+1, arg2);
			}
		if	(arg3)
			{
			strcat(tail+1, " ");
			strcat(tail+1, arg3);
			}
		start_path(pgm, tail+1, 0);
		}
	else	starte_dienstpgm("MGFORMAT.PRG", FALSE, FALSE,
				arg1, arg2, arg3);
}


/****************************************************************
*
* Der Dialog "Suchen".
*
* Es wird ein externes Programm gestartet, das unter dem Namen
* MGSEARCH.APP im GEMDESK-Ordner liegen muû.
*
* Parameter:
*
* -Dabcdef (Liste der zu durchsuchenden Laufwerke)
*
*	oder
*
* -P<path>
*
****************************************************************/

void dial_search( void )
{
	char	arg[140];
	register char *s;
	register int i;
	register OBJECT *tree;
	char c;
	int	icn,sicn;
	WINDOW *w;


	icn = icsel(&w,&sicn);
	s = arg;
	*s++ = '-';

	if	(!icn)	/* nix selektiert */
		{
		*s++ = 'P';		/* ab Pfad suchen */
		w = top_window();
		if	(!w)
			return;
		strcpy(s, w->path);
		}
	else
	if	(icn < 0)		/* mehrere Objekte => Disks! */
		{
		/* selektierte Disk-Icons merken */

		tree = fenster[0]->pobj;
		*s++ = 'D';
		*s = EOS;
		if	((i = (tree -> ob_head)) > 0)
			{
			for	(; i <= (tree -> ob_tail); i++)
				{
				if	(!((tree+i)->ob_flags & HIDETREE) && selected(tree, i))
					{
					c = icon[i-1].isdisk;
					if	(c)
						*s++ = c;
					}
				}
			}
		*s = EOS;
		}
	else	{		/* genau ein Objekt selektiert */
		*s++ = 'P';
		if	(obj_to_path(w, sicn, s, NULL) <= 0)
			return;	/* kein Ordner */
		}

	starte_dienstpgm("MGSEARCH.APP", TRUE, FALSE,
					arg, NULL, NULL);
}


int drive_from_letter(int drv)
{
	if (drv >= 'A' && drv <= 'Z')
		drv = drv - 'A';
	else if (drv >= 'a' && drv <= 'z')
		drv = drv - 'a';
	else if (drv >= '1' && drv <= '6')
		drv = (drv - '1') + 26;
	else
		return -1;
	return drv;
}


int letter_from_drive(int drv)
{
	return drv >= 26 ? drv - 26 + '1' : drv + 'A';
}


/****************************************************************
*
* Die Aktion "Laufwerke finden".
*
****************************************************************/

void dial_laufwe(void)
{
	register int i;
	register ICON *ic;
	char *name;
	CICONBLK *c;
	int dev;
	long drvs;
	int is_trash,is_prnt;


	/* existierende Laufwerke ermitteln */
	/* -------------------------------- */

	drvs = Drvmap();

	/* davon die schon angemeldeten abziehen */
	/* Papierkorb und Drucker ermitteln	 */
	/* ------------------------------------- */

	is_trash = is_prnt = FALSE;
	for	(ic = icon,i=0; i < n_deskicons; i++,ic++)
		{
		if	(ic->icontyp == ITYP_DRUCKR)
			is_prnt = TRUE;
		else
		if	(ic->icontyp == ITYP_PAPIER)
			is_trash = TRUE;
		else
		if	(ic->icontyp == ITYP_DISK)
			{
			dev = drive_from_letter(ic->isdisk);
			drvs &= ~(1L << dev);	/* entspr. Bit lîschen */
			}
		}

	/* noch fehlende Icons anmelden */
	/* ---------------------------- */

	for	(i = 0; i < 32; i++,drvs >>= 1)	/* Laufwerke 'A'..'Z' */
		{
		if	(drvs & 1L)	/* existiert, nicht angemeldet */
			{
			int letter = i >= 26 ? i - 26 + '1' : i + 'A';
			c = diskname_to_iconblk(letter, &name);
			make_icon(ITYP_DISK, c, letter, name, NULL, FALSE,-1,0);
			}
		}

	if	(!is_trash)
		make_icon(ITYP_PAPIER, std_tra_icon,
					0, NULL, NULL, FALSE,
					-1,0);

	if	(!is_prnt && status.show_prticon)
		make_icon(ITYP_DRUCKR, std_prt_icon,
					0, NULL, NULL, FALSE,
					-1,0);
}


/****************************************************************
*
* Die Aktion "Anwendung anmelden".
* Es wird das externe Programm aufgerufen, das folgende
* Kommandos kennt:
*
*	-aa	appath		; Applikation anmelden
*	-ad	appath dat	; angemeldete Datei modifizieren
*
*	-ia	appath		; Icon fÅr Programm anmelden
*	-id	apname dat	; Icon fÅr Datei anmelden
*					; <app> ist ggf. "<>"
*	-io	opath		; Icon fÅr Ordner/Disk anmelden
*	-is	key[4]		; Icon fÅr "special object" anmelden
*
****************************************************************/

void dial_anwndg(void)
{
	char *arg1,*arg2,*arg3;
	char path[256+2];
	int obj,typ,config;
	APPLICATION *a;
	WINDOW *w;


	if	(1 != icsel(&w, &obj))
		return;
	if	(obj_typ(w, obj, path, NULL, &typ, &config, &a))
		return;	/* nur Datei zulassen */

	arg1 = "-a?";
	arg2 = arg3 = NULL;

	switch(typ)
		{
	 case '_X':	arg1[2] = 'a';
	 			if	(a)				/* angemeldete APP */
	 				arg2 = a->apname;
	 			else	arg2 = path;		/* neue APP */
	 			break;
	  case 'TX':	if	(!a)
	  				return;	/* ??? */
	  			arg1[2] = 'd';
	  			arg2 = a->apname;		/* ang. Datei */
				arg3 = get_name(path);
	  			break;
	  default:	return;	/* ??? */
	  			
		}

	starte_dienstpgm("APPLICAT.APP", FALSE, FALSE,
						arg1, arg2, arg3 );
}


/****************************************************************
*
* Die Aktion "Icon zuweisen".
* Es wird das externe Programm aufgerufen, das folgende
* Kommandos kennt:
*
*	-aa	appath		; Applikation anmelden
*	-ad	appath dat	; angemeldete Datei modifizieren
*
*	-ia	appath		; Icon fÅr Programm anmelden
*	-id	apname dat	; Icon fÅr Datei anmelden
*					; <app> ist ggf. "<>"
*	-io	opath		; Icon fÅr Ordner/Disk anmelden
*	-is	key[4]		; Icon fÅr "special object" anmelden
*
****************************************************************/

void dial_assign_icon(void)
{
	char *arg1,*arg2,*arg3;
	char path[256+2];
	int obj,typ,config;
	APPLICATION *a;
	PATHNAME *p;
	DATAFILE *d;
	WINDOW *w;


	arg2 = arg3 = NULL;
	if	(1 == icsel(&w, &obj))
		{
		obj_typ(w, obj, path, NULL, &typ, &config, &a);

		arg1 = "-i?";

		switch(typ)
			{
		 case 'DO':
		 case '_O':	arg1[2] = 'o';
		 			p = find_path(path, NULL);
		 			if	(p)
		 				arg2 = p->path;
		 			else	arg2 = path;
		 			break;
		 case '_X':	arg1[2] = 'a';
					if	(a)			/* angemeldete APP */
		 				arg2 = a->apname;
		 			else	arg2 = path;	/* neue APP */
		 			break;
		 case '_T':
		 case 'TX':	arg1[2] = 'd';
					if	(a)			/* angemeldete Datei */
		 				arg2 = a->apname;
		 			else	arg2 = "<>";	/* keine APP */
		 			d = find_datafile(path);
		 			if	(d)
		 				arg3 = d->daname;
		  			else	arg3 = get_name(path);
		  			break;
		 
		 case 'AT':	arg2 = "ALIS";
		  			goto spec;

		 case 'BX':	arg2 = "BTCH";
		  			goto spec;

		 case 'D_':	arg2 = "PRNT";
		 			goto spec;

		 case 'P_':	arg2 = "TRSH";
		 			spec:
		 			arg1[2] = 's';
		 			break;

		 default:	return;	/* ??? */
			}
		}

	starte_dienstpgm("APPLICAT.APP", FALSE, FALSE,
					arg1, arg2, arg3);
}


/****************************************************************
*
* Der Dialog "Einstellungen Ñndern".
*
****************************************************************/

static int specpgms[] = {EIN_CMD, EIN_SHOW, EIN_PRNT, EIN_EDIT,
					EIN_KACH};

static MENUPROGRAM *newkach;

static int chk_einste(OBJECT *tree, int exitbutton)
{
	int kats[] = {EIN_GRP1, EIN_GRP2, EIN_GRP3, EIN_GRP4, EIN_GRP5};
	TEDINFO *ted;
	register int kat,off;
	MENUPROGRAM *pgm;
	EVNTDATA ev;


	for	(kat = 0; kat < 5; kat++)
		{
		if	(exitbutton == specpgms[kat])
			{
			if	(kat < 4)
				{
				pgm = menuprograms+kat;
				off = new_program(pgm, NULL, TRUE);
				}
			else	{
				pgm = newkach;
				off = new_program(pgm, "*.img", FALSE);
				}
			if	(!off)
				{
				ted = tree[exitbutton].ob_spec.tedinfo;
				abbrev_path(ted->te_ptext, pgm->path,
					ted->te_tmplen-1 );
				draw:
				subobj_draw(tree, exitbutton, -1, NULL);
				}
			return(FALSE);
			}
		}

	if	(exitbutton == EIN_COL0)
		{
		exitbutton = EIN_COL;
		tree[exitbutton].ob_spec.obspec.interiorcol--;
		draw_wait:
		graf_mkstate(&ev.x, &ev.y, &ev.bstate, &ev.kstate);
		if	(ev.bstate & 1)	/* Maustaste noch gedrÅckt */
			evnt_timer(100L);		/* 100 ms warten */
		goto draw;
		}
	if	(exitbutton == EIN_COL1)
		{
		exitbutton = EIN_COL;
		tree[exitbutton].ob_spec.obspec.interiorcol++;
		goto draw_wait;
		}
	if	(exitbutton == EIN_PAT0)
		{
		exitbutton = EIN_PAT;
		tree[exitbutton].ob_spec.obspec.fillpattern--;
		goto draw_wait;
		}
	if	(exitbutton == EIN_PAT1)
		{
		exitbutton = EIN_PAT;
		tree[exitbutton].ob_spec.obspec.fillpattern++;
		goto draw_wait;
		}
	if	(exitbutton == EIN_DSH0)
		{
		off = -1;
		goto hcnt;
		}
	if	(exitbutton == EIN_DSH1)
		{
		off = 1;
		hcnt:
		exitbutton = EIN_DSH;
		cnt:
		tree[exitbutton].ob_spec.obspec.character += off;
		if	(tree[exitbutton].ob_spec.obspec.character < '0')
			tree[exitbutton].ob_spec.obspec.character = '0';
		if	(tree[exitbutton].ob_spec.obspec.character > '9')
			tree[exitbutton].ob_spec.obspec.character = '9';
		goto draw_wait;
		}
	if	(exitbutton == EIN_DSV0)
		{
		off = -1;
		goto vcnt;
		}
	if	(exitbutton == EIN_DSV1)
		{
		off = 1;
		vcnt:
		exitbutton = EIN_DSV;
		goto cnt;
		}
	if	(exitbutton == EIN_RAS0)
		{
		off = -1;
		goto ras;
		}
	if	(exitbutton == EIN_RAS1)
		{
		off = 1;
		ras:
		exitbutton = EIN_RAS;
		goto cnt;
		}

	if	(exitbutton == EIN_KAT)
		{
		kat = pop_kategorie.obnum - 1;
		if	(kat < 0 || kat > 4)
			return(FALSE);
		kat = kats[kat];
		if	(kat == curr_kat)
			return(FALSE);
		objs_hide(tree, curr_kat, 0);
		objs_unhide(tree, kat, 0);
		curr_kat = kat;
		objs_uneditable(tree, EIN_CMD, EIN_BAT, EIN_BTP,
					EIN_SHOW, EIN_PRNT, EIN_EDIT,
					EIN_KACH, 0);
		if	(kat == EIN_GRP3)
			{
			objs_editable(tree, EIN_BAT, EIN_BTP,
						0);
			}
		subobj_draw(tree, kat, -1, NULL);
		return(FALSE);
		}
	return(TRUE);
}


void dial_einste(void)
{
	int ret;
	int dummy;
	TEDINFO *ted;
	char txt[5][128];
	char *p;
	char newpat,newcol;
	char new_hdst,new_vdst;
	MENUPROGRAM _newkach;
	int	upd_w = FALSE;
	int	upd_0 = FALSE;
	int 	oldex;



	newkach = &_newkach;
	if	(!(*kachel_path))
		{
		newkach->path[0] = EOS;
		oldex = FALSE;
		}
	else	{
		strcpy(newkach->path, (*kachel_path)->path);
		oldex = TRUE;
		}

	for	(ret = 0; ret < 5; ret++)
		{
		ted = adr_einst[specpgms[ret]].ob_spec.tedinfo;
		ted->te_ptext = txt[ret];
		p = (ret < 4) ? menuprograms[ret].path : newkach->path;
		abbrev_path(ted->te_ptext, p, ted->te_tmplen-1 );
		}

	ob_sel_dsel(adr_einst, EINST_BL, status.cnfm_del);
	ob_sel_dsel(adr_einst, EINST_BK, status.cnfm_copy);

	ob_sel_dsel(adr_einst, EINST_KU, status.mode_ovwr == OVERWRITE);
	ob_sel_dsel(adr_einst, EINST_KA, status.mode_ovwr == BACKUP);
	ob_sel_dsel(adr_einst, EINST_KB, status.mode_ovwr == CONFIRM);
	ob_sel_dsel(adr_einst, EINST_KF, status.check_free);
	ob_sel_dsel(adr_einst, EIN_CPRS, status.copy_resident);
	ob_sel_dsel(adr_einst, EIN_KOBO, status.copy_use_kobold);


	ob_sel_dsel(adr_einst, EINST_RS, status.resident);
	ob_sel_dsel(adr_einst, EINST_DN, status.dnam_init);
	ob_sel_dsel(adr_einst, EINS_ERD, status.save_on_exit);
	ob_sel_dsel(adr_einst, EINS_DCLICK, status.rtbutt_dclick);

	ob_sel_dsel(adr_einst, EIN_PP, status.use_pp);
	ob_sel_dsel(adr_einst, EINST_VE, status.show_all);
	ob_sel_dsel(adr_einst, EIN_8PL3, status.show_8p3);
	ob_sel_dsel(adr_einst, EINS_DRK, status.show_prticon);

	adr_einst[EIN_DSH].ob_spec.obspec.character =
		status.h_icon_dist + '0';
	adr_einst[EIN_DSV].ob_spec.obspec.character =
		status.v_icon_dist + '0';
	adr_einst[EIN_RAS].ob_spec.obspec.character =
		status.desk_raster + '0';

	adr_einst[EIN_COL].ob_spec.obspec.interiorcol = *desk_col;
	adr_einst[EIN_PAT].ob_spec.obspec.fillpattern = *desk_patt;

	ret = do_exdialog(adr_einst, chk_einste, NULL);

	if	(ret == EINST_LD)
		{
		char	path[256+2];
		char	fname[64+2];	/* ggf. lange Namen! */
		int ret;

		strcpy(fname, inf_name+3);
		strcpy(path, inf_name);
		if	(!fsel_exinput(path, fname, &ret,
						Rgetstring(STR_READ_INF)))
		return;		/* Fehler */
		if	(!ret)
			return;	/* Abbruch */
		reload_status(drive_from_letter(path[0]));
		return;
		}

	if	(ret == EIN_OK)		/* OK */
		{

		new_hdst = adr_einst[EIN_DSH].ob_spec.obspec.character - '0';
		new_vdst = adr_einst[EIN_DSV].ob_spec.obspec.character - '0';
		if	((status.h_icon_dist != new_hdst) ||
			 (status.v_icon_dist != new_vdst))
			{
			status.h_icon_dist = new_hdst;
			status.v_icon_dist = new_vdst;
			if	(status.showtyp == M_ABILDR)
				upd_w = TRUE;
			}
		if	(status.show_8p3 != selected(adr_einst, EIN_8PL3) &&
			(status.showtyp == M_ATEXT))
			upd_w = TRUE;

		status.desk_raster = adr_einst[EIN_RAS].ob_spec.obspec.character - '0';
		newcol = adr_einst[EIN_COL].ob_spec.obspec.interiorcol;
		newpat = adr_einst[EIN_PAT].ob_spec.obspec.fillpattern;


		if	(oldex && strcmp(_newkach.path, (*kachel_path)->path) ||
			 !oldex && _newkach.path[0])
			{
			if	(oldex)				/* alte freigeben */
				{
				Mfree(*kachel_path);
				*kachel_path = NULL;
				}
			if	(_newkach.path[0])		/* neue allozieren */
				{
				*kachel_path = Malloc(strlen(_newkach.path)+1);
				strcpy((*kachel_path)->path, newkach->path);
				}
			set_desktop();
			upd_0 = TRUE;
			}

		if	((newcol != *desk_col) || (newpat != *desk_patt))
			{
			*desk_col = newcol;
			*desk_patt = newpat;
			upd_0 = TRUE;
			}

		if	(upd_0)
			{
			set_desktop();
			upd_wind(fenster[0]);
			}

		status.cnfm_del  = selected(adr_einst, EINST_BL);
		status.cnfm_copy = selected(adr_einst, EINST_BK);
		status.copy_resident = selected(adr_einst, EIN_CPRS);
		status.copy_use_kobold = selected(adr_einst, EIN_KOBO);

		if		(selected(adr_einst, EINST_KB))
				status.mode_ovwr = CONFIRM;
		else if	(selected(adr_einst, EINST_KA))
				status.mode_ovwr = BACKUP;
		else		status.mode_ovwr = OVERWRITE;

		status.check_free	= selected(adr_einst, EINST_KF);
		status.resident	= selected(adr_einst, EINST_RS);
		status.use_pp		= selected(adr_einst, EIN_PP);
		status.show_all	= selected(adr_einst, EINST_VE);
		status.show_8p3	= selected(adr_einst, EIN_8PL3);
		status.dnam_init	= selected(adr_einst, EINST_DN);
		status.save_on_exit	= selected(adr_einst, EINS_ERD);
		status.rtbutt_dclick= selected(adr_einst, EINS_DCLICK);
		status.show_prticon = selected(adr_einst, EINS_DRK);

		fslx_set_flags(status.show_8p3, &dummy);

		if	(upd_w)
			upd_show();
/*
		wind_update(END_UPDATE);
		shutdown(ndrvr, txtheight);
		wind_update(BEG_UPDATE);
*/
		}
}


/****************************************************************
*
* Der Dialog "Parameter eingeben".
*
****************************************************************/

int dial_ttppar(char *pgm, char *par)
{
	register char *ziel1,*ziel2;


	ziel1 = (adr_ttppar+TTPPAR_T)->ob_spec.free_string;
	strcpy(ziel1, get_name(pgm));

	ziel1 = ((adr_ttppar+TTPPAR_1)->ob_spec.tedinfo)->te_ptext;
	ziel2 = ((adr_ttppar+TTPPAR_2)->ob_spec.tedinfo)->te_ptext;
	if	(*par)
		{
		strncpy(ziel1, par, TTPLEN);
		if	(strlen(par) >= TTPLEN)
			{
			ziel1[TTPLEN] = EOS;
			strcpy(ziel2, par + TTPLEN);
			}
		}

	if 	(TTPPA_OK != do_dialog(adr_ttppar))
		return(0);

	strcpy(par, ziel1);
	strcat(par, ziel2);
	return(1);
}


/****************************************************************
*
* Der Dialog "Zeichensatz auswÑhlen".
*
****************************************************************/

/* Definitionen fÅr <font_flags> bei fnts_create() */

#define	FNTS_BTMP	1													/* Bitmapfonts anzeigen */
#define	FNTS_OUTL	2													/* Vektorfonts anzeigen */
#define	FNTS_MONO	4													/* Ñquidistante Fonts anzeigen */
#define	FNTS_PROP	8													/* proportionale Fonts anzeigen */

/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define	FNTS_3D		1		/* 3D-Design benutzen */

/* Definitionen fÅr <button_flags> bei fnts_open() */
#define	FNTS_SNAME	0x01		/* Checkbox fÅr die Namen selektieren */
#define	FNTS_SSTYLE	0x02		/* Checkbox fÅr die Stile selektieren */
#define	FNTS_SSIZE	0x04		/* Checkbox fÅr die Hîhe selektieren */
#define	FNTS_SRATIO	0x08		/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */

#define	FNTS_CHNAME	0x0100	/* Checkbox fÅr die Namen anzeigen */
#define	FNTS_CHSTYLE	0x0200	/* Checkbox fÅr die Stile anzeigen */
#define	FNTS_CHSIZE	0x0400	/* Checkbox fÅr die Hîhe anzeigen */
#define	FNTS_CHRATIO	0x0800	/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define	FNTS_RATIO	0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define	FNTS_BSET		0x2000	/* Button "setzen" anwÑhlbar */
#define	FNTS_BMARK	0x4000	/* Button "markieren" anwÑhlbar */

/* Definitionen fÅr <button> bei fnts_evnt() */

#define	FNTS_CANCEL	1		/* "Abbruch" wurde angewÑhlt */
#define	FNTS_OK		2		/* "OK" wurde gedrÅckt */
#define	FNTS_SET		3		/* "setzen" wurde angewÑhlt */
#define	FNTS_MARK		4		/* "markieren" wurde betÑtigt */
#define	FNTS_OPT		5		/* der applikationseigene Button wurde ausgewÑhlt */


#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )
#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE )

void dial_fontsel( void )
{
	int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
	int	handle;
	register int i;
	void	*fnt_dialog;
	int button,check_boxes;
	long id,pt,ratio;
	int mono,dummy;
			

	for( i = 1; i < 10 ; i++ )											/* work_in initialisieren */
		work_in[i] = 1;
	work_in[10] = 2;		/* Rasterkoordinaten benutzen */
	handle = aes_handle;
	v_opnvwk( work_in, &handle, work_out );

	id = status.fontID;
	pt = (((long) status.fontH)<<16L);
	ratio = (1L<<16L);
	fnt_dialog = fnts_create( handle, 0, FONT_FLAGS, FNTS_3D,
				  "Was Shumway Your favourite Gordon?", 0L );
	if	(!fnt_dialog )
		return;
	button = fnts_do( fnt_dialog, BUTTON_FLAGS, id, pt, ratio,
			&check_boxes, &id, &pt, &ratio );
	if	(button == FNTS_OK)
		{
/*
		char s[100];
		Cconws("\x1b" "Hid=");
		ltoa(id, s, 16);
		Cconws(s);
		Cconws("        pt=");
		ltoa(pt, s, 16);
		Cconws(s);
		Cconws("        ratio=");
		ltoa(ratio, s, 16);
		Cconws(s);
		Cconws("        ");
		Cnecin();
*/
		status.fontID = (int) id;
		status.fontH = (int) (pt >> 16L);
		if	(!fnts_get_info(fnt_dialog, id, &mono, &dummy ))
			status.font_is_prop = TRUE;
		else	status.font_is_prop = !mono;
		set_char_dim();
		upd_is();
		}
	fnts_delete( fnt_dialog, handle );
	v_clsvwk(handle);
}


/****************************************************************
*
* Der Dialog "Auflîsung wechseln".
*
****************************************************************/

void dial_chgres( void )
{
	shutdown(0,0);
}

