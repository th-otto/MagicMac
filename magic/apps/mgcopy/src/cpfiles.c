/*********************************************************************
*
* Dieses Modul enthÑlt die Bearbeitung aller Dateioperationen, also
*  Lîschen, Kopieren, Verschieben, Umbenennen.
* (mit BedienerfÅhrung Åber Dialogboxen)
*
*********************************************************************/

#define DEBUG 0

#include <mgx_dos.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include "mgcopy.h"
#include "cpfiles.h"
#include "gemut_mt.h"
#include "globals.h"
#include "dat_dial.h"

#define FLP_BSIZE	32768L
#define ESKIP		-1000	/* Fehlercode bei "öberspringen" */
#define MAX_PATHLEN		256
#define MAX_PATHDEPTH	12
#define MAX_NAMELEN		64

static long cluster_size_dst;	/* Clustergrîûe auf Zielpfad */
static long n_clu_dst;		/* soviele Cluster brÑuchten wir
						   auf dem Zielpfad */
static long size_src;		/* soviele Bytes momentan belegt */
static long netto_size_src;	/* zur Berechnung des Forschr.balkens */

static int _move_flag;		/* Verschieben/Kopieren */
static long bsize;			/* Puffergrîûe fÅrs Kopieren */
static char *copy_buffer;
static char *_zielpath;

static char dirty_drives[32];

static int copy_mode = CONFIRM;

static char *delete_file_s;
static char *delete_folder_s;
static char *move_file_s;
static char *read_file_s;
static char *write_file_s;
static char *create_folder_s;

#if DEBUG
static char *errcommand;
#endif

/****************************************************************
*
* Initialisierung
*
****************************************************************/

void init_messages( void )
{
	delete_file_s = Rgetstring(STR_DEL_FILE, NULL);
	delete_folder_s = Rgetstring(STR_DEL_FOLDER, NULL);
	move_file_s = Rgetstring(STR_MOVE_FILE, NULL);
	read_file_s = Rgetstring(STR_READ_FILE, NULL);
	write_file_s = Rgetstring(STR_WRITE_FILE, NULL);
	create_folder_s = Rgetstring(STR_CREATE_FOLDR, NULL);
}


/****************************************************************
*
* Verschickt SH_WDRAW
*
****************************************************************/

void send_shwdraw( void )
{
	register int i;
	register char *s;
	int	msg[8];


	msg[1] = ap_id;
	msg[5] = msg[6] = msg[7] = 0;
	for	(i = 0,s=dirty_drives; i < 32; i++,s++)
		if	(*s)
			{
			*s = FALSE;
			msg[0] = SH_WDRAW;
			msg[2] = 0;
			msg[3] = i;
			msg[4] = msg[5] = msg[6] = msg[7] = 0;
			appl_write(0, 16, msg);
			}

	if	((copy_mode >= 0) && (copy_mode != RENAME))
		{
		msg[0] = 'AK';		/* Post an die Shell */
		msg[1] = ap_id;
		msg[2] = 0;
		msg[3] = 1;		/* Opcode 1 */
		msg[4] = copy_mode;
		appl_write(0, 16, msg);
		}
}


/****************************************************************
*
* Gibt zu einem DOS- Fehler den entsprechenden Text
*
****************************************************************/

static char *err_file;

static long err_alert(long e)
{
	form_xerr(e, err_file);
	err_file = NULL;

#if DEBUG
if	(e)
{
char buf[256];

strcpy(buf, "[3][Fehler bei ");
strcat(buf, errcommand);
strcat(buf,"][OK]");
form_alert(1, buf);
}
#endif

	return(e);
}


/****************************************************************
*
* Der Fall "Datei schreibgeschÅtzt"
*
* -> 1			OK
* -> DOS-Fehlercode	Abbruch
* -> 0			öberspringen
*
****************************************************************/

long test_readonly(char *path, char *fname, XATTR *xa)
{
	int ret;
	char buf[MAX_PATHLEN+2];


	if	(!((xa->attr) & FA_READONLY))
		return(1L);		/* OK */
	ret = Rxform_alert(3, ALRT_FILE_RDONLY, path[0],
					fname, NULL);
	if	(ret == 1)
		return(E_OK);		/* Åberspringen */
	if	(ret == 3)
		return(EBREAK);	/* Abbruch */
	strcpy(buf, path);
	strcat(buf, fname);

#if DEBUG
errcommand = "Fattrib";
#endif

	return(Fattrib(buf, 1, (xa->attr) & ~FA_READONLY));
}


/****************************************************************
*
* Der Fall "Datei existiert schon"		(is_ren = FALSE)
* bzw. "Datei umbenennen"			(is_ren = TRUE)
*
* An <path> ist zu erkennen, ob die Datei Format 8+3 hat und
* wie die maximale Dateinamen-LÑnge ist.
*
* -> 1	OK
* -> -1	Abbruch
* -> 0	öberspringen
*
****************************************************************/

static int dial_datexi(char *path, char *fname, filetype ftype,
					int is_ren)
{
	int whdl;
	long ret;
	FILEDESCR fd;
	EVNT w_ev;
	int panic;


	ret = Dpathconf(path, DP_NAMEMAX);
	if	(ret > 0L)
		{
		fd.maxnamelen = ret;
		fd.is_8_3 = (Dpathconf(path, DP_TRUNC) == DP_DOSTRUNC);
		}
	else	{
		fd.is_8_3 = TRUE;
		fd.maxnamelen = 12;
		}
	fd.ftype = ftype;
	fd.fname = fname;

	d_dat = wdlg_create(hdl_dat,
					adr_dat,
					&fd,		/* user_data */
					0,		/* code */
					NULL,	/* data */
					is_ren);	/* flags */
	if	(!d_dat)
		goto err;

	whdl = wdlg_open( d_dat,
				Rgetstring((is_ren) ?
				STR_RENAME : STR_NAMECONFLICT, NULL),
				NAME+CLOSER+MOVER,
				-1, -1,
				0,
				NULL );

	if	(whdl <= 0)
		{
		wdlg_delete(d_dat);
		d_dat = NULL;
		err:
		Rform_alert(1, ALRT_ERROPENWIND, NULL);
		return(-1);		/* Abbruch */
		}

	panic = FALSE;
	while((fd.answ == WAITING) && !panic)
		{
		w_ev.mwhich = evnt_multi(
				MU_KEYBD+MU_BUTTON+MU_MESAG,
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

		if	(abbruch)		/* "Abbruch" im Hauptdialog */
			goto abbr;

		if	(w_ev.mwhich & MU_MESAG)
			{
			if	((w_ev.msg[0] == AP_TERM) ||
				(w_ev.msg[0] == PA_EXIT))
				{
				abbr:
				panic = TRUE;
				goto cldat;
				}
			}
	
		if	(d_dat && !wdlg_evnt(d_dat, &w_ev))
			{
			cldat:
			wdlg_close(d_dat, NULL, NULL);
			wdlg_delete(d_dat);
			d_dat = NULL;
			}

		}

	if	(panic)
		return(-1);
	if	(fd.answ == CANCEL)
		return(-1);
	if	(fd.answ == OK)
		return(1);
	return(0);
}


/****************************************************************
*
* Ermittle freien Speicher und Clustergrîûe fÅr <path>
*
****************************************************************/

static long pathinfo(char *path, long *free_clusters,
		long *cluster_size)
{
	DISKINFO di;
	DTA dta;
	long errcode;
	int drv;


	/* Diskwechsel erkennen */
	/* -------------------- */

	Fsetdta(&dta);
	drv = (path[0] & 0x5f) - 'A';
	Dsetdrv(drv);
	errcode = Dsetpath(path);

	if	(errcode)
		return(errcode);
	errcode = Fsfirst("*.*", 0);

	if	(errcode && (errcode != EFILNF))
		return(errcode);
	errcode = Dsetpath(path);

	if	(!errcode)
		errcode = Dfree(&di, 0);

	*free_clusters = di.b_free;
	*cluster_size = di.b_secsiz * di.b_clsiz;

	return(errcode);
}


/*********************************************************************
*
* Fragt, ob abgebrochen werden soll.
*
*********************************************************************/

int qbreak( void )
{
	if	(abbruch ||
		(Kbshift(-1) & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT))
		{
		if	(abbruch)
			ackn_cancel();

		if	(1 == Rform_alert(1, ALRT_STOPPROCESS, NULL))
			return(TRUE);
		}
	return(FALSE);
}


/*********************************************************************
*
* Setzt das Dirty- Flag von Laufwerk <lw>.
*
*********************************************************************/

void set_dirty(long err, char *path, char val)
{
	int drv;

	if	(err != EWRPRO && err != EDRIVE && err != EFILNF &&
	 	 err != EPTHNF && err != EACCDN && err != ENSAME)
	 	{
	 	drv = *path - 'A';
	 	if	(drv == 'U'-'A')
	 		{
	 		if	(path[4] == '\\')
	 			drv = path[3] - 'A';
	 		}
	 	if	(dirty_drives[drv] == 1)
	 		return;		/* schon "dirty" */
		dirty_drives[drv] = val;
		}
}


/*********************************************************************
*
* Lîscht eine Datei
*
*********************************************************************/

long GFdelete(char *path, char *name)
{
	char all[MAX_PATHLEN+2];
	long doserr;


	strcpy(all,path);
	if	(name)
		strcat(all,name);
	down_cnt(2, delete_file_s, all, 0L);
	doserr = Fdelete(all);

#if DEBUG
errcommand = "Fdelete";
#endif

	set_dirty(doserr, path, 1);
	err_file = all;
	return(err_alert(doserr));
}


/*********************************************************************
*
* Lîscht einen Ordner
*
*********************************************************************/

long GDdelete(char *path, char *name)
{
	char all[MAX_PATHLEN+2];
	long doserr;


	strcpy(all,path);
	if	(name)
		strcat(all,name);
	down_cnt(2, delete_folder_s, all, 0L);
	doserr = Ddelete(all);

#if DEBUG
errcommand = "Ddelete";
#endif


/*
	/o 1. Versuch: Standardverzeichnis wechseln o/
	/o ---------------------------------------- o/

	if	(doserr == EACCDN)
		{
		char *freep = "X:\\";

		freep[0] = path[0];
		Dsetpath(freep);
		doserr = Ddelete(all);

	/o 2. Versuch: Laufwerk freigeben o/
	/o ------------------------------ o/

		if	(doserr == EACCDN)
			{
			if	(!Dlock(DLOCKMODE_LOCK, path[0]-'A'))
				{
				Dlock(DLOCKMODE_UNLOCK, path[0]-'A');
				doserr = Ddelete(all);
				}
			}
		}
*/

	set_dirty(doserr, path, 1);
	err_file = all;
	return(err_alert(doserr));
}


/*********************************************************************
*
* PrÅft, ob die Datei mit dem kompletten Pfad <all> schon existiert
* bzw. Åberschrieben werden darf.
*
* Parameter:	all			kompletter Zielpfad
*			old_file		XATTR der existierenden Datei oder NULL
*			new_file		XATTR der neuen Datei.
*
* RÅckgabe:	EFILNF		Datei darf Åberschrieben werden
*			EACCDN		Datei darf nicht Åberschrieben werden
*			< 0			Diskettenfehler
*			<new_file>	enthÑlt den ermittelten XATTR-Block
*
* Wird aufgerufen von GFcreate, GFsymlink und GFrename
*
*********************************************************************/

static long does_exist(char *all, XATTR *old_file, XATTR *new_file)
{
	long doserr;


	if	(copy_mode == OVERWRITE)
		return(EFILNF);

	doserr = Fxattr(1, all, new_file);		/* keine Aliase auflîsen */

#if DEBUG
errcommand = "Fxattr";
#endif

	if	(doserr == E_OK && old_file && (copy_mode == BACKUP))
		{
		if	( ((unsigned) old_file->mdate  >
			   (unsigned) new_file->mdate) ||
			 (((unsigned) old_file->mdate == (unsigned) new_file->mdate) &&
			    ((unsigned) old_file->mtime > (unsigned) new_file->mtime))
			)
		doserr = EFILNF;	/* Ñltere Datei: Åberbraten */
		}
	if	(doserr == E_OK)
		doserr = EACCDN;

	return(doserr);
}


/*********************************************************************
*
* Erstellt eine Datei <fname> in <path>.
* Ggf. wird andere Datei erzeugt und <fname> verÑndert.
*
* RÅckgabe: E_OK		Åberspringen, bei Verschieben lîschen
*		  ESKIP		öberspringen, bei Verschieben nicht lîschen
*		  EBREAK		Abbruch
*		  > 0		Dateihandle
*		  < 0		Fehlercode
*
*********************************************************************/

long GFcreate(char *path, char *fname, XATTR *file)
{
	XATTR newfile;
	char	all[MAX_PATHLEN+2],oldname[MAX_NAMELEN+2];
	long doserr;
	unsigned int attr;
	int ret;
	char query = (copy_mode != OVERWRITE);


	attr = file->attr;				/* Attribute der Quelldatei */
	attr &= ~F_RDONLY;				/* ReadOnly nicht Åbernehmen */
	newfile.mode = S_IFREG;			/* initialisieren */

	do	{
		strcpy(all, path);
		strcat(all, fname);
		if	(query)
			{
			query = FALSE;

			/* prÅfen, ob Datei schon existiert */
			/* -------------------------------- */

			doserr = does_exist(all, file, &newfile);

			/* ernste Diskettenfehler: sofort abbrechen */
			/* ---------------------------------------- */

			if	(doserr != EACCDN && doserr != EFILNF)
				{
				err_file = all;
				return(err_alert(doserr));
				}

			/* Datei ist schon gesichert: öberspringen */
			/* --------------------------------------- */

			if	((doserr == EACCDN) &&
				 (copy_mode == BACKUP))
				return(E_OK);	/* bei Verschieben: Lîschen */

			/* Datei existiert noch nicht: Erstellen */
			/* ------------------------------------- */

			if	(doserr == EFILNF)
				doserr = Fcreate(all, attr);

#if DEBUG
errcommand = "Fcreate";
#endif

			}


		/* Nicht nachfragen bzw. schon nachgefragt */
		/* --------------------------------------- */

		else {
			if	((newfile.mode & S_IFMT) == S_IFLNK)
				Fdelete(all);		/* existierenden Symlink lîschen */
		 again:
			doserr = Fcreate(all, attr);

#if DEBUG
errcommand = "Fcreate";
#endif

			if	(doserr == EACCDN)
				{
				if	(!Fxattr(1, all, &newfile))
					{
					doserr = test_readonly(path, fname, &newfile);
					if	(doserr > 0)
						goto again;
					if	(!doserr)
						doserr = EACCDN;
					}
				}
			}

		if	(doserr == EACCDN)
			{
			strcpy(oldname, fname);
			ret = dial_datexi(all, fname, ORDINARYFILE, FALSE);
			if	(strcmp(fname, oldname))
				{
				query = TRUE;
				}
			if	(ret == 0)		/* öberspringen */
				return(ESKIP);
			if	(ret < 0)			/* Abbruch */
				return(EBREAK);
			}
		}
	while(doserr == EACCDN);

	set_dirty(doserr, path, 1);
	if	(doserr < E_OK)
		{
		err_file = all;
		err_alert(doserr);
		}
	return(doserr);
}


/*********************************************************************
*
* Erstellt einen Symlink <fname> in <path>, mit dem Wert <buf>.
* Ggf. wird andere Datei erzeugt und <fname> verÑndert.
* <xa> darf NULL sein.
*
* RÅckgabe: E_OK		Åberspringen
*		  EBREAK		Abbruch
*		  < 0		Fehlercode
*
*********************************************************************/

long GFsymlink(char *buf, char *path, char *fname, XATTR *xa)
{
	XATTR newfile;
	struct mutimbuf mutime;
	char	all[MAX_PATHLEN+2],oldname[MAX_NAMELEN+2];
	long doserr;
	int ret;
	char query = (copy_mode != OVERWRITE);
	char do_rename = (copy_mode == RENAME);


	if	(xa)
		{
		mutime.actime = xa->atime;
		mutime.acdate = xa->adate;
		mutime.modtime = xa->mtime;
		mutime.moddate = xa->mdate;
		}

	do	{
		strcpy(all, path);
		strcat(all, fname);
		if	(query)
			{
			if	(do_rename)
				{
				do_rename = FALSE;
				doserr = EACCDN;
				}
			else	{
				query = FALSE;
				/* prÅfen, ob Datei schon existiert */
				doserr = does_exist(all, xa, &newfile);
				/* ernste Diskettenfehler: sofort abbrechen */
				if	(doserr != EACCDN && doserr != EFILNF)
					{
					err_file = all;
					return(err_alert(doserr));
					}
				/* Datei ist schon gesichert, Åberspringen */
				if	((doserr == EACCDN) &&
					 (copy_mode == BACKUP))
					return(E_OK);
				if	(doserr == EFILNF)
					goto create_symlink;
				}
			}
		else {
			 create_symlink:
			doserr = Fsymlink(buf, all);


#if DEBUG
errcommand = "Fsymlink";
#endif

			/* Den Fall "irgendwas durch einen Symlink ersetzen" behandeln */
			/* ----------------------------------------------------------- */

			if	(doserr == EACCDN)
				{
				XATTR xa;

				doserr = Fxattr(1, all, &xa);

#if DEBUG
errcommand = "Fxattr";
#endif

				if	(!doserr)
					{
					doserr = EACCDN;

					/* Symlink ersetzt regulÑre Datei: nachfragen! */
					/* ------------------------------------------- */

					if	(((xa.mode & S_IFMT) == S_IFREG))
						{
						if	(1 == Rxform_alert(2, ALRT_REPL_W_ALIA,
									path[0], fname, NULL))
							doserr = E_OK;
						}
					else

					/* Symlink ersetzt Symlink: ÅberbÅgeln! */
					/* ------------------------------------ */

					if	((xa.mode & S_IFMT) == S_IFLNK)
						doserr = E_OK;

					if	(!doserr)
#if DEBUG
{
#endif
						doserr = Fdelete(all);

#if DEBUG
errcommand = "Fdelete";
}
#endif

					if	(!doserr)
#if DEBUG
{
#endif
						doserr = Fsymlink(buf, all);

#if DEBUG
errcommand = "Fsymlink";
}
#endif

					}
				}
			}
		if	(!doserr && xa)
			{
			Dcntl(FUTIME, all, (long) (&mutime));
			}

		if	(doserr == EACCDN)
			{
			strcpy(oldname, fname);
			ret = dial_datexi(all, fname, ALIAS, FALSE);
			if	(strcmp(fname, oldname))
				{
				query = TRUE;
				}
			if	(ret == 0)		/* öberspringen */
				return(E_OK);
			if	(ret < 0)			/* Abbruch */
				return(EBREAK);
			}
		}
	while(doserr == EACCDN);
	set_dirty(doserr, path, 1);
	if	(doserr < E_OK)
		{
		err_file = all;
		err_alert(doserr);
		}
	return(doserr);
}


/*********************************************************************
*
* Verschiebt eine Datei oder einen Ordner <name> unter dem neuen
* Namen <new_name> nach <path>. <new_name> kann verÑndert werden,
* wenn die Datei schon existiert.
* <fname> wird nicht verÑndert.
*
* ENSAME erzeugt keinen Alert!
*
*********************************************************************/

long GFrename(char *path, char *fname,
			char *new_name, XATTR *xa, char *zpath)
{
	XATTR newfile;
	int old_ftype,new_ftype;
	char	alls[MAX_PATHLEN+2],alld[MAX_PATHLEN+2];
	long doserr;
	int ret;
	char query = copy_mode;


	/* PrÅfen, ob Objekt schreibgeschÅtzt.	*/
	/* Ggf. Abbruch oder Åberspringen		*/
	/* ------------------------------------ */

	old_ftype = ((xa->mode & S_IFMT) == S_IFDIR) ?
				FOLDER : ORDINARYFILE;

	doserr = test_readonly(path, fname, xa);
	if	(doserr <= E_OK)
		return(doserr);		/* Fehler/Abbruch/öberspringen */

	strcpy(alls, path);
	strcat(alls, fname);

	down_cnt(2, move_file_s, alls, 0L);
	do	{
		strcpy(alld, zpath);
		strcat(alld, new_name);
/*
Cconws("rename ");Cconws(alls);Cconws(" => ");Cconws(alld);Cconws("\r\n");
*/
		doserr = Frename(0, alls, alld);

#if DEBUG
errcommand = "Frename";
#endif

		if	(doserr == EACCDN)
			{
/*
Cconws("EACCDN ");
*/
			/* Frename() verweigert Zugriff. Mal sehen, ob	*/
			/* das Zielobjekt existiert und was es ist		*/
			/* ---------------------------------------------- */

			doserr = Fxattr(1, alld, &newfile);		/* keine Aliase auflîsen */
			if	(doserr)
				return(EACCDN);		/* anderer Schutz? */
			new_ftype = ((newfile.mode & S_IFMT) == S_IFDIR) ?
						FOLDER : ORDINARYFILE;
			/* Ordner soll auf Datei verschoben werden	*/
			/* oder umgekehrt.						*/
			if	(old_ftype != new_ftype)
				{
				doserr = EACCDN;
				goto do_dial_datexi;
				}

			/* Zielordner ex. schon. */
			if	(old_ftype == FOLDER)
				return(ENSAME);		/* Ordner benutzen */

			if	(old_ftype != FOLDER)
				{

				/* Sowohl alte als auch neue Datei ist kein Ordner */

				if	(query == OVERWRITE)
					doserr = EFILNF;
				else	doserr = does_exist(alld, xa, &newfile);

				/* Datei schon gesichert: nur lîschen */

				if	(doserr == EACCDN && copy_mode == BACKUP)
					return(GFdelete(alls, NULL));

				/* Hypothese: EACCDN kam, weil Zieldatei ex. */
				/* Daher Zieldatei lîschen				*/

				if	(doserr == EFILNF)	/* darf ÅberbÅgeln... */
					doserr = Fdelete(alld);
				set_dirty(doserr, alld, 1);
				if	(doserr != E_OK && doserr != EACCDN)
					{
					err_file = alld;
					return(err_alert(doserr));
					}

				/* ... und Verschieben wiederholen */

				if	(doserr == E_OK)
					{
					doserr = Frename(0, alls, alld);
					set_dirty(doserr, alls, 1);
					set_dirty(doserr, alld, 1);
					}
				}
			}
		else {
			set_dirty(doserr, alls, 2);
			set_dirty(doserr, alld, 2);
			}
do_dial_datexi:
		query = FALSE;
		if	(doserr == EACCDN)
			{
			char rett_name[MAX_NAMELEN+2];

			strcpy(rett_name, new_name);
			if	(old_ftype != FOLDER)
				new_ftype = ORDINARYFILE;
			ret = dial_datexi(alld, new_name, new_ftype, FALSE);
			if	(strcmp(new_name, rett_name))
				{
				query = TRUE;
				}
			if	(ret == 0)		/* öberspringen */
				return(E_OK);
			if	(ret < 0)			/* Abbruch */
				return(EBREAK);
			}
		}
	while(doserr == EACCDN);

	if	(doserr == ENSAME)
		return(doserr);

	if	(!doserr)
		down_cnt(3, NULL, NULL, xa->size);

	err_file = alls;
	return(err_alert(doserr));
}


/*********************************************************************
*
* Kopiert einen Symlink <fname> in <path> nach <dstpath>.
* Ggf. wird andere Datei erzeugt und <fname> verÑndert.
*
*********************************************************************/

long GFcopy_symlink(char *path, char *fname,
				char *new_name, XATTR *xa, char *dstpath)
{
	char	alls[MAX_PATHLEN+2];
	long err;
	char	buf[MAX_PATHLEN+2];


	if	(qbreak())
		return(EBREAK);

	strcpy(alls, path);			/* Quellpfad */
	strcat(alls, fname);
	err_file = alls;
	down_cnt(2, read_file_s, alls, 0L);
	err = Freadlink(255, buf, alls);

#if DEBUG
errcommand = "Freadlink";
#endif

	if	(err)
		return(err_alert(err));
	if	(qbreak())
		return(EBREAK);

	strcpy(alls, dstpath);
	strcat(alls, new_name);
	down_cnt(2, write_file_s, alls, 0L);
	err = GFsymlink(buf, dstpath, new_name, xa);
	if	(!err)
		down_cnt(3, NULL, NULL, 1024L);
	return(err);
}


/*********************************************************************
*
* Kopiert eine Datei <fname> in <path> nach <zpath>.
* Ggf. wird andere Datei erzeugt und <fname> verÑndert.
* RÅckgabe ESKIP, falls die Datei Åbersprungen werden soll; sie
* darf dann beim Verschieben nicht gelîscht werden.
*
*********************************************************************/

long GFcopy(char *path, char *fname,
			char *new_name, XATTR *xa, char *zpath)
{
	char	alls[MAX_PATHLEN+2],alld[MAX_PATHLEN+2];
	long doserr;
	int shdl,dhdl;
	long lbytes;
	int drv;
	long	my_bsize;		/* ggf. fÅr Floppies kleineren Puffer nehmen */


	/* Symlinks extra kopieren */

	if	((xa->mode & S_IFMT) == S_IFLNK)
		return(GFcopy_symlink(path, fname, new_name, xa, zpath));

	/* Andere als regular files nicht kopieren */

	if	((xa->mode & S_IFMT) != S_IFREG)
		return(err_alert(EACCDN));

	/* Speicher holen, Quellpfad zusammenstellen */
	/* ----------------------------------------- */

	if	(qbreak())
		return(EBREAK);

	dhdl = shdl = -1;			/* Dateien sind noch nicht geîffnet */

	strcpy(alls, path);
	strcat(alls, fname);

	/* benutzte Puffergrîûe ggf. verkleinern */

	drv = (alls[0] & 0x5f) - 'A';
	my_bsize = bsize;
	if	(((drv == 0) || (drv == 1)) && (bsize > FLP_BSIZE))
		my_bsize = FLP_BSIZE;	/* Floppy! */

	/* Kopierschleife */
	/* -------------- */

	do	{
		if	(qbreak())
			{
			abbruch:
			doserr = EBREAK;
			break;
			}

		/* Im Backupmodus wird erst die Zieldatei geîffnet */
		/* ----------------------------------------------- */

		if	(dhdl < 0 && copy_mode == BACKUP)
			lbytes = 0L;

		/* Ansonsten die Quelldatei gelesen und ggf. geîffnet */
		/* -------------------------------------------------  */

		else	{
			down_cnt(2, read_file_s, alls, 0L);
			if	(shdl < 0)
				{
				doserr = Fopen(alls, RMODE_RD);

#if DEBUG
errcommand = "Fopen";
#endif

				if	(((int) doserr) == -4)	/* NUL: */
					doserr = EACCDN;
				if	(doserr < E_OK)
					goto source_error;
				shdl = (int) doserr;
				}
			doserr = Fread(shdl, my_bsize, copy_buffer);

#if DEBUG
errcommand = "Fread";
#endif

			if	(doserr < E_OK)
				{
				source_error:
				err_file = alls;
				break;			/* Fehler beim Lesen */
				}
			if	(doserr >= E_OK && doserr < my_bsize)
				{
				Fclose(shdl);
				shdl = -2;			/* Flag fÅr das Ende */
				}
			if	(qbreak())
				goto abbruch;
			lbytes = doserr;			/* soviele Bytes sind gelesen */
			}

		/* Die Zieldatei wird geîffnet */
		/* --------------------------- */

		if	(dhdl < 0)
			{
			strcpy(alld, zpath);
			strcat(alld, new_name);
			down_cnt(2, write_file_s, alld, 0L);
			doserr = GFcreate(zpath, new_name, xa);
			strcpy(alld, zpath);
			strcat(alld, new_name);	/* Name ggf. geÑndert */
			if	(doserr <= E_OK)	/* < 0: Fehler oder Abbruch */
				{				/* = 0: öberspringen 	   */
				if	(!doserr)
					down_cnt(3, NULL, NULL, xa->size);
				break;
				}
			dhdl = (int) doserr;
			}

		if	(qbreak())
			{
			doserr = EBREAK;
			continue;
			}

		/* <lbytes> gelesene Bytes werden geschrieben */
		/* ------------------------------------------ */

		if	(lbytes)
			{
			down_cnt(2, write_file_s, alld, 0L);
			doserr = Fwrite(dhdl, lbytes, copy_buffer);

#if DEBUG
errcommand = "Fwrite";
#endif

			if	(doserr < E_OK)
				err_file = alld;
			else	down_cnt(3, NULL, NULL, lbytes);
			if	(doserr >= 0L && doserr < lbytes)
				{
				Rform_alert(1, ALRT_DISKFULL, NULL);
				doserr = -1L;
				}
			}
		}
	while(shdl != -2 && doserr >= E_OK);

	if	(doserr > E_OK)
		doserr = E_OK;
	if	(shdl > 0)
		Fclose(shdl);
	if	(dhdl > 0)
		{
		Fdatime((DOSTIME *) &(xa->mtime), dhdl, RMODE_WR);
		Fclose(dhdl);
		}
	if	((dhdl > 0) && (doserr != E_OK) &&
		 (doserr != EWRPRO) && (doserr != EDRVNR))
		Fdelete(alld);
	if	((err_file) && (doserr != ESKIP))
		err_alert(doserr);
	return(doserr);
}


/*********************************************************************
*
* Erstellt einen Ordner <name> in <path>.
* Ggf. wird anderer Ordner erzeugt und <name> verÑndert.
*
*********************************************************************/

long GDcreate(char *path, char *name)
{
	char	all[MAX_PATHLEN+2];
	long doserr,doserr2;
	int ret;
	XATTR newfile;
	int new_ftype;
	int  do_rename = (copy_mode == RENAME);


	do	{
		strcpy(all, path);
		strcat(all, name);
		down_cnt(2, create_folder_s, all, 0L);
		if	(do_rename)
			doserr = EACCDN;
		else	doserr = Dcreate(all);

/*
Cconws("Dcreate ");Cconws(all);Cconws("\r\n");
*/

#if DEBUG
errcommand = "Dcreate";
#endif

		if	(doserr == EACCDN)
			{

			/* Dcreate() verweigert Zugriff. Mal sehen, ob	*/
			/* das Zielobjekt existiert und was es ist		*/
			/* ---------------------------------------------- */

			doserr2 = Fxattr(1, all, &newfile);		/* keine Aliase auflîsen */
			if	(doserr2)
				return(doserr);		/* anderer Schutz? */
			/* Ordner ex. schon. Ggf einfach benutzen */
			new_ftype = ((newfile.mode & S_IFMT) == S_IFDIR) ?
						FOLDER : ORDINARYFILE;
			if	((new_ftype == FOLDER) &&
				 ((copy_mode == BACKUP) || (copy_mode == OVERWRITE))
				)
				return(E_OK);		/* Bei BACKUP immer benutzen */

			ret = dial_datexi(all, name, new_ftype, do_rename);
			do_rename = FALSE;
			if	(ret == 0)		/* Benutzen */
				return((new_ftype == FOLDER) ? E_OK : ESKIP);
			if	(ret < 0)			/* Abbruch */
				return(EBREAK);
			
			}
		}
	while(doserr == EACCDN);
	set_dirty(doserr, path, 1);
	err_file = all;
	return(err_alert(doserr));
}


/*********************************************************************
*
* DurchlÑuft einen Pfad und fÅhrt bei jeder gefundenen Datei
* vorher ein Programm <before>, hinterher <after> aus.
* Sind <before> und <after> == NULL, werden nur Informationen gesammelt.
* gibt ggf. DOS- Fehlercode zurÅck.
*
*********************************************************************/

static long _nbytes,_hbytes;
static int  _nfiles,_hfiles,_folders;
static long (*_before)(char *path, char *fname, XATTR *xa);
static long (*_after) (char *path, char *fname, XATTR *xa);
static int  depth;
static char *_path;


static long _walk_path( void )
{
	XATTR xa;
	long dirhandle;
	int	dirlen;			/* Anzahl EintrÑge in diesem Verzeichnis */
	long err;
	long err_xr;
	char *endp;
	char fname[MAX_NAMELEN+4+1];


	err = strlen(_path);
	endp = _path + err;
	depth++;

/*
	if	(depth == 6)
		{
		Cconws("TIEFE = 6\r\n");
		Cconin();
		}
	if	(depth == 7)
		{
		Cconws("TIEFE = 7\r\n");
		Cconin();
		}
	if	(depth == 8)
		{
		Cconws("TIEFE = 8\r\n");
		Cconin();
		}
*/

	if	(depth > MAX_PATHDEPTH || err > MAX_PATHLEN-MAX_NAMELEN-1)
		{
		err_alert(EPTHOV);
		depth--;
		return(E_OK);
		}
	if	(qbreak())
		return(EBREAK);
	dirlen = 0;

	dirhandle = Dopendir(_path, DOPEN_NORMAL);	/* Modus mit langen Namen */

#if DEBUG
errcommand = "Dopendir";
#endif

	if	(dirhandle < E_OK)
		return(dirhandle);			/* Fehler */

	do	{
		if	(qbreak())
			{
			err = EBREAK;
			continue;
			}

		err = Dxreaddir(MAX_NAMELEN+4+1, dirhandle, fname, &xa, &err_xr);

#if DEBUG
errcommand = "Dxreaddir";
#endif

		if	(err || err_xr)
			continue;
		if	(fname[0+4] == '.')
			{
			if	(!fname[1+4])
				continue;			/* "." */
			if	(fname[1+4] == '.' && !fname[2+4])
				continue;			/* ".." */
			}

		if	(_before)
			{
			*endp = EOS;
			if	(E_OK != (err = _before(_path, fname+4, &xa)))
				continue;
			}

		if	((xa.mode & S_IFMT) == S_IFDIR)
			{
			_folders++;
			strcpy(endp, fname+4);
			strcat(endp, "\\");
			err = _walk_path();	/* REKURSION */
			*endp = EOS;
			if	(err)
				continue;
			}
		else {
			if	(xa.attr & (F_HIDDEN | F_SYSTEM))
				{
				_hfiles++;
				_hbytes += xa.size;
				}
			else {
				_nfiles++;
				_nbytes += xa.size;
				}
			netto_size_src += xa.size;
			size_src += xa.blksize * xa.nblocks;
			if	(cluster_size_dst)
				{
				n_clu_dst += xa.size/cluster_size_dst;
				if	(xa.size % cluster_size_dst)
					n_clu_dst++;	/* auf ganze Cluster aufrunden */
				}
			}

		if	(!err && _after != NULL)
			{
			*endp = EOS;
			if	(E_OK != (err = _after(_path, fname+4, &xa)))
				continue;
			}			/* "User break" */

		dirlen++;
		if	(qbreak())
			err = EBREAK;
		} /* ENDWHILE */
	while(!err && !err_xr);

	if	(err == EFILNF || err == ENMFIL)
		err = E_OK;
	Dclosedir(dirhandle);

	depth--;
	if	(cluster_size_dst && endp > _path+3)	/* nicht Root */
		{
		long dirn;

		dirn = dirlen << 5;			/* 32 Bytes pro Eintrag */
		n_clu_dst += dirn/cluster_size_dst;
		size_src += 1024L;
		netto_size_src += 1024L;
		if	(dirn % cluster_size_dst)
			n_clu_dst++;
		}
	return(err_alert(err));
}

static long walk_path(char *path, long *nbytes,
			long *hbytes, long *folders,
			long *nfiles, long *hfiles,
			long (*before)(char *path, char *fname, XATTR *xa),
			long (*after) (char *path, char *fname, XATTR *xa))
{
	long errcode;


	_nbytes = _hbytes = _nfiles = _hfiles = _folders = depth = 0;
	_before	= before;
	_after	= after;
	_path = path;
	errcode = _walk_path();
	*nbytes   = _nbytes;		/* Bytes in normalen Dateien */
	*hbytes   = _hbytes;		/* Bytes in versteckten Dateien */
	*folders  = _folders;		/* Anzahl Ordner */
	*nfiles   = _nfiles;		/* Anzahl normale Dateien */
	*hfiles   = _hfiles;		/* Anzahl versteckte Dateien */
	return(errcode);
}


/*********************************************************************
*
* Untersucht unbekannte Dateitypen.
* Im Fall "Symlink" wird ein folgendes '\' abgesÑgt.
*
* -1		Ordner
* -2		symlink
* -3		special file
* -4		unbekannt
*
*********************************************************************/

long resolve_unknown_ftypes(char *path, long *flen)
{
	XATTR xa;
	char *lastc;
	long err;

	err_file = path;
	lastc = path+strlen(path)-1;

	if	(*flen == -2)
		{
		if	(*lastc == '\\')
			*lastc = EOS;	/* trailing '\' absÑgen */
		}
	else
	if	(*flen == -4)
		{	/* unbekanntes Objekt */
		if	(!path[3])	/* "X:\" */
			*flen = -1;
		else	{
			if	(*lastc == '\\')
				*lastc = EOS;	/* trailing '\' absÑgen */
			err = Fxattr(1, path, &xa);

#if DEBUG
errcommand = "Fxattr";
#endif

			if	(err)
				return(err);
			if	((xa.mode & S_IFMT) == S_IFLNK)
				*flen = -2;
			else
			if	((xa.mode & S_IFMT) == S_IFDIR)
				{
				*flen = -1;
				*lastc = '\\';
				}
			else
			if	((xa.mode & S_IFMT) == S_IFREG)
				*flen = xa.size;
			else	*flen = -3;	/* irgendein special file */
			}
		}
	return(E_OK);
}


/*********************************************************************
*
* Bereitet das Lîschen/Kopieren/Verschieben vor.
*
*  function == 'D' 	: lîschen
*  function == 'C' 	: kopieren
*  function == 'A' 	: Alias erstellen
*  function == 'M' 	: verschieben
*
*	RÅckgabe:
*
*		n_dat:			Anzahl Dateien
*		n_ord:			Anzahl Ordner
*		size_used_src:		aktuell belegter Speicher
*		size_used_dst:		soviel brÑuchte eine Kopie
*		free_dst:			soviel ist auf Zielpfad frei
*
*********************************************************************/

long prepare_action(int function,
				int cmode,
				int checkfree_flag,
				long *n_dat, long *n_ord,
				long *size_used_src, long *cl_used_dst,
				long *size_netto_src,
				long *cl_free_dst,
				long *clsize_dst,
				int argc, char *argv[],
				char *dest_path)
{
	long clusters,folders,dummy,nfiles,hfiles;
	long flen,err;
	char path[MAX_PATHLEN+2];



	/* Nur Speicherplatz prÅfen, wenn gewÅnscht */

	copy_mode = cmode;
	*n_dat = *n_ord = *size_used_src = *cl_used_dst = 0L;
	cluster_size_dst = 0L;
	size_src = netto_size_src = 0L;
	if	(dest_path && checkfree_flag)
		{
		err = pathinfo(dest_path,
					cl_free_dst,
					&cluster_size_dst);
		}

	_zielpath = dest_path;
	_move_flag = (function == 'M');

	n_clu_dst = 0L;
	for	(;argc > 0; argc--,argv++)
		{
/*
Cconws("arg = \"");
Cconws(*argv);
Cconws("\"\r\n");
*/
		strcpy(path, *argv);
		argc--;
		if	(!argc)
			continue;			/* Fehler !!! */
		argv++;
		flen = atol(*argv);
		err_file = path;

		/* Unbekannte Objekte auflîsen */
		/* --------------------------- */

		err = resolve_unknown_ftypes(path, &flen);
		if	(err)
			return(err_alert(err));

		if	((function == 'A') && (flen == -3))
			flen = 0;			/* Aliase auch von Devices */

		/* Special files nur lîschen, nicht kopieren/verschieben */

		if	((flen == -3) && (function != 'D'))	/* special file */
			continue;				/* ignorieren */

		if	(flen == -2)			/* Symlink */
			{
			(*n_dat)++;
			n_clu_dst++;
			size_src += 1024;
			netto_size_src += 1024;
			}
		else
		if	(flen == -1)
			{	/* Ordner */
			if	(path[3])		/* Ordner */
				{
				(*n_ord)++;
				size_src += 1024;
				netto_size_src += 1024;
				}
			else
			if	(function == 'A')
				(*n_ord)++;	/* Alias auf root wie Subdir */
				
			if	(function == 'A')
				n_clu_dst++;
			else	{
				err = walk_path(path, &dummy, &dummy,
							&folders,
							 &nfiles, &hfiles,
							 0L, 0L);
				*n_dat += nfiles+hfiles;
				*n_ord += folders;
				}
			}

		else	{	/* Datei */
			(*n_dat)++;
			size_src += ((flen+1023L) & 0xfffffc00L);
			netto_size_src += flen;
			if	(cluster_size_dst)
				{
				if	(function == 'A')
					n_clu_dst++;
				else	{
					clusters = flen / cluster_size_dst;
					if	(flen % cluster_size_dst)
						clusters++;
					n_clu_dst += clusters;
					}
				}
			}

		}
	*size_used_src = size_src;
	*size_netto_src = netto_size_src;

	*cl_used_dst = n_clu_dst;
	*clsize_dst = cluster_size_dst;
	return(E_OK);
}


/*********************************************************************
*
* Lîscht eine Datei oder einen Ordner
* "after"- Funktion bei "Datei lîschen" fÅr walk_path
*
*********************************************************************/

static long after_delete(char *path, char *fname, XATTR *xa)
{
	long doserr;


	if	(((xa->mode) & S_IFMT) == S_IFDIR)
		{
		doserr = GDdelete(path, fname);
		down_cnt(1, NULL, NULL, 1024L);
		}
	else	{
		doserr = test_readonly(path, fname, xa);
		if	(doserr > E_OK)
			doserr = GFdelete(path, fname);
		down_cnt(0, NULL, NULL, xa->size);
		}
	return(doserr);
}


/*********************************************************************
*
* Lîscht alle Dateien auf <path>.
* gibt Anzahl gelîschter Dateien zurÅck, < 0 bei Fehler
*
*********************************************************************/

static long _delete(char *path, int ispath, long flen)
{
	long dummy,doserr;
	char *endp = path + strlen(path);

	if	(ispath)
		{
		doserr = walk_path(path, &dummy, &dummy, &dummy,&dummy,
					 &dummy, 0L, after_delete);
		if	(doserr || !path[3])
			return(doserr);
		endp[-1] = EOS;
		if	(qbreak())
			return(EBREAK);
		doserr = GDdelete(path, NULL);
		down_cnt(1, NULL, NULL, 1024L);
		}
	else {
		if	(qbreak())
			return(EBREAK);
		doserr = GFdelete(path, NULL);
		down_cnt(0, NULL, NULL, flen);
		}
	return(doserr);
}


/*********************************************************************
*
* Kopiert/Verschiebt eine Datei oder einen Ordner oder
* einen Symlink.
* (Bei Rekursion VOR Eintritt in einen Ordner aufrufen!)
*
*********************************************************************/

static long before_cpmv(char *path, char *fname, XATTR *xa)
{
	long doserr;
	char all[MAX_PATHLEN+2];
	char new_name[MAX_PATHLEN+2];
	char old_mode_ovwr;
	int ret;


	if	(qbreak())
		return(EBREAK);

	/* Verzeichnis */
	/* ----------- */

	if	(((xa->mode) & S_IFMT) == S_IFDIR)
		{
		doserr = GDcreate(_zielpath, fname);
		strcat(_zielpath, fname);
		strcat(_zielpath, "\\");
		down_cnt(1, NULL, NULL, 1024L);
		return(doserr);
		}

	/* Datei */
	/* ----- */

	strcpy(all,path);
	strcat(all,fname);

	/* Wenn eine Datei in sich selbst kopiert oder verschoben werden */
	/* soll, wird die Sicherheitsabfrage automatisch eingeschaltet	*/
	/* ------------------------------------------------------------- */

	old_mode_ovwr = copy_mode;
	if	(!strcmp(path, _zielpath))
		copy_mode = CONFIRM;

	/* Im Modus "umbenennen" hier schon neuer Name */
	/* ------------------------------------------- */

	strcpy(new_name, fname);		/* Name per Default unverÑndert */
	if	(copy_mode == RENAME)
		{
		ret = dial_datexi(_zielpath, new_name,
				((xa->mode & S_IFMT) == S_IFLNK) ?
						ALIAS : ORDINARYFILE, TRUE);
		if	(ret == 0)		/* öberspringen */
			return(E_OK);
		if	(ret < 0)			/* Abbruch */
			return(EBREAK);
		}

	/* Jetzt geht es los */
	/* ----------------- */

	if	(_move_flag)
		{
		/* erstmal zu verschieben versuchen */
		doserr = GFrename(path, fname, new_name, xa, _zielpath);
		/* wenn das nicht geht, kopieren und Original lîschen */
		if	(doserr == ENSAME)
			{
			doserr = GFcopy(path, fname, new_name,
							xa, _zielpath);
			if	(!doserr)
				{
				doserr = Fdelete(all);

#if DEBUG
errcommand = "Fdelete";
#endif

				set_dirty(doserr, all, 1);
				err_file = all;
				if	(doserr);
					err_alert(doserr);
				}
			}
		}
	else {
		doserr = GFcopy  (path, fname, new_name, xa, _zielpath);
		}

	if	(doserr == ESKIP)
		doserr = E_OK;	/* Åberspringen */
	copy_mode = old_mode_ovwr;
	if	(!doserr)
		down_cnt(0, NULL, NULL, 0L);
	return(doserr);
}


/*********************************************************************
*
* Geht im Zielpfad um eine Position in Richtung Root.
* Bei "Verschieben" wird der Ordner gelîscht.
* (Bei Rekursion NACH Eintritt und wieder Austritt aus einem Ordner
* aufrufen!)
*
*********************************************************************/

static long after_cpmv(char *path, char *fname, XATTR *xa)
{
	long doserr;
	register char *endp = path + strlen(path);


	if	(qbreak())
		return(EBREAK);
	if	(((xa->mode) & S_IFMT) != S_IFDIR)
		return(E_OK);
	if	(_move_flag)
		doserr = GDdelete(path, fname);
	else doserr = E_OK;

	endp = _zielpath + strlen(_zielpath);
	*(--endp) = EOS;
	endp = strrchr(_zielpath, '\\');
	*(++endp) = EOS;		/* Ordner entfernen */
	return(doserr);
}


/*********************************************************************
*
* Kopiert/Verschiebt alle Dateien von <quell> nach <ziel>.
*
*********************************************************************/

static long _copy_move(char *quell, char *ziel, int move_flag, int ispath)
{
	long dummy,doserr;
	char *endp = quell + strlen(quell);
	char *lastb;
	char *zendp = ziel + strlen(ziel);
	char	newname[MAX_NAMELEN+2];
	char *name;
	XATTR xa;
	char c;


	_move_flag = move_flag;
	_zielpath = ziel;


	/* 1. Fall: Pfad, also Ordner oder Root */
	/* ------------------------------------ */

	if	(ispath)
		{
		if	(ziel == strstr(ziel, quell))
			{
			Rform_alert(1, ALRT_INVAL_COPY, NULL);
			return(E_OK);
			}
		endp[-1] = EOS;		/* letzten '\' entfernen */
		if	(quell[3])
			{
			name = strrchr(quell, '\\') + 1;	/* Name des Ordners */
			strcpy(newname, name);		/* merken */
			}

		/* 1.1 Fall: Ordner auf demselben Laufwerk verschieben */
		/* --------------------------------------------------- */

		if	(quell[3] && move_flag)		/* nicht root */
			{
			doserr = Fxattr(1, quell, &xa);	/* keine Aliase auflîsen */

#if DEBUG
errcommand = "Fxattr";
#endif

			if	(!doserr)
				{
				c = *name;
				*name = EOS;
				doserr = GFrename(quell, newname, newname,
									&xa, _zielpath);
				*name = c;
				}
			if	(!doserr)
				{
				down_cnt(1, NULL, NULL, xa.size);
				move_flag = FALSE;	/* kein Ddelete() */
				}
			else	{
				if	((doserr == EBADRQ) || (doserr == EACCDN))
					doserr = ENSAME;
				}
			}
		else	doserr = ENSAME;

		/* 1.2 Fall: Ordner, also Ordner auf Zielpfad erstellen */
		/* ---------------------------------------------------- */

		if	(doserr == ENSAME)
			{
			if	(quell[3])
				{
				doserr = GDcreate(ziel, newname);
				if	(doserr)
					return(doserr);
				down_cnt(1, NULL, NULL, 1024L);
				strcat(ziel, newname);
				strcat(ziel, "\\");
				}
			endp[-1] = '\\';		/* letzten '\' restaurieren */
			doserr = walk_path(quell, &dummy, &dummy, &dummy, &dummy,
						 &dummy, before_cpmv, after_cpmv);
			endp[-1] = EOS;		/* letzten '\' entfernen */
			}

		if	(doserr || !quell[3])
			{
			*zendp = EOS;
			return(doserr);
			}
		if	(move_flag)
			doserr = GDdelete(quell, NULL);
		}

	/* 2. Fall: Nur eine Datei */
	/* ----------------------- */

	else {
		doserr = Fxattr(1, quell, &xa);

#if DEBUG
errcommand = "Fxattr";
#endif

		if	(doserr != E_OK)
			return(err_alert(doserr));
		lastb = strrchr(quell, '\\') + 1;
		strcpy(newname, lastb);	/* Dateiname extrahieren */
		*lastb = EOS;			/* Pfad abtrennen */
		doserr = before_cpmv(quell, newname, &xa);
		}

	*zendp = EOS;
	return(doserr);
}


/*********************************************************************
*
* Kopiert/Verschiebt alle Dateien von <argv[]> nach <dest_path>.
*
*********************************************************************/

long copy_move(int move_flag,
			int cmode,
			int argc, char *argv[],
			char *dest_path)
{
	char srcpath[MAX_PATHLEN+2];
	char dstpath[MAX_PATHLEN+2];
	long err,flen;
	int drv;


	/* Laufwerk bestimmen wg. nur 32k Puffer fÅr Floppies */

	drv = dest_path[0] - 'A';
	if	((drv == ('U'-'A')) && (dest_path[4] == '\\'))
		drv = dest_path[3]-'A';

	err = (long) Malloc(-1);
	if	(err < 65536L)			/* mind. 32k Puffer */
		return(ENSMEM);
	bsize = err - 32768L;		/* 32 k frei lassen */
	if	(bsize > 262144L)
		bsize = 262144L;		/* Pufferspeicher max. 256k */
	if	((drv == 0) || (drv == 1))
		bsize = FLP_BSIZE;
	if	(NULL == (copy_buffer = Malloc(bsize)))
		return(ENSMEM);

	copy_mode = cmode;
	for	(;argc > 0; argc-=2,argv++)
		{
		strcpy(srcpath, *argv);
		argv++;
		flen = atol(*argv);
		strcpy(dstpath, dest_path);
		err = resolve_unknown_ftypes(srcpath, &flen);
		if	(err)
			return(err_alert(err));
		else err = _copy_move(srcpath, dstpath, move_flag, flen == -1);
		if	(err == EBREAK)
			break;
		}

	Mfree(copy_buffer);
	return(E_OK);
}


/*********************************************************************
*
* Erstellt Aliase fÅr alle Dateien von <argv[]> nach <dest_path>.
*
*********************************************************************/

long create_aliases(int cmode, int argc, char *argv[],
			char *dest_path)
{
	char path[MAX_PATHLEN+2];
	long err,flen;
	char name[MAX_NAMELEN+2];
	char *lastc;


	copy_mode = cmode;
	if	((copy_mode != CONFIRM) && (copy_mode != RENAME))
		copy_mode = CONFIRM;
	for	(;argc > 0; argc-=2,argv++)
		{
		if	(qbreak())
			return(EBREAK);
		strcpy(path, *argv);
		argv++;
		flen = atol(*argv);
		err = resolve_unknown_ftypes(path, &flen);
		if	(err)
			return(err_alert(err));

		if	(flen != -1)
			{	/* Datei, d.h. kein Ordner */
			strcpy(name, get_name(path));
			}
		else	{
			if	(!path[3])	/* X:\ */
				{
				name[0] = path[0];
				name[1] = EOS;
				}
			else	{
				lastc = path+strlen(path)-1;
				*lastc = EOS;
				strcpy(name, get_name(path));
				*lastc = '\\';
				}
			}
		err = GFsymlink(path, dest_path, name, NULL);
		if	(err == EBREAK)
			break;
		}
	err_file = NULL;
	return(E_OK);
}


/*********************************************************************
*
* Lîscht alle Dateien von <argv[]>.
*
*********************************************************************/

long delete(int argc, char *argv[])
{
	char path[MAX_PATHLEN+2];
	long err,flen;


	copy_mode = -1;		/* ungÅltig */
	for	(;argc > 0; argc-=2,argv++)
		{
		if	(qbreak())
			return(EBREAK);
		strcpy(path, *argv);
		argv++;
		flen = atol(*argv);
		err = resolve_unknown_ftypes(path, &flen);
		if	(err)
			return(err_alert(err));
		err = _delete(path, flen == -1, flen);
		if	(err == EBREAK)
			break;
		}
	return(E_OK);
}


/*********************************************************************
*
* Unser Thread.
*
*********************************************************************/

LONG cdecl action_thread( ACTIONPARAMETER *par )
{
	WORD myglobal[15];
	long err;

	/* wir braten das global-Feld der Haupt-APPL nicht Åber */

     if   (MT_appl_init(myglobal) < 0)
          Pterm(-1);

	copy_mode = par->mode;
	switch(par->action)
		{
	 case 'A':
	 	err = create_aliases(copy_mode,
	 						par->argc,
	 						par->argv,
	 						par->dstpath);
	 	break;
	 case 'C':
	 	err = copy_move(FALSE,copy_mode,
	 						par->argc,
	 						par->argv,
	 						par->dstpath);
	 	break;
	 case 'M':
	 	err = copy_move(TRUE,copy_mode,
	 						par->argc,
	 						par->argv,
	 						par->dstpath);
	 	break;
	 case 'D':
	 	err = delete(par->argc,par->argv);
	 	break;
	 	}
	 return(err);
}
