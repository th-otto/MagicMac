/*
*
* Dieses Modul enthÑlt die Routinen zum rekursiven
* Kopieren von Ordnern.
*
*/

#include <string.h>
#include <tos.h>
#include <aes.h>
#include <toserror.h>
#include "country.h"
#include <stdio.h>
#include "xcopy.h"

extern void redraw_dialog( void );

static char dstpath[256];
static char srcpath[256];
static char *_zielpath;

#define NPRESERVE 5

static char *preserve[] = {
	"CHGRES.PRG",
	"CHGRES.RSC",
	"APPLICAT.DAT",
	"APPLICAT.INF",
	"SHUTDOWN.INF"
	};

long MFcreate( char *name )
{
	char *fname;
     long doserr;
     int i;
     char s[200];


	fname = strrchr(name, '\\') + 1;		/* reiner Dateiname */
	for	(i = 0; i < NPRESERVE; i++)
		{
		if	(!strcmp(fname, preserve[i]))
			{
	          doserr = Fattrib(name, 0, 0);
	          if	(doserr >= 0L)
				return(E_OK);			/* Åberspringen!!! */
			}
		}

	callback(writing, name);
#if 0
     if   (!global)
          {
          doserr = Fattrib(name, 0, 0);
          if   (doserr >= 0L)
               {
#if		COUNTRY==COUNTRY_DE
               strcpy(s, "[2][Datei existiert schon:|");
               strcat(s, name);
               strcat(s,"][Weiter|Abbruch]");
#elif	COUNTRY==COUNTRY_US
               strcpy(s, "[2][File already exists:|");
               strcat(s, name);
               strcat(s,"][Continue|Abort]");
#endif
               if   (2 == form_alert(2, s))
                    return(EBREAK);
               global = 1;
               }
          }
#endif
     doserr = Fcreate(name, 0);
     if   (doserr < 0L)
          {
          sprintf(s, err_creating, name);
          form_alert(1, s);
          }
     return(doserr);
}


/*********************************************************************
*
* Kopiert eine Datei <qpath> nach <zpath>.
* éndert nicht mehr die DTA.
*
*********************************************************************/

long GFcopy(char *path, char *name, char *dstpath)
{
     DTA  mydta;
     DTA  *olddta;
     long doserr;
     int  shdl,dhdl;
     long bsize,lbytes;
     char *buf;
     char qpath[128];
     char zpath[128];
     char *s;



	strcpy(qpath, path);
	strcat(qpath, name);

	strcpy(zpath, dstpath);
	strcat(zpath, name);

	olddta = Fgetdta();
	Fsetdta(&mydta);
	doserr = Fsfirst(qpath, 0);
	if   (doserr < 0L)
		{
		Fsetdta(olddta);
          return(doserr);
          }

     /* Speicher holen, Quellpfad zusammenstellen */
     /* ----------------------------------------- */

     bsize = (long) Malloc(-1L) - 4096L;
     if   (bsize < 4096L || (NULL == (buf = Malloc(bsize))))
		{
		Fsetdta(olddta);
          return(ENSMEM);
          }

     dhdl = shdl = -1;             /* Dateien sind noch nicht geîffnet */

     /* Kopierschleife */
     /* -------------- */

     do   {

          /* Ansonsten die Quelldatei gelesen und ggf. geîffnet */
          /* -------------------------------------------------  */

          if   (shdl < 0)
               {
			callback(reading, qpath);
               doserr = Fopen(qpath, O_RDONLY);
               if   (((int) doserr) == -4)   /* NUL: */
                    doserr = EACCDN;
               if   (doserr < E_OK)
                    goto source_error;
               shdl = (int) doserr;
               }
		callback(reading, qpath);
          doserr = Fread(shdl, bsize, buf);
          if   (doserr < E_OK)
               {
               source_error:
               break;              /* Fehler beim Lesen */
               }
          if   (doserr >= E_OK && doserr < bsize)
               {
               Fclose(shdl);
               shdl = -2;               /* Flag fÅr das Ende */
               }
          lbytes = doserr;              /* soviele Bytes sind gelesen */

          /* Die Zieldatei wird geîffnet */
          /* --------------------------- */

          if   (dhdl < 0)
               {
               doserr = MFcreate(zpath);
               if   (doserr <= E_OK)    /* < 0: Fehler oder Abbruch */
                    break;              /* = 0: öberspringen        */
               dhdl = (int) doserr;
               }

          /* <lbytes> gelesene Bytes werden geschrieben */
          /* ------------------------------------------ */

          if   (lbytes)
               {
			callback(writing, zpath);
               doserr = Fwrite(dhdl, lbytes, buf);
               if   (doserr >= 0L && doserr < lbytes)
                    {
                    form_alert(1, diskfull);
                    doserr = -1L;
                    }
               }
          }
     while(shdl != -2 && doserr >= E_OK);

     if   (doserr > E_OK)
          doserr = E_OK;
     if   (shdl > 0)
          Fclose(shdl);
     if   (dhdl > 0)
          {
          Fdatime((DOSTIME *) &(mydta.d_time), dhdl, 1);
          Fclose(dhdl);
          }
     if   (dhdl > 0 && doserr != E_OK && doserr != EWRPRO && doserr != EDRVNR)
          Fdelete(zpath);

	Mfree(buf);
	Fsetdta(olddta);

	/* Sonderbehandlung fÅr .SFX Dateien */
	/* --------------------------------- */

	if	(!doserr)
		{
		s = strrchr(zpath, '.');
		if	((s) && (!strcmp(s, ".SFX")))
			{
		     int olddrv;
		     char oldpath[256];


			olddrv = Dgetdrv();
			Dgetpath(oldpath, 0);
			Dsetdrv(dstpath[0] - 'A');
			Dsetpath(dstpath);
			doserr = Pexec(0, zpath, "", NULL);
	/*		redraw_dialog();	*/

			if	(!doserr)
				Fdelete(zpath);

			Dsetdrv(olddrv);
			Dsetpath(oldpath);
			}
		}

	return(doserr);
}


/*********************************************************************
*
* Erstellt einen Ordner <name> in <path>.
*
*********************************************************************/

long GDcreate(char *path, char *name)
{
	char	all[128];
	long doserr;
	char s[200];


	strcpy(all, path);
	strcat(all, name);
	callback(crfolder, all);
	doserr = Dcreate(all);
     if   (doserr < 0L && doserr != EACCDN)
          {
          sprintf(s, err_creating, name);
          form_alert(1, s);
          return(ERROR);
          }
	return(E_OK);
}


/*********************************************************************
*
* Kopiert/Verschiebt eine Datei oder einen Ordner.
* (Bei Rekursion VOR Eintritt in einen Ordner aufrufen!)
*
*********************************************************************/

static long before_cpmv(char *path, DTA *file)
{
	long doserr;
	char all[128];


	if	((file->d_attrib) & FA_SUBDIR)
		{
		doserr = GDcreate(_zielpath, file->d_fname);
		strcat(_zielpath, file->d_fname);
		strcat(_zielpath, "\\");
		return(doserr);
		}
	strcpy(all,path);
	strcat(all,file->d_fname);

	/* Wenn eine Datei in sich selbst kopiert oder verschoben werden */
	/* soll, wird die Sicherheitsabfrage automatisch eingeschaltet	*/
	/* ------------------------------------------------------------- */

	doserr = GFcopy  (path, file->d_fname, _zielpath);
	if	(doserr)
		return(doserr);
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

static long after_cpmv(char *path, DTA *file)
{
	long doserr;
	register char *endp = path + strlen(path);


	if	(!(file->d_attrib & FA_SUBDIR))
		return(E_OK);
	doserr = E_OK;

	endp = _zielpath + strlen(_zielpath);
	*(--endp) = EOS;
	endp = strrchr(_zielpath, '\\');
	*(++endp) = EOS;		/* Ordner entfernen */
	return(doserr);
}


/*********************************************************************
*
* DurchlÑuft einen Pfad und fÅhrt bei jeder gefundenen Datei
* vorher ein Programm <before>, hinterher <after> aus.
* Sind <before> und <after> == NULL, werden nur Informationen gesammelt.
* gibt ggf. DOS- Fehlercode zurÅck.
*
*********************************************************************/

static long (*_before)(char *path, DTA *file);
static long (*_after) (char *path, DTA *file);
static int  depth;
static char *_path;
static char *_mask;


static long _walk_path( void )
{
	DTA	dta;
	long errcode;
	char *endp;


	errcode = strlen(_path);
	endp = _path + errcode;
	depth++;
	if	(depth > 8 || errcode > 116)
		return(ERROR);
	Fsetdta(&dta);
	strcpy(endp, "*.*");
	errcode = Fsfirst(_path, 0x17);	/* keine Volumes! */
	while(errcode == E_OK)
		{
		if	(dta.d_fname[0] == '.')
			{
			if	(dta.d_fname[1] == '.' || dta.d_fname[1] == EOS)
				goto next;
			}

		if	(_before != NULL)
			{
			*endp = EOS;
			if	(E_OK != (errcode = _before(_path, &dta)))
				return(errcode);
			}

		if	(dta.d_attrib & FA_SUBDIR)
			{
			strcpy(endp, dta.d_fname);
			strcat(endp, "\\");
			errcode = _walk_path();	/* REKURSION */
			*endp = EOS;
			if	(errcode)
				return(errcode);
			}

		if	(errcode == E_OK && _after != NULL)
			{
			*endp = EOS;
			if	(E_OK != (errcode = _after(_path, &dta)))
				return(errcode);
			}			/* "User break" */

		next:
		if	(errcode == E_OK)
			{
			Fsetdta(&dta);
			errcode = Fsnext();
			}
		} /* ENDWHILE */
	depth--;
	if	(errcode == EFILNF || errcode == ENMFIL)
		errcode = E_OK;
	return(errcode);
}

static long walk_path(char *path,
			long (*before)(char *path, DTA *file),
			long (*after) (char *path, DTA *file))
{
	long errcode;


	depth = 0;
	_before	= before;
	_after	= after;
	_path = path;
	_mask = "*.*";
	errcode = _walk_path();
	return(errcode);
}


/******************************************************************************
*
* Kopiert ein Verzeichnis rekursiv.
*
******************************************************************************/

long copy_subdir( char *src, char *dst )
{
	long errcode;

	strcpy(dstpath, dst);
	_zielpath = dstpath;
	strcpy(srcpath, src);
	errcode = walk_path(srcpath, before_cpmv, after_cpmv);
	return(errcode);
}
