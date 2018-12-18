/****************************************************************
*
* FORMAT
* ======
*
* Beginn der Programmierung:  01.08.93    (vorher: MAGXDESK)
* letzte énderung:			01.10.95
*
* Modul zum Formatieren und Kopieren von Disketten.
* Dieses Programm arbeitet nicht interaktiv, sondern quasi als
* Thread fÅr MGFORMAT.
*
* Kommandozeile: bisher keine
*
* Nachrichten:
*    Die Nachrichten haben alle das 8-Wort-Format:
*         Wort 0: Code
*              1: ID des Absenders
*              2: öberlÑnge (immer 0)
*              3,4,5,6,7: Nachricht
*
*    MGFORMAT -> FORMAT
*         Code 1031: Formatieren/Kopieren abbrechen
*         Code 1032: Programm beenden
*
*    FORMAT -> MGFORMAT
*         Code 1040: öbertragen von Statusmeldungen
*			Wort 3:		Fensterhandle des Dialogs
*              Wort 4:        formatierte Spurnummer
*			Wort 5:		action (0=les/1=schr/2=fmt)
*			Wort 6:		0
*				Diese Nachricht wird ab 1.10.95 mit Hilfe
*				einer XAES-Message verschickt und ggf.
*				vom AES verschmolzen, um einen öberlauf
*				des Nachrichtenpuffers der Zielapplikation
*				zu vermeiden.
*         Code 1043: öbertragen von Statusmeldungen (Kopieren)
*			Wort 3:		Fensterhandle des Dialogs
*              Wort 4:        Anzahl Seiten
*			Wort 5:		Anzahl Spuren
*			Wort 6:		Anzahl Sektoren pro Spur
*         Code 1041: "Formatieren beendet"
*			Wort 3:		Fensterhandle des Dialogs
*              Wort 4:        doserr
*         Code 1042: "Formatieren abgebrochen"
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include "toserror.h"
#include "mgformat.h"
#include "gemut_mt.h"
#include "globals.h"


#define DEBUG 		0

#if DEBUG
#include <stdio.h>
#endif

#define MIN(a,b) ((a < b) ? a : b)



static int  ap_id;


long format( int dst_apid, int whdl, int dev, int is_logic,
               unsigned sid, unsigned trk, unsigned spt, unsigned clu,
            int inter, int vtrk, int vsid, char *dname);
long diskcopy(int dst_apid, int whdl, int slw, int dlw, int tmp, int fmt);


LONG cdecl format_thread( struct fmt_parameter *par )
{
	WORD myglobal[15];

	/* wir braten das global-Feld der Haupt-APPL nicht Åber */

     if   ((ap_id = mt_appl_init(myglobal)) < 0)
          Pterm(-1);

    	if	(par->action == action_format)	/* Formatieren */
    		{
		format(
			par->apid,
			par->whdl,
			par->device,
			par->do_logical,
			prefs.sides,
			prefs.tracks,
			prefs.sectors,
			prefs.clustsize,
			prefs.interlv,
			prefs.trkincr,
			prefs.sidincr,
			par->diskname);
		}
	else	{				/* Kopieren */
		diskcopy(
			par->apid,
			par->whdl,
			par->src_dev,
			par->dst_dev,
			prefs.tmpdrv,
			par->do_format);
		}

	appl_exit();
     return(0);
}


/*********************************************************************
*
* Fragt, ob abgebrochen werden soll.
*
*********************************************************************/

int qbreak( void )
{
     if   ((Kbshift(-1) & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT))
          {
          if   (1 == Rform_alert(1, AL_ASK_BREAK, global))
               return(TRUE);
          }
     return(FALSE);
}


/*********************************************************************
*
* Ermittelt den Disknamen von Laufwerk <lw>.
*
*********************************************************************/

long read_dname(int lw, char *name)
{
     DTA dta;
     DTA *olddta;
     char path[10];
     long doserr;

     olddta = Fgetdta();
     Fsetdta(&dta);
     path[0] = letter_from_drive(lw);
     strcpy(path+1, ":\\*.*");
     doserr = Fsfirst(path, FA_VOLUME);
     if   (doserr != E_OK)
          *name = EOS;
     else strcpy(name, dta.d_fname);
     Fsetdta(olddta);
     return(doserr);
}


/*********************************************************************
*
* Sperrt ein Laufwerk fÅrs Formatieren/Kopieren
* Es wird die MiNT- Funktion Dlock verwendet, um ein Laufwerk fÅr
* DOS- Aufrufe zu sperren.
*
* RÅckgabe:	0	OK
*			1	Fehler
*
*********************************************************************/

int lock_drive( int dev )
{
	long ret;
	char *procname = "U:\\PROC\\*.xxx";
     DTA dta;
     DTA *olddta;


	if	(E_OK == (ret = Dlock(3, dev)))		/* Sperren, pid zurÅckgeben */
		return(0);				/* OK */
	if	(ret == EINVFN)
		{
          Rform_alert(1, AL_OLD_OSVERSION, global);
		return(1);
		}
	if	(ret == EACCDN)
		{
          Rform_alert(1, AL_DISK_IN_USE, global);
		return(1);
		}
	if	((ret < 0) || (ret > 999))
		{
		unknown:
          Rform_alert(1, AL_DSKNOTLOCKABL, global);
		return(1);
		}

	procname[10] = ret / 100 + '0';
	ret %= 100;
	procname[11] = ret / 10 + '0';
	procname[12] = ret % 10 + '0';
	olddta = Fgetdta();
     Fsetdta(&dta);
	ret = Fsfirst(procname, 0);
	if	(ret)
		goto unknown;
	Rxform_alert(1, AL_DSK_LOCKED_BY, 0, dta.d_fname, global);
     Fsetdta(olddta);
     return(1);
}


/*********************************************************************
*
* Gibt ein Laufwerk wieder frei
* Es wird die MiNT- Funktion Dlock verwendet
*
*********************************************************************/

void send_wdraw( int dev )
{
	int msg[8] = {SH_WDRAW, 0, 0};

	msg[1] = ap_id;
	msg[3] = dev;
	appl_write(0, 16, msg);	/* App #0 ist die Shell (?) */
}


/*********************************************************************
*
* Eine Art "etv_critic" fÅr Xbios- Funktionen.
*
* Folgende Mîglichkeiten hat man:
*
* Abbruch:     RÅckgabe 0, doserr wird nicht verÑndert
* Wiederholen: RÅckgabe 1, doserr wird nicht verÑndert
* Ignorieren:  RÅckgabe 0, doserr wird auf E_OK gesetzt
*
*********************************************************************/

int tryagain(long *doserr, int drv)
{
     int ret;
     char *s;


     s = (((DOSVARS *) Sconfig(SC_DOSVARS, 0L))->err_to_str)((char) (*doserr));
     ret = Rxform_alert(2, AL_CAN_RETR_CONT, letter_from_drive(drv), s, global);
     if   (ret == 1)          /* Abbruch */
          return(0);
     if   (ret == 2)          /* Wiederholen */
          return(1);
     *doserr = E_OK;          /* Ignorieren */
     return(0);
}

long M_Flopfmt( void *buf, void *filler, int devno, int spt, int trackno,
                int sideno, int interlv, int virgin )
{
     long doserr;

     do   {
          doserr = Flopfmt(buf, filler, devno, spt, trackno, sideno,
                           interlv, 0x87654321L, virgin);
          }
     while(doserr != E_OK && tryagain(&doserr, devno));
     return(doserr);
}

long M_Flopwr(void *buf, void *filler, int devno, int sectno, int trackno,
              int sideno, int count)
{
     long doserr;

     do   {
          doserr = Flopwr(buf, filler, devno, sectno, trackno, sideno, count);
          }
     while(doserr != E_OK && tryagain(&doserr, devno));
     return(doserr);
}

long M_Floprd (void *buf, void *filler, int devno, int sectno, int trackno,
              int sideno, int count)
{
     long doserr;

     do   {
          doserr = Floprd(buf, filler, devno, sectno, trackno, sideno, count);
          }
     while(doserr != E_OK && tryagain(&doserr, devno));
     return(doserr);
}


/*********************************************************************
*
* RÅckmeldung. Bei Empfang einer Abbruchnachricht
*  wird EBREAK zurÅckgegeben
* action == 0	Lese
* action == 1  Schreibe
* action == 2	Formatiere
*
*********************************************************************/

long send_status(int whdl, int dst_apid, int msg4, int msg5, int msg6)
{
	XAESMSG xmsg;		/* MagiC !!! */
	int message[8];


	message[0] = (msg6) ? 1043 : 1040;
	message[1] = ap_id;
	message[2] = 0;
	message[3] = whdl;
	message[4] = msg4;		/* ctrack bzw. Anzahl Seiten*/
	message[5] = msg5;		/* action bzw. Anzahl Tracks*/
	message[6] = msg6;		/*		bzw. Anzahl Sektoren pro Track */
	if	(!msg6)
		{
		xmsg.dst_apid = dst_apid;
		xmsg.unique_flg = TRUE;		/* !!! */
		xmsg.attached_mem = NULL;
		xmsg.msgbuf = message;
		appl_write(-2, 16, &xmsg);
		}
	else	appl_write(dst_apid, 16, message);
	while(appl_read(-1, 16, message))
		{
		if   (message[0] == 1031)
			{
			message[0] = 1042;  /* Aktion abgebrochen */
			message[1] = ap_id;
			message[2] = 0;
			message[3] = whdl;
			appl_write(dst_apid, 16, message);
			return(EBREAK);
			}
		}
	return(0L);
}


/*********************************************************************
*
* Vollzugsmeldung.
*
*********************************************************************/

void send_finish( int whdl, int dst_apid, long doserr )
{
	int message[8];

	message[0] = 1041;  /* Formatieren beendet */
	message[1] = ap_id;
	message[2] = 0;
	message[3] = whdl;
	message[4] = (int) doserr;
	appl_write(dst_apid, 16, message);
}


/*********************************************************************
*
* Disk umbenennen.
*
*********************************************************************/

long label(int lw, char *name)
{
     static    char pfad[] = "A:\\*.*";
               long retcode;
     extern char    *tmpnam( char *s );
     char diskname[40];


     pfad[0] = letter_from_drive(lw);
     strcpy(diskname,     pfad);
     strcpy(diskname + 3, name);
     if   (!*name)
          {
          diskname[3] = '\xe5';
          diskname[4] = EOS;
          }
     retcode = Fcreate(diskname, FA_VOLUME);
     if   (retcode >= E_OK)
          retcode = Fclose((int) retcode);
     return(retcode);
}


/*********************************************************************
*
* Untersucht den Bootsektor eines Mediums.
*
*********************************************************************/

long read_bootsec(int lw, long *ser, int *bps, int *spc,
						int *res,	int *nfats, int *ndirs, int *nsects,
						int *media, int *spf, int *spt, int *nsides,
						int *nhid, int *exec)
{
	long doserr;
	unsigned char *s;
	unsigned int  *sw;


	if	(NULL == (s = Malloc(512L)))
		return(ENSMEM);
	if	(lw == 0 || lw == 1)
		doserr = M_Floprd(s, NULL, lw, 1, 0, 0, 1);
	else doserr = Rwabs(0, s, 1, 0, lw);
	if	(doserr == E_OK)
		{
		*ser    = s[10] + 256 * s[ 9] + 65536L * s[8];
		*bps    = s[11] + 256 * s[12];
		*spc    = s[13];
		*res    = s[14] + 256 * s[15];
		*nfats  = s[16];
		*ndirs  = s[17] + 256 * s[18];
		*nsects = s[19] + 256 * s[20];
		*media  = s[21];
		*spf	   = s[22] + 256 * s[23];
		*spt	   = s[24] + 256 * s[25];
		*nsides = s[26] + 256 * s[27];
		*nhid   = s[28] + 256 * s[29];
		*exec   = 0;
		for	(sw = (unsigned int *) s; (unsigned char *) sw < s+512; sw++)
			*exec += *sw;
		*exec = (*exec == 0x1234);
		}
	Mfree(s);
	return(doserr);
}


/*********************************************************************
*
* Initialisiert ein Laufwerk
* Das Laufwerk muû bereits ge-lock-t sein.
*
*********************************************************************/

static long init_disk(int dev)
{
     long doserr,buflen,fsizb,rsizb;
     long label(int lw, char *name);
     BPB  *bpb;
     char *buf;


     bpb = Getbpb(dev);
     if   (!bpb)
     	{
          doserr = EMEDIA;
          goto err;
          }
     fsizb = ((long) bpb->fsiz) * ((long) bpb->recsiz);
     rsizb = ((long) bpb->rdlen) * ((long) bpb->recsiz);
     buflen = fsizb+fsizb+rsizb;
     buf = Malloc(buflen);
     if   (!buf)
     	{
          doserr = ENSMEM;
          goto err;
          }
     memset(buf, 0, buflen);

     buf[0] = buf[fsizb] = (dev > 1) ? 0xf8 : 0xf9;         /* Mediabyte */
     buf[1] = buf[2] = buf[fsizb+1] = buf[fsizb+2] = 0xff;
     if   (bpb->bflags & 1)                                 /* 16bit FAT */
          buf[3] = buf[fsizb+3] = 0xff;

     /* FATs und Root lîschen */
     /* --------------------- */

/*	free_drive(dev);	*/
     doserr = Rwabs(1, buf, 2*bpb->fsiz + bpb->rdlen, 1, dev);

     Mfree(buf);
     err:
     return(doserr);
}


/*********************************************************************
*
* Formatiert eine Diskette
*
* whdl	- Fensterhandle fÅr RÅckmeldungsnachrichten
* dev     - Devicenummer (0 = A, 1 = B)
* sid     - Anzahl Seiten (1 oder 2)
* trk     - Anzahl Tracks (40..86)
* spt     - Anzahl Sektoren/Track (9,10)
* clu     - Anzahl Sektoren/Cluster (2,4,8)
* inter   - Interleave
* vtrk    - Spurversatz
* vsid    - Seitenversatz
* counter - Zeiger auf eine Funktion, die den gerade formatierten Track
*            anzeigt
* is_logic- nur logisch formatieren, d.h. FAT und DIR lîschen
* dname   - Diskname oder Platz fÅr einen solchen
*
*********************************************************************/

long format(int dst_apid, int whdl, int dev, int is_logic,
               unsigned sid, unsigned trk, unsigned spt, unsigned clu,
            int inter, int vtrk, int vsid, char *dname)
{
	unsigned int nsects,spf;
	unsigned char media;
	register ctrack,cside,i,j;
	int  interlv,versatz;
	unsigned char *buf = NULL;
/*	BPB *bpb;	*/
	long doserr;
	int  secnos[100];        /* Sektornummern fÅr Versatz */


	if	((clu == 0) || (clu != 1 && clu & 1))
		{
		doserr = EMEDIA;          /* ungerade Clustergrîûe */
		goto err2;
		}

	if	(is_logic)
		{
		if	(!dname[0])
			{
			doserr = read_dname(dev, dname);
			if   (doserr != EFILNF && doserr != E_OK)
			     goto err2;
			}

		if	(lock_drive(dev))
			return(ELOCKED);

		doserr = init_disk(dev);
		goto set_dname;
		}

	if	(dev != 0 && dev != 1)
		{
		doserr = EUNCMD;
		goto err2;
		}

	/* ggf. Standardwerte eintragen */
	/* ============================ */

	vtrk  %= spt;
	vsid  %= spt;
	inter %= spt;
	if	(!inter)
		inter = 1;

	/* Erst ab TOS 1.2 kann man die Sektornummern selbst angeben */
	/* --------------------------------------------------------- */

	interlv = -1;

	/* Speicher anfordern 		*/
	/* DD: 1461 + n * 612 Bytes 	*/
	/* HD: 2921 + n * 612 Bytes 	*/
	/* ED: ?					*/
	/* -------------------------- */

	doserr = (spt / 13 + 1) * 1500L + spt * 650L;
	buf = Malloc(doserr);
	if	(!buf)
		{
		doserr = ENSMEM;
		goto err2;
		}

	/* Sektornummerliste initialisieren */
	/* -------------------------------- */

	for	(i = 0; i < spt; i++)
		secnos[i] = 0;                /* erst alle ungÅltig */

	i = 0;                             /* Beginne mit Sektor 1 */
	for  (j = 1; j <= spt; j++)        /* diese Nummern werden vergeben */
		{
		while(secnos[i])              /* schon belegt */
			{
			i++;                     /* daher einfach weiterschalten */
			i %= spt;
			}
		secnos[i] = j;                /* neue Sektornummer eintragen */
		i += inter;
		i %= spt;                     /* nÑchster Sektor */
		}

     /* Disk formatieren */
     /* ---------------- */

	if	(lock_drive(dev))
		{
		doserr = ELOCKED;
		goto err2;
		}

	for	(ctrack = trk - 1; ctrack >= 0; ctrack--)
		{
		for  (cside = sid - 1; cside >= 0; cside--)
			{
			if	(qbreak())
				{
				doserr = EBREAK;
				goto err;
				}

			doserr = M_Flopfmt(buf, secnos, dev, spt, ctrack, cside,
						interlv, 0xe5e5);

			if	(doserr != E_OK)
				goto err;

			/* Seiten- bzw. Spurversatz */

			versatz = (cside) ? vsid : vtrk;
			for  (i = 0; i < spt; i++)
				{
				if	((secnos[i] += versatz) > spt)
					secnos[i] -= spt;
				}
               }

		/* counter(ctrack); */
		/* ---------------- */

		doserr = send_status( whdl, dst_apid, ctrack, 2, 0);
		if	(doserr < 0)
			{
			Dlock(0, dev);		/* Freigeben */
			Mfree(buf);
			return(doserr);
			}
		}

	/* Bootsektor erstellen und schreiben 		*/
	/* Die Standardtypen werden nicht verwendet	*/
	/* ----------------------------------------- */

	memset(buf, 0, 512L);
	Protobt(buf, 0x01000000L, 3, FALSE);

	nsects = sid * trk * spt;          /* Anzahl Sektoren */
	media  = 0xf9;
	spf    = (nsects/clu)/341 + 1;     /* Sektoren/FAT */

	buf[0] = 0xeb;
	buf[1] = 0x3c;
	buf[2] = 0x90;
	memcpy( buf+3,
				"MSDOS", 5);
	memcpy( buf+0x2b,
				"NO NAME    FAT12   ", 19);
	memcpy( buf+0x1a0,
				"Kein System oder"
				" Laufwerksfehler"
				"\r\nWechseln und T"
				"aste drÅcken\r\n\0I"
				"O      SYSMSDOS "
				"  SYS",
				85);
	buf[20] = nsects / 256;
	buf[19] = nsects % 256;
	buf[21] = media;
	buf[13] = clu;
	buf[23] = spf / 256;
	buf[22] = spf % 256;
	buf[25] = spt / 256;
	buf[24] = spt % 256;
	buf[27] = sid / 256;
	buf[26] = sid % 256;

	Protobt(buf, -1L, -1, FALSE);      /* nicht ausfÅhrbar */
	doserr = M_Flopwr(buf, NULL, dev, 1, 0, 0, 1);
	if	(doserr)
		goto err;

	/* FATs und DIR initialisieren */
	/* --------------------------- */

	doserr = init_disk(dev);

#if 0
	Hier war vorher eine manuelle Initialisierung:

	bpb = Getbpb(dev);
	if	(bpb == NULL)
		{
		doserr = ERROR;
		goto err;
		}
	for	(i = 3; i < 512; i++)
		buf[i] = 0;
	buf[0] = 0xf9;
	buf[1] = buf[2] = 0xff;
	doserr = Rwabs(3, buf, 1, 1, dev);      /* FAT 1 */
	if	(doserr == E_OK)
		doserr = Rwabs(3, buf, 1, bpb->fsiz + 1, dev);
#endif

	err:

	/* Speicher freigeben, Diskwechsel simulieren */
	/* ------------------------------------------ */

	Rwabs(0, NULL, 2, 0, dev);

     /* Disknamen schreiben */
     /* ------------------- */

	set_dname:
	Dlock(0, dev);		/* Freigeben */
	if	(!doserr && dname[0])
		doserr = label(dev, dname);
	send_wdraw(dev);

	err2:
	if	(buf)
		Mfree(buf);
	send_finish( whdl, dst_apid, doserr );
	if	(doserr != ELOCKED)
		form_xerr(doserr, "FORMAT");
     return(doserr);
}


/*********************************************************************
*
* Fordert per Alert einen Diskwechsel an.
* RÅckgabe TRUE, wenn OK, sonst FALSE (bei Abbruch)
*
*********************************************************************/

enum eingelegt_typ { QUELLE, ZIEL } eingelegt;

int msg_chg( enum eingelegt_typ willhaben, int src_dev, int dst_dev )
{
	char	*s;


	if	((dst_dev != src_dev) || (willhaben == eingelegt))
		return(TRUE);
	s = Rgetstring((willhaben == QUELLE) ? STR_SOURCE : STR_DEST,
				global);
	eingelegt = willhaben;
	return(1 == Rxform_alert(1, AL_INSERT_DISK, letter_from_drive(src_dev),
			s, global));
}


/*********************************************************************
*
* Kopiert eine Diskette
*
* slw	- Quell- Laufwerk
* dlw	- Ziel - Laufwerk
* fmt	- Flag fÅr "Formatieren"
*
*********************************************************************/

long diskcopy(int dst_apid, int whdl, int slw, int dlw, int tmp, int fmt)
{
	int	to_finish = TRUE;
	char	tmpdatei[128];
	int	gelesen;
	int	handle = -1;
	int	secnos[100];			/* Sektornummern fÅr Versatz */
	int	interlv;
	long	doserr;
	long	ser;
	int	trk;
	int	bps,spc,res,nfats,ndirs,nsects,media,spf,spt,sid,nhid,exec;
	long bufsiz_char;			/* Puffergrîûe in Zeichen */
	unsigned long n_bytes;		/* gefÅllte Bytes */
	unsigned int  bufsiz_trk;	/* Puffergrîûe in Spuren */
	unsigned int  c_tracks;		/* gefÅllte Spuren */
	register unsigned ltrack,ctrack,cside,i;
	register unsigned char *cbuf;
	unsigned char *buf = NULL, *fbuf = NULL;




	if	(lock_drive(slw))
		{
		doserr = ELOCKED;
		goto err;
		}
	if	(lock_drive(dlw))
		{
		Dlock(0, slw);		/* Freigeben */
		doserr = ELOCKED;
		goto err;
		}
		
	eingelegt = ZIEL;			/* Quelldisk erstmal nicht eingelegt! */
	if	(!msg_chg(QUELLE, slw, dlw))	/* Quelldisk anfordern */
		goto abbruch;


	doserr = read_bootsec(slw, &ser,&bps,&spc,&res,&nfats,&ndirs,&nsects,
					   &media,&spf,&spt,&sid,&nhid,&exec);
	if	(doserr != E_OK)
		goto err;
	if	(sid <= 0 || spt <= 0 || nsects <= 0)
		{
		doserr = EMEDIA;
		goto err;
		}

	trk = nsects/(sid*spt);

	/* Wenn die Laufwerke nicht A: oder B: sind oder wenn Quell- oder */
	/* Ziellaufwerk mit dem temporÑren Laufwerk identisch sind, wird	 */
	/* eine Fehlermeldung geliefert							 */
	/* -------------------------------------------------------------- */

	if	((slw != 0 && slw != 1) || (dlw != 0 && dlw != 1))
		{
		doserr = EUNCMD;
		goto err;
		}
	if	(tmp == slw || tmp == dlw)
		tmp = -1;		/* tolerieren und einfach ignorieren */

	send_status( whdl, dst_apid, sid, trk, spt);

	interlv = -1;

	/* Wenn ein temporÑres Laufwerk angegeben wurde, Pfad erstellen	*/
	/* -------------------------------------------------------------	*/

	if	(tmp >= 0)
		{
		tmpdatei[0] = letter_from_drive(tmp);
		tmpdatei[1] = ':';
     	tmpnam(tmpdatei+2);
     	handle = -1;
		}

	/* Wenn nicht formatiert werden soll, wird das Format der		*/
	/* Zieldisk geprÅft, ob es mit dem der Quelldisk Åbereinstimmt.	*/
	/* ggf. wird trotzdem formatiert							*/
	/* ------------------------------------------------------------- */

	if	(!fmt)
		{
		long ser;
		int bps,spc,res,nfats,ndirs,nsects,media,spf,dspt,dsid,nhid,exec;
		int dtrk;

		if	(!msg_chg(ZIEL, slw, dlw))	/* Zieldisk anfordern */
			goto abbruch;

		doserr = read_bootsec(dlw, &ser,&bps,&spc,&res,&nfats,&ndirs,&nsects,
						   &media,&spf,&dspt,&dsid,&nhid,&exec);
		if	(doserr != E_OK)
			goto err;
		if	(dsid <= 0 || dspt <= 0 || nsects <= 0)
			{
			doserr = EMEDIA;
			goto err;
			}
		dtrk = nsects/(dsid*dspt);
		if	(dsid != sid || trk != dtrk || dspt != spt)
			{
			if	(1 != Rform_alert(1, AL_ASK_FORMAT, global))
				{
				doserr = EBREAK;
				goto err;
				}
			fmt = TRUE;
			}
		}

	/* Speicher anfordern, ggf. Tmpdatei erstellen */
	/* ------------------------------------------- */

	if	(fmt)
		{
		fbuf = Malloc(20480L);	/* Formatierpuffer */
		if	(fbuf == NULL)
			{
			memerr:
			doserr = ENSMEM;
			goto err;
			}
		}
	else fbuf = NULL;

	bufsiz_trk = trk;
	bufsiz_char = (long) bufsiz_trk * (long) sid * (long) spt * 512L;
	buf = Malloc(bufsiz_char);
	if	(!buf)
		{
		bufsiz_char = (long) Malloc(-1L) - 32768L;
		if	(bufsiz_char < 32768L)
			goto memerr;
		bufsiz_char /= (sid * spt * 512);
		bufsiz_char *= (sid * spt * 512);	/* In Spuren umrechnen */
		buf = Malloc(bufsiz_char);
		if	(!buf)
			goto memerr;
		bufsiz_trk = (unsigned int) (bufsiz_char/(sid * spt * 512L));

		if	(bufsiz_trk < trk && tmp >= 0)	/* Speicher reicht nicht fÅr ganze Disk */
			{
			doserr = Fcreate(tmpdatei, 0);
			if	(doserr < E_OK)
				goto err;
			handle = (int) doserr;
			}
		}

	/* Sektornummerliste initialisieren (fÅrs Formatieren) */
	/* --------------------------------------------------- */

	for	(i = 0; i < spt; i++)
		secnos[i] = i+1;

	gelesen = FALSE;
	nochmal:
	for	(ltrack = 0; ltrack < trk; ltrack += bufsiz_trk)
		{

		/* Lesen */
		/* ----- */

		c_tracks = MIN(trk, ltrack + bufsiz_trk);	/* bis hierher lesen */
		n_bytes  = (c_tracks-ltrack)*spt*sid*512L;	/* soviele Bytes lesen */

		if	(!gelesen)
			{
			if	(!msg_chg(QUELLE, slw, dlw))	/* Quelldisk anfordern */
				goto abbruch;
			for	(ctrack = ltrack, cbuf = buf;
			      ctrack < c_tracks;
			      ctrack++, cbuf += spt*sid*512)
				{
				doserr = send_status( whdl, dst_apid, ctrack, 0, 0);
				if	(doserr < 0)
					{
					to_finish = FALSE;
					goto abbruch;
					}

				for	(cside = 0; cside < sid; cside++)
					{
					if	(qbreak())
						{
						abbruch:
						doserr = EBREAK;
						goto err;
						}
					doserr = M_Floprd(cbuf + 512L*spt*cside, NULL, slw, 1, ctrack, cside, spt);
					if	(doserr != E_OK)
						goto err;
					}	
				}
			if	(tmp >= 0 && bufsiz_trk < trk)
				{
				doserr = Fwrite(handle, n_bytes, buf);
				if	(doserr != n_bytes && doserr > E_OK)
					doserr = ENSMEM;
				if	(doserr < E_OK)
					goto err;
				if	(ctrack < trk)
					continue;			/* Weiterlesen */
				gelesen = TRUE;
				doserr = Fseek(0L, handle, 0);
				if	(doserr < E_OK)
					goto err;
				goto nochmal;
				}
			}
		else {
			doserr = Fread(handle, n_bytes, buf);
			if	(doserr != n_bytes)
				goto err;
			}

		/* Schreiben und ggf. Formatieren */
		/* ------------------------------ */

		if	(!msg_chg(ZIEL, slw, dlw))		/* Zieldisk anfordern */
			goto abbruch;
		for	(ctrack = ltrack, cbuf = buf;
			 ctrack < c_tracks;
			 ctrack++, cbuf += spt*sid*512)
			{
			if	(fmt)
				{
				doserr = send_status( whdl, dst_apid, ctrack, 2, 0);
				if	(doserr < 0)
					goto abbruch;
				for	(cside = 0; cside < sid; cside++)
					{
					if	(qbreak())
						goto abbruch;
					doserr = M_Flopfmt(fbuf, secnos, dlw, spt, ctrack, cside, interlv,
								   (ctrack < 10) ? 0 : 0xe5e5);
					if	(doserr != E_OK)
						goto err;
					for	(i = 0; i < spt; i++)
						{
						secnos[i] -= 2;
						if	(secnos[i] < 1)
							secnos[i] += spt;
						}
					}
				}
			doserr = send_status( whdl, dst_apid, ctrack, 1, 0);
			if	(doserr < 0)
				goto abbruch;
			for	(cside = 0; cside < sid; cside++)
				{
				if	(ctrack == 0 && cside == 0)
					Protobt(cbuf, 0x01000000L, -1, -1);	/* Eigene Seriennummer */
				if	(qbreak())
					goto abbruch;
				doserr = M_Flopwr(cbuf + 512L*spt*cside, NULL, dlw, 1, ctrack, cside, spt);
				if	(doserr != E_OK)
					goto err;
				}	
			}

		}

	err:

     /* Speicher freigeben, Diskwechsel simulieren */
     /* ------------------------------------------ */

	if	(buf)
		Mfree(buf);
	if	(fbuf)
		Mfree(fbuf);
	if	(tmp >= 0 && (handle >= 0))
		{
		Fclose(handle);
		Fdelete(tmpdatei);
		}
/*	Rwabs(0, NULL, 2, 0, dlw);	*/
	if	(to_finish)
		send_finish( whdl, dst_apid, doserr );
	if	(doserr != ELOCKED)
		{
		Dlock(0, slw);		/* Freigeben */
		Dlock(0, dlw);		/* Freigeben */
		send_wdraw(dlw);
		form_xerr(doserr, "DISKCOPY");
		}
	return(doserr);
}
