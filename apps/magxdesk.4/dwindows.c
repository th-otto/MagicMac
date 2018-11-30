/*********************************************************************
*
* Dieses Modul enthÑlt die Bearbeitung aller Fensteroperationen
*
*********************************************************************/

#include <vdi.h>
#include <tos.h>
#include <toserror.h>
#include <mgx_dos.h>
#include <string.h>
#include <stdlib.h>
#include "pattern.h"
#include "k.h"
/* #include <stdio.h> */
#include <sys/stat.h>

static char *str_free;
static char *str_full;

static char dirty[ANZFENSTER+1];

static void MY_keyed( WINDOW *w, int kstate, int key );
static void MY_message( WINDOW *w, int kstate, int message[16]);
static void MY_topped( WINDOW *w );
static void MY_closed(WINDOW *w, int kstate);
static void MY_fulled( WINDOW *w );
static void MY_sized(WINDOW *w, GRECT *g);
static void MY_moved(WINDOW *w, GRECT *g);
static void MY_hslid( WINDOW *w, int newpos );
static void MY_vslid( WINDOW *w, int newpos );
static void MY_arrowed(WINDOW *w, int arrow);
static void MY_iconified( WINDOW *w, GRECT *g, int mode);
static void MY_uniconified( WINDOW *w, GRECT *g, int unhide );


/****************************************************************
*
* Initialisiert nationale Zeichenketten
*
****************************************************************/

void	windows_init( void )
{
	str_free = Rgetstring(STR_FREE);
	str_full = Rgetstring(STR_FULL);
}


/****************************************************************
*
* Stellt sicher, daû ein Fenster sichtbar ist
*
****************************************************************/

void make_g_fit_screen( GRECT *g )
{
	if	(g->g_x < -30000)		/* totale Sicherheit */
		g->g_x = 0;
	if	(g->g_y < -30000)
		g->g_y = 0;

	if	(g->g_w > desk_g.g_w+32)
		g->g_w = desk_g.g_w+32;
	if	(g->g_h > desk_g.g_h+32)
		g->g_h = desk_g.g_h+32;

	if	(g->g_x + g->g_w < 40)
		g->g_x = 40 - g->g_w;
	if	(g->g_y + g->g_h < 40)
		g->g_y = 40 - g->g_h;

	if	(g->g_x > desk_g.g_w-8)
		g->g_x = desk_g.g_w-8;
	if	(g->g_y > desk_g.g_h-8)
		g->g_y = desk_g.g_h-8;
}


/****************************************************************
*
* Merkt den Selectstatus in Bit 1 von MYDTA.flags.
*
****************************************************************/

static void save_select_status( WINDOW *w )
{
	register int i,tail;
	register OBJECT *tree = w->pobj;


	if	((i = (tree -> ob_head)) <= 0)
		return;
	tail = (tree++ -> ob_tail);
	for	(; i <= tail; i++,tree++)
		{
		if	(!(SELECTED&(tree->ob_state)) || (HIDETREE&(tree->ob_flags)))
			w->pmydta[i - 1]->flags &= ~2;
		else	w->pmydta[i - 1]->flags |=  2;
		}
}


/****************************************************************
*
* Gibt das oberste Fenster zurÅck.
* RÅckgabe ist NULL, wenn das Fenster nicht mir gehîrt.
*
****************************************************************/

WINDOW *top_window( void )
{
	int whdl;

	if	(!wind_get_int(0, WF_TOP, &whdl))
		return(NULL);
	if	(whdl < 0)
		return(NULL);
	return(whdl2window(whdl));
}


/****************************************************************
*
* Zeichnet das Fenster neu.
*
****************************************************************/

void upd_wind(WINDOW *w)
{
	int    msg[8];

	/* Der Redraw wird nicht direkt ausgefÅhrt, sondern schickt */
	/* eine Nachricht an die Applikation, um Kollisionen mit    */
	/* von AES erzeugten Redraws zu vermeiden                   */
	/* -------------------------------------------------------- */

	msg[0] = WM_REDRAW;
	msg[1] = ap_id;
	msg[2] = 0;
	msg[3] = w->handle;
	msg[4] = w->in.g_x;
	msg[5] = w->in.g_y;
	msg[6] = w->in.g_w;
	msg[7] = w->in.g_h;
	appl_write(ap_id, 16, msg);
}


/****************************************************************
*
* Sortiert die Dateien fÅr Fenster <wnr>.
* Auûerdem werden die "nicht zur Maske passenden" Dateien nach
* hinten sortiert und
*
*	<w->shownum>
*	<w->max_fname>
*	<w->max_wicnobj>
*	<w->max_is_alias>
*
* initialisiert.
*
****************************************************************/

static int cmp_mydtas(MYDTA **ff1, MYDTA **ff2)
{
	register int  r;
	register long l;
	register char *n1,*n2;
	register MYDTA *f1,*f2;


	f1 = *ff1;
	f2 = *ff2;
	if	(((f1->flags)&1) != ((f2->flags)&1))		/* Match- Flag */
		return(((f2->flags)&1 - ((f1->flags)&1)));
	if	(status.sorttyp == M_SNICHT)
		return(f1->number - f2->number);
	if	(f1->attrib & FA_SUBDIR)
		{
		if	(!(f2->attrib & FA_SUBDIR))
			return(-1);
		else goto name;
		}
	if	(f2->attrib & FA_SUBDIR)
		return(1);
	switch(status.sorttyp)
		{
		case M_SNAME:	name:
					return(stricmp(f1->filename, f2->filename));
		case M_SDATUM: l = ((unsigned long) f2->date) - ((unsigned long) f1->date);
					if	(l == 0)
						l = ((unsigned long) f2->time) - ((unsigned long) f1->time);
					goto groe;
		case M_SGROES: l = f2->filesize - f1->filesize;
					groe:
					if	(l == 0)
						goto name;
					else return((l > 0) ? 1 : -1);
		case M_STYP:	n1 = strrchr(f1->filename, '.');
					n2 = strrchr(f2->filename, '.');
					if	(n1 == NULL && n2 == NULL)
						goto name;
					if	(n1 == NULL)
						return(-1);
					if	(n2 == NULL)
						return(1);
					r = stricmp(n1,n2);
					if	(r == 0)
						goto name;
					return(r);
		}
	return(0);
}


static void sort_mydtas( WINDOW *w )
{
	extern void 	shelsort(void *base, size_t count, size_t size, int (*compar)());
	MYDTA **files = w->pmydta;
	int   anzahl  = w->realnum;
	register int i,match,len,olen;
	register MYDTA **dtas,*mdta;


	w->shownum = 0;
	w->max_wicnobj = 0;
	w->max_fname = MIN_FNAMLEN;
	for	(dtas = files, i = 0; i < anzahl; i++)
		{
		mdta = *dtas++;
		match = ((mdta->attrib & FA_SUBDIR) ||
			 (pattern_match(w->maske, mdta->filename)));
		if	(match)
			{
			len = (int) strlen(mdta->filename);
			if	(len > w->max_fname)
				w->max_fname = len;
			if	(mdta->is_alias && len == w->max_fname)
				w->max_is_alias = TRUE;
			olen = 6*len;
			if	(mdta->is_alias)
				olen += 6;
			if	(mdta->ciconblk.monoblk.ib_wicon > olen)
				olen = mdta->ciconblk.monoblk.ib_wicon;
			if	(olen > w->max_wicnobj)
				w->max_wicnobj = olen;

			mdta->flags |=  1;
			w->shownum++;
			}
		else mdta->flags &= ~1;
		}



	/* Beim Sortieren ggf. den ersten Eintrag ".." vorn lassen */

	dtas = w->pmydta;
	i = w->realnum;
	if	((i) && !strcmp(dtas[0]->filename, ".."))
		{
		dtas++;
		i--;
		}
	shelsort(dtas, (size_t) i, sizeof(MYDTA *), cmp_mydtas);
}


/****************************************************************
*
* Setzt die Titelzeile des Fensters
*
****************************************************************/

static void set_title( WINDOW *mywindow )
{
	register char *s,*p,*m;


	s = mywindow->title;
	p = mywindow->path;
	m = mywindow->maske;
	*s++ = ' ';
	if	(strlen(p) + strlen(m) > 124)
		strcpy(s, Rgetstring(STR_PATH_2_DEEP));
	else	{
		strcpy(s, p);
		strcat(s, m);
		}
	s += strlen(s);
	*s++ = ' ';
	*s 	= EOS;
}


/****************************************************************
*
* Setzt die Infozeile des Fensters mit Nummer <wnr>.
*
****************************************************************/

static void set_info( WINDOW *mywindow )
{
	register char *s;
	register unsigned long size 	= 0L;
		    unsigned long ssize	= 0L;
	register int num;
		    int snum			= 0;
	register int i;
	MYDTA **file;
	MYDTA *sfile				= NULL;
	OBJECT *o;


	if	(mywindow->flags & WFLAG_ICONIFIED)
		return;
	s		= mywindow->info;
	num		= mywindow->shownum;
	o		= mywindow->pobj + 1;
	file		= mywindow->pmydta;
	for	(i = num; i > 0; i--,file++,o++)
		{
		size += ((*file) -> filesize);
		if	((o -> ob_state) & SELECTED)
			{
			snum++;
			ssize += ((*file) -> filesize);
			sfile = *file;
			}
		}

	/* Selektionsmaske, z.B. "[A*]" */

	*s++ = ' ';
	if	(mywindow->sel_maske[0])
		{
		*s++ = '[';
		strcpy(s, mywindow->sel_maske);
		s += strlen(s);
		*s++ = ']';
		*s++ = ' ';
		}

	if	(snum)			/* selektierte Objekte */
		{
		size = ssize;
		num  = snum;
		}
	if	(snum == 0 || snum > 1)
		{
		char *objs;


		if	(snum == 0 && mywindow->too_much)
			{
			strcpy(s, Rgetstring(STR_MORE_THAN));
			objs = Rgetstring(STR_OBJECTS);
			}
		else {
			print_ul(size, s);
			strcat(s, Rgetstring(STR_BYTES_IN));
			objs = Rgetstring((num == 1) ? STR_OBJECT : STR_OBJCTS_DATIV);
			}
		s += strlen(s);
		itoa(num, s, 10);
		if	(snum)
			strcat(s, Rgetstring(STR_SELECTED));
		strcat(s, objs);

		if	((!snum) && !(mywindow->sel_maske[0]))
			{
			int lwc;
			/* long percent; */
			unsigned long bytes;
			DISKINFO di;
			DISKINFO *d;


			lwc  = mywindow->real_drive;
			if	(lwc == 'U' - 'A')
				{
				d = &di;
				d->b_free = 0L;
				Dsetdrv(lwc);
				Dsetpath(mywindow->path);
				Dfree(d, 0);
				}
			else	d = dinfo+lwc;
		
		/*	bytes = d->b_free * d->b_secsiz * d->b_clsiz;	*/

			s += strlen(s);
			*s++ = '|';		/* Special fÅr MagiC 6*/
			*s++ = '|';
			if	((!d->b_free) || (!d->b_total))
				strcpy(s, str_full);
			else	{
				bytes = d->b_free * d->b_secsiz * d->b_clsiz;
				print_big_bytes(bytes, s);
				s += strlen(s);
				strcpy(s, str_free);

/*
			if	(d->b_free == d->b_total)
				strcpy(s, "leer ");
			else	{
				percent = ((d->b_total - d->b_free) * 100L)/d->b_total;
				print_ul(percent, s);
				s += strlen(s);
				strcpy(s, "% belegt ");
				}
*/
				}
			}

		}
	else {
		if	(0 == ((sfile -> attrib) & FA_SUBDIR))
			{
			if	(size < 100000L)
				*s++ = ' ';
			if	(size < 10000)
				*s++ = ' ';
			if	(size < 1000)
				{
				*s++ = ' ';
				*s++ = ' ';
				}
			if	(size < 100)
				*s++ = ' ';
			if	(size < 10)
				*s++ = ' ';
			print_ul(size, s);
			strcat(s, Rgetstring(STR_BYTES));
			s += strlen(s);
			}
		date_to_str(s, sfile -> date);
		strcat(s, " | ");
		s += strlen(s);
		time_to_str(s, sfile -> time);
		i = suffixtyp(sfile->filename);
		if	(i == PGMT_NOEXE)
			i = (NULL != dfile_to_app(sfile->filename));
		else i = TRUE;
		if	(i || ((sfile -> attrib) & (FA_RDONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE)))
			strcat(s, " | ");
		if	((sfile -> attrib) & FA_RDONLY)
			strcat(s, "R");
		if	((sfile -> attrib) & FA_SYSTEM)
			strcat(s, "S");
		if	((sfile -> attrib) & FA_HIDDEN)
			strcat(s, "H");
		if	((sfile -> attrib) & FA_ARCHIVE)
			strcat(s, "A");
		if	(i)
			strcat(s, "E");		/* executable */
		}
	s += strlen(s) + 1;
	*s = EOS;
}


/****************************************************************
*
* Zeigt freien Speicher fÅr Disk in Fenster (wnr) an.
*
****************************************************************/

void show_free( WINDOW *mywindow)
{
	char s[50];
	int lwc;
	DISKINFO di;
	DISKINFO *d;
	long percent;
	char *t;
	ULONG bytes[2];	/* 64 Bit */
	extern void ullmul( ULONG m1, ULONG m2, ULONG erg[2]);


	if	(mywindow->flags & WFLAG_ICONIFIED)
		return;
	lwc  = mywindow->real_drive;
	if	(lwc == 'U' - 'A')
		{
		d = &di;
		d->b_free = 0L;
		Dsetdrv(lwc);
		Dsetpath(mywindow->path);
		Dfree(d, 0);
		}
	else	d = dinfo+lwc;

	/* freie Bytes auf Laufwerk: */
	ullmul( d->b_free, d->b_secsiz * d->b_clsiz, bytes );
	print_ull(bytes, s);

	strcat(s, Rgetstring(STR_BYTES));
	strcat(s, "       ( ");
	t = s+strlen(s);
	percent = ((d->b_free) * 100L)/d->b_total;
	print_ul(percent, t);
	strcat(t, "% )");
	Rxform_alert(1, ALRT_FREE_AT_DRV, lwc + 'A', s);
}


/****************************************************************
*
* Zeigt den Disknamen <dname> auf allen Icons auf dem Desktop an,
* die die Disk <lw> darstellen.
*
****************************************************************/

void set_dname(int lw, char *dname)
{
	register int i;
	int w,index,xoffs;
	register char **p;
	char old_text[65];
	OBJECT *o;
	CICONBLK *c;
	GRECT g;


	lw += 'A';
	for	(i = 0; i < n_deskicons; i++)
		if	(icon[i].isdisk == lw)
			{
			p = &(icon[i].data.monoblk.ib_ptext);
			strcpy(old_text, *p);
			/* 1. Fall: Ein Name wurde Åbergeben: einsetzen */
			if	(*dname)
				{
				strcpy(icon[i].text, dname);
				*p = icon[i].text;
				}
			/* 2. Fall: Leerstring Åbergeben: Default einsetzen */
			else {
				*p = ((adr_icons + icon[i].icontyp) -> ob_spec.iconblk) -> ib_ptext;
				}
			if	(strcmp(old_text, *p))
				{
				index = i+1;
				o = fenster[0]->pobj+index;
				g = *((GRECT *) &(o->ob_x));
				g.g_x += fenster[0]->pobj->ob_x;
				g.g_y += fenster[0]->pobj->ob_y;
				if	(o->ob_type == G_CICON)
					{
					w = (int) strlen(*p);
					if	(w < MIN_FNAMLEN)
						w = MIN_FNAMLEN;
					w *= 6;
					c = o->ob_spec.ciconblk;
					if	(o->ob_width != w)
						index = 0;	/* root zeichnen */
					if	(o->ob_width < w)
						g.g_w = w;	/* max bilden */
					c->monoblk.ib_wtext = o->ob_width = w;
					xoffs = c->monoblk.ib_xicon;	/* alte Pos. */
					c->monoblk.ib_xicon = (w-c->monoblk.ib_wicon)>>1;
					xoffs -= c->monoblk.ib_xicon;	/* alt-neu */
					o->ob_x += xoffs;
					if	(xoffs < 0)
						{
						g.g_x += xoffs;
						g.g_w -= xoffs;
						}
					}
				wind_update(BEG_UPDATE);
				objc_wdraw(fenster[0]->pobj, index, 1, &g, 0 );
				wind_update(END_UPDATE);
				}
			}
}


/****************************************************************
*
* Legt Icontypen und Exec-Flags fÅr ein eingelesenes Fenster
* fest
*
****************************************************************/

static void set_wind_icons( WINDOW *mywindow )
{
	char path[128];
	char *epath;
	MYDTA **z,*ziele;
	int anzahl;
	int typ;


	strcpy(path, mywindow->path);
	epath = path+strlen(path);	/* hier Dateiname ansetzen */
	mywindow->max_hicon = 0;
	anzahl = mywindow->realnum;
	for	(z = mywindow->pmydta;
		 z < mywindow->pmydta + anzahl;
		 z++
		)
		{
		ziele = *z;
		ziele -> flags = 0;					/* Datei */

		if	((ziele -> attrib) & FA_SUBDIR)
			{
			strcpy(epath, ziele->filename);
			strcat(epath, "\\");	/* Ordner -> abs. Pfad */
			if	(!strcmp(ziele->filename, ".."))
				{
				ziele->icontyp = ITYP_PARENT;
				ziele->ciconblk = *parentname_to_iconblk(path, epath);
				}
			else	{
				ziele->icontyp = ITYP_ORDNER;
				ziele->ciconblk = *foldername_to_iconblk(path, epath);
				}
			}
		else {

			typ = suffixtyp(ziele -> filename);

			/* Sonstige Dateien bekommen das ihnen zugewiesene	*/
			/* Icon 										*/
			/* --------------------------------------------------- */

			if	(((ziele->mode) & S_IFMT) == S_IFCHR)
				{
				ziele->icontyp = ITYP_DEVICE;
				ziele->ciconblk = *devicename_to_iconblk(ziele -> filename);
				}
			else
			if	(ziele->is_alias == 2)
				{
				ziele->icontyp = ITYP_ALIAS;
				ziele->ciconblk = *alias_to_iconblk(ziele -> filename);
				}
			else
			if	(typ < 0)
				{
				ziele->icontyp = ITYP_DATEI;
				ziele->ciconblk = *datname_to_iconblk(ziele -> filename);
				}

			/* Batchdateien bekommen das Icon I_BTCHDA */
			/* --------------------------------------- */

			else	if	(typ & PGMT_BATCH)
				{
				ziele->icontyp = ITYP_BTCHDA;
				ziele->ciconblk = *batchname_to_iconblk(ziele -> filename);
				}

			/* Programmdateien bekommen das ihnen	*/
			/* zugeordnete Icon 				*/
			/* ------------------------------------ */

			else {
				ziele->flags = 4;				/* Programm */
				ziele->icontyp = ITYP_PROGRA;
				ziele->ciconblk = *pgmname_to_iconblk(ziele->filename);
				}

			}

		if	((ziele->ciconblk).monoblk.ib_hicon > mywindow->max_hicon)
			mywindow->max_hicon = (ziele->ciconblk).monoblk.ib_hicon;

		}
}


/****************************************************************
*
* Liest das Verzeichnis fÅr Fenster <wnr> ein und gibt ggf. einen
*  DOS- Fehlercode zurÅck.
* Das Vezeichnis wird in die MYDTAs des Fensters eingelesen, dabei
*  werden in <icontyp> bereits die Icontypen festgelegt.
* Es werden alle Dateien eingelesen, ohne Maske zu berÅcksichtigen.
* Tritt irgendwo ein Fehler EPTHNF auf, wird das Verzeichnis auf
*  "Root" gesetzt und der Vorgang wiederholt. Trat ein anderer Fehler
*  auf oder war die Root schon eingeschaltet, wird der Fehlercode
*  zurÅckgegeben.
* Wenn <free_flag> != 0 ist, wird der freie Speicher berechnet.
*
****************************************************************/

static long read_wind( WINDOW *w, int free_flag)
{
	char	path[128];
	static char *rpath = "X:\\";
	char dname[65];
	char *epath;
	register int anzahl,drv,real_drv;
	int maxnamelen;
	int maxmem_per_name;
	long err;
	XATTR xa;
	long err_xr;
	long	dirhandle;
	char *ziele,*limit;
	MYDTA *mdta,**p_d;
	int was_long_names = FALSE;


	/* Speicherblock allozieren */
	/* ------------------------ */

	if	(w->memblk)
		{
		Mfree(w->memblk);
		w->memblk = NULL;
		}
	w->memblksize = ((long) Malloc(-1L)) - MINFREEBLK;
	if	(w->memblksize > FIRSTMAXMEMBLK)
		w->memblksize = FIRSTMAXMEMBLK;
	if	(w->memblksize < 8192L)
		return(ENSMEM);			/* nix zu wollen */
#pragma warn -pia
	if	(!(w->memblk = Malloc(w->memblksize)))
#pragma warn .pia
		return(ENSMEM);

	/* Initialisierungen */
	/* ----------------- */

	if	(free_flag)
		w->real_drive = -1;			/* kein altes Laufwerk */
	w->sel_maske[0] = EOS;			/* Keine Selektionsmaske */
	Mgraf_mouse(HOURGLASS);
	drv = w->path[0] - 'A';			/* Nominal-Laufwerk */


	/* Bei Fehler auf Root umschalten */
	/* ------------------------------ */

	err = E_OK;
	do	{
		if	(err)
			{
			w->yscroll = 0;
			if	(err != EPTHNF || w->path[3] == EOS)
				{
				Mfree(w->memblk);
				w->memblk = NULL;
				Mgraf_mouse(ARROW);
				return(err);
				}
			else {
				w->path[3] = EOS;
				free_flag = TRUE;
				set_title(w);
				wind_set_str(w->handle, WF_NAME, w->title);
				}
			}
		/* Diskname einlesen (von der Root)		*/
		/* Dabei wird ggf. der Diskwechsel erkannt	*/
		/* ----------------------------------------- */

		rpath[0] = drv+'A';
		dname[0] = EOS;
		err = Dreadlabel(rpath, dname, 65);
		set_dname(drv, dname);
		if	(err != EFILNF && err != ERANGE && err != E_OK)
			continue;
	
		/* Pfad ÅberprÅfen, ggf. auf Root setzen. */
		/* Dabei tatsÑchliches Laufwerk ermitteln */
		/* -------------------------------------- */

		err = get_real_drive(w->path);
		if	(err < 0L)	/* Fehler bei Dsetpath */
			continue;
		real_drv = (int) err;

		if	((w->real_drive != real_drv) ||
			 (real_drv == 'U'-'A'))
			free_flag = TRUE;

		/* Freien Plattenplatz ermitteln */
		/* ----------------------------- */

		if	(free_flag)
			{
/*			long slsize;	*/

			if	((real_drv == 'U'-'A') ||
				 dinfo[real_drv].b_clsiz == 0L)
				/* Laufwerk U: oder ungÅltig */
				if	(0L > (err = Dfree(&dinfo[real_drv], 0)))
					continue;
/*
			if	(dinfo[real_drv].b_free == dinfo[drv].b_total)
				slsize = -1L;
			else slsize = ((dinfo[real_drv].b_total-dinfo[real_drv].b_free) * 1000L) /
							dinfo[real_drv].b_total;
			wind_set_int(w->handle, WF_HSLSIZE, (int) slsize);
*/
			w->real_drive = real_drv;
			}

		/* Hier Verzeichnis schon îffnen, um	*/
		/* Automounter auszulîsen			*/
		/* ------------------------------------ */

		strcpy(path, w->path);
		err = Dopendir(path, 0);
		if	(err < E_OK)
			continue;
		dirhandle = err;

		/* DateinamenlÑnge usw. ermitteln */
		/* ------------------------------ */

		err = Dpathconf(path, DP_NAMEMAX);
		if	(err > 0L)
			{
			maxnamelen = (int) err;
			w->dos_mode = (Dpathconf(path, DP_TRUNC) == DP_DOSTRUNC);
			}
		else	{
			w->dos_mode = TRUE;
			maxnamelen = 12;
			}
		maxmem_per_name = (int) (sizeof(MYDTA) + maxnamelen + 1 +
				sizeof(MYDTA *) + sizeof(OBJECT) +
				sizeof(CICONBLK));
		if	(maxmem_per_name & 1)
			maxmem_per_name++;		/* auf WORD runden */

		/* Verzeichnis einlesen */
		/* -------------------- */

		epath = path+strlen(path);	/* hier Dateiname ansetzen */
		ziele = w->memblk;
		limit = ziele + w->memblksize - sizeof(OBJECT)
			- maxmem_per_name;	/* Objekt #0 berÅcksichtigen! */

		anzahl = 0;

		err = err_xr = E_OK;
		while((err == E_OK) && (err_xr == E_OK))
			{

			/* Hier ggf. mehr Speicher allozieren */
			/* ---------------------------------- */

			if	(ziele >= limit)
				{
				long newsize = w->memblksize+NEXTMEMBLK;

				if	((w->memblksize >= LASTMAXMEMBLK) ||
					 (w->memblksize < FIRSTMAXMEMBLK))
					break;

				/* Versuche Blockvergrîûerung */
				/* -------------------------- */

				if	(Mshrink(w->memblk,
							w->memblksize+NEXTMEMBLK))
					{
					char *newblk;

					newblk = Malloc(newsize);
					if	(!newblk)
						break;	/* Fehler */
					memcpy(newblk, w->memblk, ziele - w->memblk);
					limit = newblk + (limit - w->memblk);
					ziele = newblk + (ziele - w->memblk);
					Mfree(w->memblk);
					w->memblk = newblk;
					}
				limit += NEXTMEMBLK;
				w->memblksize = newsize;
				}

			/* Einen Eintrag einlesen */
			/* ---------------------- */

			mdta = (MYDTA *) ziele;
			if	((!anzahl) && (path[3]) && (status.use_pp))
				{

				/* ".." simulieren */
				/* --------------- */

				strcpy(mdta->filename, "..");
				xa.st_mtime = 0;
				xa.st_size = 0L;
				xa.st_attr = FA_SUBDIR;
				xa.st_mode = S_IFDIR;
				err = err_xr = E_OK;
				}
			else	{
				err = Dxreaddir(maxnamelen+4+1, dirhandle,
							mdta->filename-4,
							&xa, &err_xr);

				/* Åberlange Dateinamen... */
	
				if	(err == ERANGE)
					{
					err = err_xr = E_OK;
					was_long_names = TRUE;
					continue;
					}
	
				/* Fehler oder "." oder ".." */
	
				if	(err || err_xr ||
						(mdta->filename[0] == '.') &&
						((!mdta->filename[1]) ||
						 ((mdta->filename[1] == '.') &&
						  (!mdta->filename[2])
						 )
						)
					)
					continue;
				}

			/* versteckte Dateien... */

			if	((!status.show_all) &&
				 (xa.st_attr & (FA_HIDDEN | FA_SYSTEM))
				)
				continue;		/* verst. Dateien! */

			/* Symlink behandeln... */

			if	((xa.st_mode & S_IFMT) == S_IFLNK)
				{
				XATTR xa2;

				mdta->is_alias = 1;
				strcpy(epath, mdta->filename);
				err = Fxattr(0, path, &xa2);
				if	(!err)
					xa = xa2;
				else	mdta->is_alias = 2; /* nicht aufgelîst!! */
				err = E_OK;
				}
			else	mdta->is_alias = 0;

			/* alles klar, abspeichern... */

			mdta->number = anzahl;
			mdta->time = xa.st_mtim.u.d.time;	/* Modif.zeit */
			mdta->date = xa.st_mtim.u.d.date;
			mdta->filesize = xa.st_size;
			mdta->attrib = xa.st_attr;
			mdta->mode = xa.st_mode;
			anzahl++;
			ziele += sizeof(MYDTA)+strlen(mdta->filename)+1;
			if	(((long) ziele) & 1)
				ziele++;		/* WORD align! */
			limit -= maxmem_per_name;
			}

		Dclosedir(dirhandle);

		if	(was_long_names)
			{
			Rform_alert(1, ALRT_CONT_LNAMES);
			}

		if	(err == E_OK)
			w->too_much = TRUE;
		else {
			w->too_much = FALSE;
			if	(err == EFILNF || err == ENMFIL)
				err = E_OK;
			}
		}
	while(err != E_OK);

	w->realnum = anzahl;

	/* Zeiger aufbauen */
	/* --------------- */

	w->pmydta = (MYDTA **) ziele;
	w->pobj = (OBJECT *) ( ziele + anzahl * sizeof(MYDTA *) );
	limit = (char *) (w->pobj + anzahl + 1);
	w->memblksize = limit - w->memblk;
	Mshrink(w->memblk, w->memblksize);
	for	(p_d = w->pmydta,ziele = w->memblk;
			anzahl > 0; anzahl--)
		{
		mdta = (MYDTA *) ziele;
		*p_d++ = mdta;
		ziele += sizeof(MYDTA)+strlen(mdta->filename)+1;
		if	(((long) ziele) & 1)
			ziele++;		/* WORD align! */
		}

	/* Icontypen und Exec- Flag festlegen */
	/* ---------------------------------- */

	set_wind_icons(w);

	Mgraf_mouse(ARROW);
	return(E_OK);
}


/****************************************************************
*
* Die Innenmaûe des Fensters werden berechnet.
*
****************************************************************/

static void calc_in(WINDOW *w)
{
	register int gescrollte_pixel;


	if	(w->flags & WFLAG_ICONIFIED)
		{
		wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
		gescrollte_pixel = 0;
		}
	else	{
		gescrollte_pixel = w->yscroll*(w->showh+w->ydist);

		wind_calc_grect(WC_WORK, w->kind, &w->out, &w->in);
		}
	(w->pobj)->ob_x = w->in.g_x;
	(w->pobj)->ob_y = w->in.g_y - gescrollte_pixel;
	(w->pobj)->ob_width  = w->in.g_w;
	(w->pobj)->ob_height = w->in.g_h + gescrollte_pixel;
}


/****************************************************************
*
* Die Anzahl der Spalten des Fensters werden berechnet.
* Die Anzahl der sichtbaren Zeilen des Fensters werden berechnet.
*
****************************************************************/

static void calc_collin(WINDOW *w)
{
	int x,y;
	int c;


	x = w->in.g_w - w->xoffs + w->xdist;
	y = w->in.g_h - w->yoffs + w->ydist;
	if	(status.is_1col && status.showtyp == M_ATEXT)
		c = 1;
	else {
		c = x / (w->showw + w->xdist);
		if	(c < 1)
			c = 1;
		}
	w->cols = c;
	w->wlins = y / (w->showh + w->ydist);
	w->lins = (w->shownum + w->cols - 1) / w->cols;
}


/****************************************************************
*
* Die die Dateien darstellenden Objekte werden festgelegt.
* Aus den DTAs werden alle <shownum> sichtbaren Dateien als
*  Objekte zusammengestellt.
* Die Icontypen (falls nicht als Text dargestellt wird), sind
*  bereits in den MYDTAs festgelegt.
* Ist dsel_flg FALSE, werden die "ob_flags" aus den MYDTAs geholt
*  (Bit 2), um den Selectstatus zu erhalten, der vorher mittels
*  "save_select_status" gesichert wurde.
* Eingabe: (global) showtyp,is_groesse,
*				is_datum,is_zeit
* Ausgabe: (global) showw,showh
*
****************************************************************/

static void calc_obj_look(WINDOW *w, int dsel_flag)
{
	int out[8];
	int anzahl;
	OBJECT *o;
	MYDTA **p_d,*d;
	CICONBLK *c;
	int	len,tlen;
	register int i;
	register char *s;



	anzahl	= w->shownum;
	o 		= w->pobj;
	p_d 		= w->pmydta;

	if	(status.showtyp == M_ATEXT)
		{
		w->xoffs = 2*gl_hwchar - 1;
		w->yoffs = 1;
		w->xdist = 2*gl_hwchar;
		w->ydist = 1;
		w->showh = char_h;
		if	(status.font_is_prop)
			{
			vqt_extent(vdi_handle, "8888888", out);
			w->xtab_sizelen = out[2] - out[0];
			vqt_extent(vdi_handle, "88-88-88", out);
			w->xtab_datelen = out[2] - out[0];
			vqt_extent(vdi_handle, "88:88", out);
			w->xtab_timelen = out[2] - out[0];
			/* Breite der Spalte "Dateiname" fÅr Vektorfonts */
			w->xtab_namelen = 20;
			w->xtab_typelen = 8;
			for	(i = 1; i <= anzahl; i++,p_d++)
				{
				d = *p_d;
	#pragma warn -pia
				if	(status.show_8p3 && w->dos_mode &&
					(s = strchr(d->filename, '.')))
	#pragma warn .pia
					{
					*s = EOS;
					vqt_extent(vdi_handle, d->filename, out);
					len = out[2] - out[0];
					*s++ = '.';
					vqt_extent(vdi_handle, s, out);
					tlen = out[2] - out[0];
					if	(w->xtab_typelen < tlen)
						w->xtab_typelen = tlen;
					}
				else	{
					vqt_extent(vdi_handle, d->filename, out);
					len = out[2] - out[0];
					}
	
				if	(w->xtab_namelen < len)
					w->xtab_namelen = len;
				}
			p_d = w->pmydta;
			w->showw = folder_w + 12 + w->xtab_namelen;
			if	(w->dos_mode && status.show_8p3)
				w->showw += spaltenabstand + w->xtab_typelen;
			if	(status.is_groesse)
				w->showw += spaltenabstand + w->xtab_sizelen;
			if	(status.is_datum)
				w->showw += spaltenabstand + w->xtab_datelen;
			if	(status.is_zeit)
				w->showw += spaltenabstand + w->xtab_timelen;
			}
		else {
			len = (w->dos_mode && status.show_8p3)
					? 12 : w->max_fname;
			w->showw = char_w * (4 + len + 8*status.is_groesse +
							 10*status.is_datum +
							 7*status.is_zeit
							);
			}
		}
	else {
		w->xscroll = w->max_xscroll = 0;
		w->xoffs = 3;
		w->yoffs = 1;
		w->xdist = status.h_icon_dist;
		w->ydist = status.v_icon_dist;
		w->showh = w->max_hicon + 8;
		w->showw = w->max_wicnobj;
#if 0
		w->showw = w->max_fname * 6;
		if	(w->max_is_alias)
			w->showw += 6;		/* fÅr Kursivstellung */
#endif
		}

	/* Objekt der weiûen Hintergrundbox */

	o -> ob_next = -1;
	o -> ob_type = G_BOX;
	o -> ob_state = NORMAL;
	o -> ob_spec.index = (long) (WHITE);
	if	(anzahl > 0)
		{
		o -> ob_flags = NONE;
		o -> ob_head = 1;
		o -> ob_tail = anzahl;
		}
	else {
		o -> ob_flags = LASTOB;
		o -> ob_head = o -> ob_tail = -1;
		}

	/* Objekte der Dateien */

	for	(i = 1; i <= anzahl; i++,c++,p_d++)
		{
		d = *p_d;
		o++;
		o -> ob_next = (i < anzahl) ? (i+1) : (0);
		o -> ob_head = o -> ob_tail = -1;
		o -> ob_flags = (i < anzahl) ? NONE : LASTOB;

		/* Spezialbehandlung fÅr parent */

		if	(d->icontyp == ITYP_PARENT)
			o->ob_flags |= EXIT;

		if	(status.showtyp == M_ABILDR)
			{
			c = &(d->ciconblk);
			c->monoblk.ib_ptext = d->filename;
			c->monoblk.ib_wtext = w->showw;
			c->monoblk.ib_xicon = (w->showw-c->monoblk.ib_wicon)>>1;
			o->ob_type   = G_CICON;
			o->ob_spec.ciconblk = c;
			o->ob_state = ((!dsel_flag) && (d -> flags & 2))
					 	? SELECTED+WHITEBAK : NORMAL+WHITEBAK;
			if	(d->is_alias)
				o->ob_state |= (SHADOWED+0x8000+0x400);	/* kursiv */
			}
		else {
			o -> ob_type = G_USERDEF;
			o -> ob_spec.userblk = &userblk;
			o -> ob_state = ((!dsel_flag) && (d -> flags & 2))
					 	? SELECTED : NORMAL;
			}
		o -> ob_width = w->showw;
		o -> ob_height = w->showh;
		}
	set_info(w);
}


/****************************************************************
*
* Organisiert das Fenster neu, d.h. legt Position der Objekte fest.
* gibt TRUE zurÅck, falls sich fenster.cols oder fenster.shift
* geÑndert haben.
*
****************************************************************/

static int re_arrange(WINDOW *w)
{
	register int i,j;
	int x,y,cols;
	int oldcols;
	int oldshift;
	int old_xscroll;
	int anzahl;
	OBJECT *o;
	long vsize,vpos;


	oldcols 		= w->cols;
	oldshift 		= w->yscroll;
	old_xscroll	= w->xscroll;
	anzahl 		= w->shownum;
	o 			= w->pobj;

	calc_in(w);			/* Innenmaûe berechnen */
	calc_collin(w);		/* Zeilen/Spalten berechnen */
	cols = w->cols;

	/* Einstellungen fÅr vertikalen Scrollbalken */
	/* ----------------------------------------- */

	w->maxshift = w->lins - w->wlins;
	if	(w->maxshift < 0)
		w->maxshift = 0;

	if	(w->yscroll < 0)
		w->yscroll = 0;
	if	(w->yscroll > w->maxshift)
		w->yscroll = w->maxshift;

	if	(w->lins > 0)
		vsize = (1000L * w->wlins) / w->lins;
	else vsize = 1000L;
	if	(vsize > 1000L)
		vsize = 1000L;
	wind_set_int(w->handle, WF_VSLSIZE, (int) vsize);

	if	(w->maxshift > 0)
		vpos = (1000L * w->yscroll) / w->maxshift;
	else vpos = 1L;
	if	(vpos > 1000L)
		vpos = 1000L;
	if	(vpos < 1)
		vpos = 1;
	wind_set_int(w->handle, WF_VSLIDE, (int) vpos);

	/* Einstellungen fÅr horizontalen Scrollbalken */
	/* ------------------------------------------- */

	w->max_xscroll = (cols <= 1) ? w->showw + w->xoffs - w->in.g_w : 0; /* ??? */
	if	(w->max_xscroll < 0)
		w->max_xscroll = 0;

	if	(w->xscroll < 0)
		w->xscroll = 0;
	if	(w->xscroll > w->max_xscroll)
		w->xscroll = w->max_xscroll;

	if	(w->max_xscroll)
		vsize = (1000L * w->in.g_w) / (w->showw + w->xoffs);
	else vsize = 1000L;
	if	(vsize > 1000L)
		vsize = 1000L;
	wind_set_int(w->handle, WF_HSLSIZE, (int) vsize);

	if	(w->max_xscroll)
		vpos = (1000L * w->xscroll) / w->max_xscroll;
	else vpos = 1L;
	if	(vpos > 1000L)
		vpos = 1000L;
	if	(vpos < 1)
		vpos = 1;
	wind_set_int(w->handle, WF_HSLIDE, (int) vpos);

	/* Position und Hîhe ggf. korrigieren (von calc_in schon gesetzt) */
	/* -------------------------------------------------------------- */

	o -> ob_y 	= w->in.g_y - w->yscroll*(w->showh+w->ydist);
	o -> ob_height = w->in.g_h + w->yscroll*(w->showh+w->ydist);
	for	(i = 0, y = w->yoffs, x = w->xoffs, j = anzahl; j > 0; i++,j--)
		{
		o++;
		if	(i >= cols)
			{
			i = 0;
			x = w->xoffs;
			y += w->showh + w->ydist;
			}
		o -> ob_x = x - w->xscroll;
		o -> ob_y = y;
		if	((o -> ob_type == G_ICON) || (o -> ob_type == G_CICON))
			o -> ob_y += w->max_hicon - o->ob_spec.iconblk->ib_hicon;
		x += w->showw + w->xdist;
		}
	if	(anzahl < oldcols)
		oldcols = anzahl;
	if	(anzahl < cols)
		cols = anzahl;
	return(oldcols != cols || oldshift != w->yscroll ||
			old_xscroll != w->xscroll);
}


/****************************************************************
*
* Ein Fenster <wnr> wird erstellt.
*
****************************************************************/

WINDOW *create_wnd( int wnr, char *path, char *mask,
			int yscroll, int flags, LONG *errcode)
{
	WINDOW *w;
	int iconify_flags;


	w = Malloc(sizeof(WINDOW));
	if	(w)
		{
		w->kind = (status.showtyp == M_ATEXT) ? FENSTERTYP_T : FENSTERTYP_B;
		iconify_flags = flags & (WFLAG_ICONIFIED+WFLAG_ALLICONIFIED);
		if	(iconify_flags == WFLAG_ALLICONIFIED)
			w->handle = -1;
		else	w->handle = wind_create_grect(w->kind, &desk_g);
		if	((iconify_flags != WFLAG_ALLICONIFIED) && (w->handle < 0))
			{
			Mfree(w);
			w = NULL;
			*errcode = ENOWND;
			}
		else	{
			if	(w->handle >= 0)
				wind_set_int(w->handle, WF_BEVENT,
						BEVENT_WORK+BEVENT_INFO );
			w->yscroll = yscroll;
			w->xscroll = 0;
			w->flags = flags;
			strcpy(w->maske, (*mask) ? mask : "*");
			strcpy(w->path, path);
			w->key = MY_keyed;
			w->message = MY_message;
			w->closed = MY_closed;
			w->topped = MY_topped;
			w->fulled = MY_fulled;
			w->sized = MY_sized;
			w->moved = MY_moved;
			w->hslid = MY_hslid;
			w->vslid = MY_vslid;
			w->arrowed = MY_arrowed;
			w->iconified = MY_iconified;
			w->uniconified = MY_uniconified;
			w->out = fensterg[wnr];
			w->wnr = wnr;
			w->memblk = NULL;
			w->pmydta = NULL;
			w->pobj = NULL;
			fenster[wnr] = w;
			*errcode = E_OK;
			}
		}
	else	*errcode = ENSMEM;
	return(w);
}


/****************************************************************
*
* Ein Fenster <w> wird entfernt. Es muû geschlossen sein.
*
****************************************************************/

void delete_wnd( WINDOW *w )
{
	if	(w->memblk)
		Mfree(w->memblk);
	if	(w->handle > 0)
		wind_delete(w->handle);
	fenster[w->wnr] = NULL;		/* austragen */
	Mfree(w);					/* freigeben */
}


/****************************************************************
*
* Ein Fenster <wnr> wird geîffnet. Pfad und Maske sind festgelegt.
*
* Wenn  <fast> auf TRUE ist, sind auch der Shiftstatus bzw. das
* Flag WFLAG_ICONIFIED festgelegt, dann wird auch keine
* Growbox gezeichnet.
*
****************************************************************/

long opn_wnd(WINDOW *w, int fast)
{
	register int i;
	register long ret;


	Dsetdrv(w->path[0] - 'A');
	i = drv_to_icn(w->path[0]);

	/* Verzeichnis einlesen */

	if	(w->flags & WFLAG_ICONIFIED)
		{
		GRECT oldg;

		oldg = w->out;
		MY_iconified( w, NULL,
				(w->flags & WFLAG_ALLICONIFIED) ? ICONIFIED_MODE_ALL : ICONIFIED_MODE_NORMAL);
		wind_set_grect(w->handle, WF_UNICONIFYXYWH, &oldg);
		}
	else	{
		dinfo[w->path[0] - 'A'].b_clsiz = 0L;	  /* ungÅltig machen */
		ret =  read_wind(w, TRUE);
		if	(ret)
			{		/* Fehler */
			delete_wnd(w);
			dirty_win = TRUE;	/* Fensterliste geÑndert */
			return(ret);
			}
	
		sort_mydtas(w);
		calc_obj_look(w, TRUE);
		re_arrange(w);
	
		if	(!fast && (i >= 0))
			graf_growbox_grect((GRECT *) &((fenster[0]->pobj+i+1)->ob_x),
					   &w->out);
		wind_set_str(w->handle, WF_INFO, w->info);
		}

	set_title(w);		/* Titel ist " <pfad><maske> "	*/
	wind_set_str(w->handle, WF_NAME, w->title);
	wind_open_grect(w->handle, &w->out);
	dirty_win = TRUE;	/* Fensterliste geÑndert */
	return(E_OK);
}


/****************************************************************
*
* Das Fenster wird nach oben gebracht.
* Jedoch nur dann, wenn es nicht das Wurzelfenster (0) ist.
*
****************************************************************/

static void MY_topped( WINDOW *w )
{
	if	(w->handle > 0)
		{
		wind_set_int(w->handle, WF_TOP, 0);
		Dsetdrv(w->path[0] - 'A');
		}
}


/****************************************************************
*
* Verzeichnis eine Ebene zurÅck
*
* RÅckgabe 0, wenn mîglich, sonst 1
*
****************************************************************/

static int parent_path(WINDOW *w)
{
	char *lastb;


	if	((w->path[3] != EOS) && !(w->flags & WFLAG_ICONIFIED))
		{
		if	(w->memblk)
			{
			Mfree(w->memblk);
			w->memblk = NULL;
			}
		w->path[strlen(w->path) - 1] = EOS;
		lastb = strrchr(w->path, '\\');
		*(lastb + 1) = EOS;
		upd_path(w, FALSE);
		return(0);
		}
	return(1);
}


/****************************************************************
*
* Im Fenster ist auf die Schlieûbox geklickt worden.
*
****************************************************************/

static void MY_closed(WINDOW *w, int kstate)
{
	register int i;
	char *lastb;



	/* Wenn die ALT- Taste gedrÅckt war, wird ein neues Fenster */
	/* erîffnet, das den Parent des Fensters enthÑlt			*/
	/* -------------------------------------------------------- */

	if	(kstate & K_ALT)
		{
		char	path[128];

		if	(w->path[3] == EOS)			/* schon Root */
			return;
		strcpy(path, w->path);			/* Pfad erst kopieren */
		path[strlen(path) - 1] = EOS;		/* letzten '\' lîschen */
		lastb = strrchr(path, '\\');		/* letzten '\' ermitteln */
		*(lastb + 1) = EOS;				/* dahinter absÑgen */
		opn_newwnd(path);
		return;
		}

	/* Wird kein ".." angezeigt, wird ggf. zurÅckgegangen */
	/* -------------------------------------------------- */

	if	((!status.use_pp) && !(kstate & K_CTRL))
		{
		if	(!parent_path(w))
			return;
		}
		
	/* Sonst: schlieûen					   */
	/* --------------------------------------- */

	if	(w->memblk)
		{
		Mfree(w->memblk);
		w->memblk = NULL;
		}

	for	(i = 0; i < n_deskicons; i++)
		{
		if	(icon[i].isdisk == w->path[0])
			break;
		}

	if	(w->flags & WFLAG_ICONIFIED)
		{
		wind_get_grect(w->handle, WF_UNICONIFY, &w->out);
		}
	wind_close(w->handle);
	fensterg[w->wnr] = w->out;	/* letzte Fensterpos. merken */
	delete_wnd(w);		/* alles abrÑumen */
	dirty_win = TRUE;		/* Fensterliste geÑndert */

	if	(i < n_deskicons)
		graf_shrinkbox_grect((GRECT *) (&(fenster[0]->pobj+i+1)->ob_x),
				 	 &w->out);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist auf den Iconifier
* geklickt worden.
*
* mode == ICONIFIED_MODE_NORMAL		normale Aktion
* mode == ICONIFIED_MODE_HIDE			anderes hat ALLICONIFY
* mode == ICONIFIED_MODE_ALL			ich habe ALLICONIFY
*
****************************************************************/

static void MY_iconified( WINDOW *w, GRECT *g, int mode)
{
	register OBJECT *o;
	char *text;
	char	path[128];
	int *c;
	static GRECT g2 = {-1,-1,-1,-1};
	MYDTA *mdta;
	CICONBLK *cic;


	/* 1. Fall: Ein anderes Fenster wurde mit ALLICONIFY	*/
	/* ikonifiziert. Dieses Fenster schlieûen und mit		*/
	/* dem Flag WFLAG_ALLICONIFIED kennzeichnen			*/
	/* --------------------------------------------------- */

	if	(mode == ICONIFIED_MODE_HIDE)
		{
		if	(w->flags & WFLAG_ICONIFIED)		/* schon ikonifiziert */
			wind_get_grect(w->handle, WF_UNICONIFY, &w->out);

		Mfree(w->memblk);
		w->memblk = NULL;
		wind_close(w->handle);
		wind_delete(w->handle);
		w->handle = -1;
		w->flags = WFLAG_ALLICONIFIED;
		dirty_win = TRUE;		/* Fensterliste geÑndert */
		return;
		}

	if	(!g)
		g = &g2;

	/* 2. Fall: Fenster wurde ikonifiziert		*/
	/* ----------------------------------------- */

	if	(wind_set_grect(w->handle, WF_ICONIFY, g))
		{
		Mfree(w->memblk);
		w->memblksize = sizeof(MYDTA) + 128 +
						sizeof(MYDTA *) + 2 * sizeof(OBJECT);
		w->memblk = Malloc( w->memblksize );
		if	(!w->memblk)
			{
			err_alert(ENSMEM);
			wind_close(w->handle);
			delete_wnd(w);
			dirty_win = TRUE;		/* Fensterliste geÑndert */
			return;
			}
			
		w->pmydta = (MYDTA **) (w->memblk + sizeof(MYDTA) + 128);
		w->pmydta[0] = mdta = (MYDTA *) (w->memblk);
		cic = &(mdta->ciconblk);
		w->pobj = (OBJECT *) (w->pmydta + 1);
		w->realnum = 1;

		w->flags |= WFLAG_ICONIFIED;
		if	(mode == ICONIFIED_MODE_ALL)
			w->flags |= WFLAG_ALLICONIFIED;

		strcpy(mdta->filename, ".");
		mdta->number = 0;
		mdta->flags = 0;
		mdta->icontyp = ITYP_ORDNER;
		mdta->filesize = 0;


		if	(!w->path[3])				/* schon Root */
			text = w->path;
		else	{
			strcpy(path, w->path);		/* Pfad erst kopieren */
			path[strlen(path)-1] = EOS;	/* letzten '\' lîschen */
			text = strrchr(path, '\\') +1;
			}
		strcpy(w->info, text);

		w->out = *g;
		w->cols = 1;
		w->yscroll = w->maxshift = 0;
		w->shownum = 1;
		w->wlins = w->lins = 1;
		wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
		/* Objektbaum aufbauen */
		o = w->pobj;

		/* Objekt der weiûen Hintergrundbox */

		o -> ob_next = -1;
		o -> ob_type = G_BOX;
		o -> ob_state = NORMAL;
		o -> ob_spec.index = (long) (WHITE);
		o -> ob_flags = NONE;
		o -> ob_head = 1;
		o -> ob_tail = 1;
		o->ob_x = w->in.g_x;
		o->ob_y = w->in.g_y;
		o->ob_width  = w->in.g_w;
		o->ob_height = w->in.g_h;

		/* Objekt des Icons */

		if	(mode == ICONIFIED_MODE_ALL)
			{
			*cic = *(foldername_to_iconblk("#:\\", NULL));
			cic->monoblk.ib_ptext = "MAGXDESK";
			}
		else	{
			*cic = *(foldername_to_iconblk(w->path, NULL));
			cic->monoblk.ib_ptext = w->info;
			}

		c = &(cic->monoblk.ib_char);
		if	(*c & 0x00ff)
			{
			*c &= 0xff00;
			*c |= w->path[0];
			}
		o++;
		o -> ob_next = 0;
		o -> ob_head = o -> ob_tail = -1;
		o -> ob_type  = G_CICON;
		o -> ob_flags = LASTOB;
		o -> ob_state = NORMAL+WHITEBAK;
		o -> ob_spec.ciconblk = cic;
		o -> ob_width  = 72;
		o -> ob_height = (o -> ob_spec.iconblk->ib_hicon) + 8;
		o -> ob_x = (w->in.g_w - o->ob_width) >> 1;
		o -> ob_y = (w->in.g_h - o->ob_height) >> 1;
		}
}


/****************************************************************
*
* Das ikonifizierte Fenster mit Handle <whdl> wurde per
* Doppelklick wieder geîffnet.
* Die Daten werden neu eingelesen.
*
* unhide = TRUE:
*	Ein anderes Fenster, das mit ALLICONIFY ikonifziziert war,
*	wurde deikonifiziert. Unser Fenster wird geîffnet.
*
* unhide = FALSE:
*	Normales Un-Iconify
*
****************************************************************/

static void MY_uniconified( WINDOW *w, GRECT *g, int unhide)
{
	if	(unhide)
		{
		w->flags &= (~WFLAG_ALLICONIFIED);
		w->handle = wind_create_grect(w->kind, &desk_g);
		if	(w->handle > 0)
			opn_wnd(w, TRUE);
		else	{
			delete_wnd(w);
			err_alert(ENSMEM);
			}
		return;
		}

	if	(read_wind(w, TRUE))
		{
		w->closed(w,0);
		return;
		}
	sort_mydtas(w);
	calc_obj_look(w, TRUE);
/*	dirty_info_selmask(w);	*/
	w->sel_maske[0] = EOS;
	dirty[w->wnr] = TRUE;
/*	wind_set(w->handle, WF_INFO, w->info);	*/
	re_arrange(w);
	wind_set_grect(w->handle, WF_UNICONIFY, g);
	w->flags &= (~(WFLAG_ICONIFIED+WFLAG_ALLICONIFIED));
	w->out = *g;
	re_arrange(w);		/* Neuzeichnen automatisch! */
	dirty_win = TRUE;	/* Fensterliste geÑndert */
}


/****************************************************************
*
* Das Fenster mit Handle <wnr> wird sofort geschlossen.
*
****************************************************************/
#if 0
void close_immed( WINDOW *w)
{
	if	(w->path[0])
		{
		w->path[3] = EOS;		/* zurÅck auf Root */
		Dsetpath(w->path);		/* Standardpfad auf Root */
		w->closed(w, 0);		/* Fenster schlieûen */
		}
}
#endif

/****************************************************************
*
* Der horizontale Scrollbalken ist auf die Position
* <newshift> zu bringen und der Redraw zu bewerkstelligen.
*
****************************************************************/

static void hshift(WINDOW *w, int newshift)
{
	register int diff;		/* um soviele Spalten Scrollen */
	register int xcopy;		/* soviele x-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT g;
	register int whdl;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(newshift < 0)
		newshift = 0;
	else if	(newshift > w->max_xscroll)
			newshift = w->max_xscroll;

	if	(0 == (diff = newshift - w->xscroll))
		return;

	w->xscroll = newshift;
	re_arrange(w);

	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	if	(abs(diff) > w->in.g_w)
		{
		upd_wind(w);
		return;
		}

	/* Fenster Åber Rechteckliste scrollen */

	whdl = w->handle;
	Mgraf_mouse(M_OFF);
	wind_get_grect(whdl, WF_FIRSTXYWH, &g);
	do	{
		if	(rc_intersect(&desk_g, &g))
			{
			xcopy = g.g_w - abs(diff);		/* soviele Pixel blitten */
			if	(xcopy > 0)
				{
				pxy[1] = pxy[5] = g.g_y;
				pxy[3] = pxy[7] = g.g_y + g.g_h - 1;
				if	(diff > 0)
					{
					pxy[4] = g.g_x;
					pxy[0] = g.g_x + diff;
					}
				else {
					pxy[0] = g.g_x;
					pxy[4] = g.g_x - diff;
					}
				pxy[2] = pxy[0] + xcopy - 1;
				pxy[6] = pxy[4] + xcopy - 1;
				src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
				set_deflt_clip();
				vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
				/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
				g.g_w -= xcopy;
				if	(diff > 0)
					g.g_x += xcopy;
				}
			objc_draw_grect(w->pobj, 0, 1, &g);
			}
		wind_get_grect(whdl, WF_NEXTXYWH, &g);
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */

	Mgraf_mouse(M_ON);
}


/****************************************************************
*
* Der vertikale Scrollbalken ist auf die Position
* <newshift> zu bringen und der Redraw zu bewerkstelligen.
*
****************************************************************/

static void vshift(WINDOW *w, int newshift)
{
	register int diff;		/* um soviele Zeilen Scrollen */
	register int ycopy;		/* soviele y-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT g;
	register int whdl;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(newshift < 0)
		newshift = 0;
	else if	(newshift > w->maxshift)
			newshift = w->maxshift;

	if	(0 == (diff = newshift - w->yscroll))
		return;

	w->yscroll = newshift;
	re_arrange(w);

	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	if	(abs(diff) > w->wlins)
		{
		upd_wind(w);
		return;
		}

	/* Von Zeilen in Pixel umrechnen */
	/* diff > 0: Balken nach unten, Inhalt nach oben */

	diff *= (w->showh + w->ydist);

	/* Fenster Åber Rechteckliste scrollen */

	whdl = w->handle;
	Mgraf_mouse(M_OFF);
	wind_get_grect(whdl, WF_FIRSTXYWH, &g);
	do	{
		if	(rc_intersect(&desk_g, &g))
			{
			ycopy = g.g_h - abs(diff);		/* soviele Pixel blitten */
			if	(ycopy > 0)
				{
				pxy[0] = pxy[4] = g.g_x;
				pxy[2] = pxy[6] = g.g_x + g.g_w - 1;
				if	(diff > 0)
					{
					pxy[5] = g.g_y;
					pxy[1] = g.g_y + diff;
					}
				else {
					pxy[1] = g.g_y;
					pxy[5] = g.g_y - diff;
					}
				pxy[3] = pxy[1] + ycopy - 1;
				pxy[7] = pxy[5] + ycopy - 1;
				src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
				set_deflt_clip();
				vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
				/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
				g.g_h -= ycopy;
				if	(diff > 0)
					g.g_y += ycopy;
				}
			objc_draw_grect(w->pobj, 0, 1, &g);
			}
		wind_get_grect(whdl, WF_NEXTXYWH, &g);
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */

	Mgraf_mouse(M_ON);
}


/****************************************************************
*
* Im Fenster ist einer der Scrollpfeile
* angeklickt worden.
* zusÑtzlich: Code -1 => Scrollbalken ganz nach oben
*		    Code -2 => Scrollbalken ganz nach unten
*
****************************************************************/

static void MY_arrowed(WINDOW *w, int arrow)
{
	int	newwshift,newhshift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	newhshift = w->yscroll;
	newwshift = w->xscroll;
	switch(arrow)
		{
		case -1:			newhshift  = 0;
						break;
		case -2:			newhshift  = w->maxshift;
						break;
		case WA_UPPAGE:	newhshift -= w->wlins;
						break;
		case WA_DNPAGE:	newhshift += w->wlins;
						break;
		case WA_UPLINE:	newhshift--;
						break;
		case WA_DNLINE:	newhshift++;
						break;
		case WA_LFPAGE:	newwshift -= w->in.g_w;
						break;
		case WA_RTPAGE:	newwshift += w->in.g_w;
						break;
		case WA_LFLINE:	newwshift -= 8;
						break;
		case WA_RTLINE:	newwshift += 8;
						break;
/*
		default:			show_free(w);
						return;
*/
		}

	if	(newwshift != w->xscroll)
		hshift(w, newwshift);
	if	(newhshift != w->yscroll)
		vshift(w, newhshift);
}


/****************************************************************
*
* Im Fenster ist der horizontale Scrollbalken bewegt worden.
*
****************************************************************/

static void MY_hslid( WINDOW *w, int newpos )
{
	long newshift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	newshift = (newpos * (w->max_xscroll + 1L))/1000L;
	hshift(w, (int) newshift);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist der vertikale Scrollbalken
* bewegt worden.
*
****************************************************************/

static void MY_vslid( WINDOW *w, int newpos)
{
	long newshift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	newshift = (newpos * (w->maxshift + 1L))/1000L;
	vshift(w, (int) newshift);
}


/****************************************************************
*
* Das Fenster ist in seiner Grîûe verÑndert worden.
*
****************************************************************/

static void MY_sized(WINDOW *w, GRECT *g)
{
	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(wind_set_grect(w->handle, WF_CURRXYWH, g))
		{
		w->out = *g;
		if	(re_arrange(w))
			upd_wind(w);
		}
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> ist verschoben worden.
*
****************************************************************/

static void MY_moved( WINDOW *w, GRECT *g)
{
/*	g->g_x &= ~7;	*/
	if	(wind_set_grect(w->handle, WF_CURRXYWH, g))
		{
		w->out = *g;
		calc_in(w);
		}
}


/****************************************************************
*
* Ein Disk-Inhalt hat sich geÑndert.
* Zeichnet alle Fenster, die das Laufwerk <lw> darstellen, neu.
* Dabei sind die tatsÑchlichen Laufwerke zu beachten, d.h.
* Symlinks mÅssen berÅcksichtigt werden.
*
****************************************************************/

static void upd_disk(int lw, int free_flag)
{
	register int i;
	register WINDOW **pw,*w;


	dirty_drives[lw] = 0;		/* dirty- Flag lîschen */
	if	(free_flag)
		dinfo[lw].b_clsiz = 0L;	  /* ungÅltig machen */
	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((!w) ||
				(w->flags & WFLAG_ICONIFIED) ||
			 (w->real_drive != lw))
			continue;

		if	(read_wind(w, free_flag))
			{
			w->closed(w,0);
			break;
			}
		sort_mydtas(w);
		calc_obj_look(w, TRUE);
		wind_set_str(w->handle, WF_INFO, w->info);
		re_arrange(w);
		upd_wind(w);
		dirty_win = TRUE;	/* Fensterliste geÑndert */
		}
}


/****************************************************************
*
* Ein Medium ist ausgeworfen worden. Alle Fenster, die zu
* nicht gemounteten Laufwerken gehîren, werden geschlossen.
*
****************************************************************/

void auto_close_windows( void )
{
	register int i;
	register WINDOW **pw,*w;
	int data[2];
	long ret;


	data[0] = 0;		/* Unterfunktionsnummer #0 */

	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && (w->path[0]))
			{
			data[1] = w->real_drive;
			ret = Dcntl(KER_DRVSTAT, "U:\\", (long) data);
			if	((ret == EDRIVE) || (ret == 0L) ||
				 (ret == ELOCKED))
				{
				dirty_drives[w->real_drive] = 0;	/* dirty- Flag lîschen */
				dinfo[w->real_drive].b_clsiz = 0L;	/* ungÅltig machen */
				w->path[3] = EOS;		/* zurÅck auf Root */
				w->closed(w, 0);		/* Fenster schlieûen */
				dirty_win = TRUE;		/* Fensterliste geÑndert */
				}
			}
		}
}


/****************************************************************
*
* Die Icon-Zuweisung hat sich geÑndert
* (Anwendung anmelden/Icon zuweisen)
*
****************************************************************/

void upd_icons( void )
{
	register int i;
	register WINDOW **pw,*w;


	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	(!w)
			continue;
		set_wind_icons(w);
		if	(w->flags & WFLAG_ICONIFIED)
			continue;
		sort_mydtas(w);
		save_select_status( w );
		calc_obj_look(w, FALSE);
		re_arrange(w);
		upd_wind(w);
		}
}


/****************************************************************
*
* Mehrere Disketteninhalte haben sich geÑndert.
* Zeichnet alle Fenster, die in der globalen Liste <drives>
* enthalten sind, neu.
*
****************************************************************/

void upd_drives( void )
{
	register int i;

	for	(i = 0; i < ANZDRIVES; i++)
		if	(dirty_drives[i])
			upd_disk(i, dirty_drives[i] == TRUE);
}


/****************************************************************
*
* Ein Pfad hat sich geÑndert.
* Zeichne Fenster <wnr> neu.
* Wenn <free_flag> TRUE ist, hat sich auch das Laufwerk geÑndert.
*
****************************************************************/

void upd_path(WINDOW *w, int free_flag)
{
	w->yscroll = 0;
	set_title(w);
	wind_set_str(w->handle, WF_NAME, w->title);
	if	(read_wind(w, free_flag))
		{
		w->closed(w,0);
		return;
		}
	sort_mydtas(w);
	calc_obj_look(w, TRUE);
	dirty_info_selmask(w);
	re_arrange(w);
	upd_wind(w);
	dirty_win = TRUE;	/* Fensterliste geÑndert */
}


/****************************************************************
*
* Die Darstellungsart (Bilder/Text) hat sich geÑndert.
* Zeichnet alle Fenster neu.
*
****************************************************************/

void upd_show( void )
{
	register int i;
	register WINDOW **pw,*w;
	int kind;


	kind = (status.showtyp == M_ATEXT) ? FENSTERTYP_T : FENSTERTYP_B;
	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	(!w)
			continue;
		w->kind = kind;
		wind_set_int(w->handle, WF_KIND, kind);
		if	(!(w->flags & WFLAG_ICONIFIED))
			{
			save_select_status(w);
			calc_in(w);			/* Innenmaûe berechnen */
			calc_obj_look(w, FALSE);
			re_arrange(w);
			upd_wind(w);
			}
		}
}


/****************************************************************
*
* Die Textdarstellungsart (zeige auch ...) hat sich geÑndert.
* Zeichnet alle Fenster neu, wenn Textdarstellung eingestellt.
*
****************************************************************/

void upd_is( void )
{
	register int i;
	register WINDOW **pw,*w;

	if	(status.showtyp == M_ABILDR)
		return;
	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && !(w->flags & WFLAG_ICONIFIED))
			{
			save_select_status(w);
			calc_obj_look(w, FALSE);
			re_arrange(w);
			upd_wind(w);
			}
		}
}


/****************************************************************
*
* Der Sortiermodus hat sich geÑndert.
* Zeichnet alle Fenster neu.
*
****************************************************************/

void upd_sort( void )
{
	register int i;
	register WINDOW **pw,*w;

	for	(i = 1,pw=fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && !(w->flags & WFLAG_ICONIFIED))
			{
			save_select_status(w);
			sort_mydtas(w);
			calc_obj_look(w, FALSE);
			upd_wind(w);
			}
		}
}


/****************************************************************
*
* Die Maske fÅr Fenster <wnr> hat sich geÑndert.
* Zeichnet das Fenster neu.
*
****************************************************************/

void upd_mask( WINDOW *w )
{
	WINDOW *ow;
	int ob;

	if	(w->path[0])
		{

		if	(icsel(&ow, &ob) && (ow != w))
			dsel_all();
		set_title(w);
		if	(w->flags & WFLAG_ICONIFIED)
			{
			wind_set_str(w->handle, WF_NAME, w->title);
			wind_set_str(w->handle, WF_INFO, w->info);
			}
		else	{
			save_select_status(w);
			sort_mydtas(w);
			calc_obj_look(w, FALSE);
			re_arrange(w);
			wind_set_str(w->handle, WF_NAME, w->title);
			wind_set_str(w->handle, WF_INFO, w->info);
			upd_wind(w);
			}
		}
}


/****************************************************************
*
* Die Anzahl/Art der selektierten Dateien fÅr Fenster <wnr> hat
* sich geÑndert. Merkt nur die Flags.
*
****************************************************************/

static void dirty_info( WINDOW *w )
{
	if	(w->handle > 0 && w->path[0] && !(w->flags & WFLAG_ICONIFIED))
		dirty[w->wnr] = TRUE;
}


void dirty_info_selmask( WINDOW *w )
{
	if	(w->handle > 0 && w->path[0] && !(w->flags & WFLAG_ICONIFIED))
		{
		w->sel_maske[0] = EOS;
		dirty[w->wnr] = TRUE;
		}
}


/****************************************************************
*
* Die Selektionsmaske hat sich geÑndert. Dateien werden
* je nach Selektionsmaske selektiert bzw. deselektiert.
*
****************************************************************/

void upd_selmask( WINDOW *w )
{
	GRECT g = {32767,32767,-32767,-32767};	/* Update-Rechteck ORECT */
	register int i,fit,ofit;
	int		num		= w->shownum;
	MYDTA	**pfile	= w->pmydta;
	OBJECT	*o		= w->pobj + 1;
	int first_sel_line = -1;		/* erstes sel. Objekt */
	MYDTA *file;


	for	(i = 0; i < num; i++,o++)
		{
		file = *pfile++;

		/* paût die Maske ? */

		ofit = (((o -> ob_state) & SELECTED) != 0);
		fit  = pattern_match(w->sel_maske, file->filename);
		if	(ofit != fit)
			{		/* énderung */
			(o -> ob_state) ^= SELECTED;	/* toggeln */
			if	(o->ob_x < g.g_x)
				g.g_x = o->ob_x;
			if	(o->ob_y < g.g_y)
				g.g_y = o->ob_y;
			if	(o->ob_x + o->ob_width > g.g_w)
				g.g_w = o->ob_x + o->ob_width;
			if	(o->ob_y + o->ob_height > g.g_h)
				g.g_h = o->ob_y + o->ob_height;
			}
		if	(fit && (first_sel_line < 0))
			first_sel_line = i / w->cols;
		}
	g.g_w -= g.g_x;
	g.g_h -= g.g_y;

	/* ggf. Redraw: umschlieûendes Rechteck */

	if	(g.g_w && g.g_h)
		{
		g.g_x += w->pobj->ob_x;
		g.g_y += w->pobj->ob_y;
		redraw(w, &g);

	/* ggf. Scrollen, so daû Objekte sichtbar werden */

		if	(first_sel_line >= 0)
			{
			if	((first_sel_line < w->yscroll) ||
				 (first_sel_line >= w->yscroll+w->wlins))
				{
				vshift(w, first_sel_line);
				}
			}
			
		}
	dirty_info(w);
}


/****************************************************************
*
* Die Anzahl/Art der selektierten Dateien fÅr Fenster <wnr> hat
* sich geÑndert. Zeichnet die neuen Infozeilen neu.
*
****************************************************************/

void upd_infos( void )
{
	register int i;
	register WINDOW **pw,*w;

	for	(i=1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) && dirty[i] &&
			 !(w->flags & WFLAG_ICONIFIED))
			{
			set_info(w);
			wind_set_str(w->handle, WF_INFO, w->info);
			dirty[i] = FALSE;
			}
		}
}


/****************************************************************
*
* Der Spaltenmodus hat sich geÑndert.
* Zeichnet alle nîtigen Fenster neu, wenn "zeige als Text"
*
****************************************************************/

void upd_col( void )
{
	register int i,oldcol;
	register WINDOW **pw,*w;


	if	(status.showtyp == M_ABILDR)
		return;
	for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++,pw++)
		{
		w = *pw;
		if	((w) &&
			 (w->shownum > 1) &&
			 !(w->flags & WFLAG_ICONIFIED))
			{
			if	(status.is_1col)
				{
				if	(w->cols > 1)
					goto doit;
				else continue;
				}
			else {
				oldcol = w->cols;
				calc_collin(w);
				if	(oldcol == w->cols)
					continue;
				}

			doit:
			re_arrange(w);
			upd_wind(w);
			}
		}
}


/****************************************************************
*
* Das Fenster wird auf "Optimal"grîûe gebracht.
*
****************************************************************/

static void optimalsize_wnd( WINDOW *w )
{
	GRECT g,og;
	int cols = w->cols;
	int lins = w->lins;
	int maxx,maxy;
	int opt_w;


	if	(w->shownum < cols)
		cols = w->shownum;

	if	((w->flags & WFLAG_ICONIFIED) || (!cols))
		return;

	maxx = desk_g.g_x + desk_g.g_w;
	maxy = desk_g.g_y + desk_g.g_h;

	/* 1. Versuch: Spaltenanzahl unverÑndert */
	/* ------------------------------------- */

	g.g_x = w->in.g_x;
	g.g_y = w->in.g_y;
	g.g_w = w->xoffs + cols * (w->showw + w->xdist)
				- w->xdist;
	g.g_h = w->yoffs + lins * (w->showh + w->ydist) - w->ydist;

	wind_calc_grect(WC_BORDER, w->kind, &g, &og);
	opt_w = og.g_w;
	if	(og.g_y + og.g_h <= maxy)
		goto ok;

	/* Im einspaltigen Textmodus: Hîhe unverÑndert */
	/* ------------------------------------------- */

	if	(status.is_1col && status.showtyp == M_ATEXT)
		goto ok_optw;	/* nix zu machen */

	/* 2. Versuch: Spaltenanzahl erhîhen */
	/* --------------------------------- */

	cols++;
	g.g_w += w->showw + w->xdist;
	og.g_w += w->showw + w->xdist;
	while(og.g_x + og.g_w <= maxx)
		{
		lins = (w->shownum + cols - 1) / cols;
		g.g_h = w->yoffs + lins * (w->showh + w->ydist) - w->ydist;
		wind_calc_grect(WC_BORDER, w->kind, &g, &og);
		if	(og.g_y + og.g_h <= maxy)
			goto ok;
		cols++;
		g.g_w += w->showw + w->xdist;
		og.g_w += w->showw + w->xdist;
		}

ok_optw:
	og.g_w = opt_w;
	og.g_h = maxy - w->out.g_y;
ok:
	if	((w->out.g_x == og.g_x) && (w->out.g_y == og.g_y) &&
		 (w->out.g_w == og.g_w) && (w->out.g_h == og.g_h))
		wind_get_grect(w->handle, WF_PREVXYWH, &og);

	/* zulÑssige Minimalgrîûe berÅcksichtigen */
	/* -------------------------------------- */

	if	(wind_get_grect(w->handle, WF_MINXYWH, &g))
		{
		if	(og.g_w < g.g_w)
			og.g_w = g.g_w;
		if	(og.g_h < g.g_h)
			og.g_h = g.g_h;
		}

	/* Garantieren, daû Fenster sichtbar */
	/* --------------------------------- */

	make_g_fit_screen(&og);

	/* Neue Grîûe setzen */
	/* ----------------- */

	if	(wind_set_grect(w->handle, WF_CURRXYWH, &og))
		{
		w->out = og;
		if	(re_arrange(w))
			upd_wind(w);
		}
}


/****************************************************************
*
* Das Fenster wird auf Maximalgrîûe gebracht.
*
****************************************************************/

static void MY_fulled( WINDOW *w )
{
	optimalsize_wnd(w);
#if 0
	register int whdl;
	GRECT   prev, full;
	register GRECT *out;


	whdl = w->handle;
	if	(w->flags & WFLAG_ICONIFIED)
		return;
	out = &(w->out);				/* out = Auûenmaûe */
	wind_get_grect(whdl, WF_PREVXYWH, &prev);
	wind_get_grect(whdl, WF_FULLXYWH, &full);
 
	/* 1. Fall: Das Fenster hat bereits Maximalgrîûe	  */
	/*		  Also muû das Fenster verkleinert werden */
	/* ------------------------------------------------ */

	if	((out->g_x == full.g_x) && (out->g_y == full.g_y) &&
		 (out->g_w == full.g_w) && (out->g_h == full.g_h)) {
		graf_shrinkbox(&prev, &full);
		*out = prev;
		}

	/* 2. Fall: Das Fenster hat nicht Maximalgrîûe	  */
	/*		  Also Grîûe auf Maximum 			  */
	/* ------------------------------------------------ */

	else {
		graf_growbox(out, &full);
		*out = full;
		}

	wind_set_grect(whdl, WF_CURRXYWH, out);
	if	(re_arrange(w))
		upd_wind(w);
#endif
}


/****************************************************************
*
* Ein Tastencode muû verarbeitet werden.
*
****************************************************************/

static void MY_keyed( WINDOW *w, int kstate, int key )
{
	char *root = "X:";
	int drv,n,len;
	int shift;
	long errcode;


	if	(w->flags & WFLAG_ICONIFIED)
		return;

	/* Ctrl-Shift-Buchstabe: Laufwerk wechseln */
	/* --------------------------------------- */

	shift = (kstate & (K_RSHIFT + K_LSHIFT));
	if	( !(kstate & K_ALT) &&
		  shift &&
		  (kstate & (K_CTRL)))
		{
		drv = (key & 0x3f) + 'A' - 1;
		if	(drv_to_icn(drv) >= 0)
			{
			w->path[0] = drv;
			w->path[3] = EOS;
			upd_path(w, TRUE);
			}
		return;
		}

	switch(key)
		{
/* Einfg */
		case 0x5200:	/*w->fulled(w);*/
					optimalsize_wnd(w);
					break;
/* Pos1  */
		case	0x4700:	w->arrowed(w, -1);
					break;
/* SH-Pos1 */
		case 0x4737:	w->arrowed(w, -2);
					break;
/* Cursor up */
		case 0x4800:	w->arrowed(w, WA_UPLINE);
					break;
/* Cursor down */
		case 0x5000:	w->arrowed(w, WA_DNLINE);
					break;
/* SH-Cursor up */
		case 0x4838:	w->arrowed(w, WA_UPPAGE);
					break;
/* SH-Cursor dwn */
		case 0x5032:	w->arrowed(w, WA_DNPAGE);
					break;
/* Esc */
		case 0x011b:	if	(shift)
						{
						errcode = Dlock(1, w->real_drive);
						if	(errcode < 0)
							{
							root[0] = w->real_drive + 'A';
							err_file = root;
							err_alert(errcode);
							}
						else	Dlock(0, w->real_drive);
						}
					dirty_drives[w->real_drive] = TRUE;
					break;
/* ^H */
		case 0x2308:	control_h:
					parent_path(w);
					break;
/* BS */
		case 0x0e08:	if	(kstate & (K_CTRL))
						goto control_h;
					len = (int) strlen(w->sel_maske);
					if	(!len)
						break;
					if	(len > 2)
						{
						w->sel_maske[len-2] = '*';
						w->sel_maske[len-1] = EOS;
						}
					else	{
						w->sel_maske[0] = EOS;
						}
					upd_selmask(w);
					break;
/* Undo */
		case 0x6100:	if	(w->path[3])
						{
						w->path[3] = '\0';
						upd_path(w, FALSE);
						}
					break;

		default:		n = key & 0xff;
					len = (int) strlen(w->sel_maske);
					if	(n == ' ')
						{
						if	(!len)
							break;
						if	(w->sel_maske[len-1] == '*')
							{
							w->sel_maske[len-1] = EOS;
							upd_selmask(w);
							}
						}
					else
					if	((n > ' ') && (len < MAX_SELMASK))
						{
						if	(!len)
							{
							dsel_all();
							w->sel_maske[0] = '*';
							len++;
							}
						if	(w->sel_maske[len-1] != '*')
							{
							w->sel_maske[len] = toupper(n);
							}
						else	{
							w->sel_maske[len-1] = toupper(n);
							w->sel_maske[len] = '*';
							}
						w->sel_maske[len+1] = EOS;
						upd_selmask(w);
						}
				}
}


/****************************************************************
*
* Behandlung aller anderen Nachrichten.
*
****************************************************************/

#pragma warn -par
static void MY_message( WINDOW *w, int kstate, int message[16])
{
}
#pragma warn +par
