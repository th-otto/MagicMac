/*
 * ramutil.c vom 16.07.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Enth�lt die Hilfsroutinen des Ramdisk-XFS f�r MagiC (also solche,
 * die nicht direkt von der XFS-Schnittstelle angesprungen werden).
 *
 * History:
 * 30.12.1995: Erstellung.
 *             In work_entry wird das x-Flag jetzt nicht mehr gepr�ft,
 *             in findfile nur noch dann, wenn nicht das Verzeichnis
 *             selbst gesucht ist.
 * 31.12.1995: Neue Funktion "increase_refcnts", n�heres in ramdisk.c
 * 01.01.1996: Wird work_entry NULL f�r action �bergeben, liefert es
 *             EINVFN sobald der Test auf einen symbolischen Link
 *             nicht erfolgreich war.
 * 02.01.1996: In prepare_dir wird jetzt f�r die Blockgr��e des
 *             Wurzelverzeichnisses eine Null eingetragen.
 * 03.01.1996: get_and_set_drive sucht jetzt bis Laufwerk Z.
 * 20.01.1996: S�mliche static-chars innerhalb von Funktionen durch
 *             per int_malloc angeforderte ersetzt. Damit ist die
 *             Ramdisk jetzt voll reentrant.
 * 05.02.1996: findfile sucht im Modus FF_EXIST nur noch dann mit
 *             TOS-gestutzten bzw. caseinsensitiven Filenamen weiter,
 *             wenn die TOS-Domain aktiv ist.
 * 10.02.-
 * 12.02.1996: Weiterf�hrung der Kommentierung.
 * 12.02.1996: Kmalloc pr�ft jetzt, ob der gr��te Speicherblock minus
 *             der gew�nschten Anzahl Bytes noch gro� genug ist
 *             (bisher fehlte das Minus...)
 * 13.02.1996: Anpassung an den neuen Prototyp von install_xfs (siehe
 *             pc_xfs.h)
 * 14.02.1996: Auswertung der Infodatei begonnen.
 * 16.02.1996: Auswertung fertiggestellt.
 * 17.02.1996: Neues Kommando f�r die Infodatei: 8bit, legt fest, ob
 *             in Filenamen ASCII-Zeichen > 127 erlaubt sind. Daf�r
 *             mu�te nat�rlich auch check_name angepa�t werden.
 *             Die Debug-Version unterst�tzt jetzt zus�tzlich die
 *             Kommandos logfile und logbackup in der Infodatei.
 *             findfile nochmal �berarbeitet.
 * 19.02.1996: Kmalloc verbessert: Erst wird versucht, einen Block
 *             der gew�nschten Gr��e anzufordern. Klappt das nicht,
 *             ist Schlu�. Ansonsten wird jetzt gepr�ft, ob sich die
 *             Lange des gr��ten noch freien Speicherblocks ge�ndert
 *             hat. Falls nicht, wird der Block so als Ergebnis
 *             geliefert. Im anderen Fall wird der Block wieder
 *             freigegeben, wenn der neue Wert kleiner als der
 *             Mindestwert ist. Auf diese Weise kann die Ramdisk auch
 *             bei stark fragmentiertem Speicher noch neue Daten
 *             aufnehmen.
 * 26.02.1996: Die Funktion readline stark beschleunigt, au�erdem
 *             wird jetzt kein Linefeed bei der letzten Zeile mehr
 *             ben�tigt.
 *             Neues Kommando f�r die INF-Datei: label, zum Festlegen
 *             des Volume Labels.
 *             Einschaltmeldung korrigiert.
 * 23.04.1996: Beim Start wird jetzt erstmal der MagX-Cookie gepr�ft.
 * 02.06.1996: Kmalloc belegt jetzt nach M�glichkeit Speicher am Ende
 *             des gr��ten freien Blocks, um die Fragmentierung des
 *             freien Speichers zu verringern.
 *             Das Ramdisk-XFS kann jetzt auch Laufwerk B: belegen,
 *             wenn nur ein physikalisches Laufwerk vorhanden ist.
 * 23.06.1996: Neue Funktionen f�r Kernel-Malloc, Kernel-Mfree und
 *             Kernel-Pdomain, die bei passender Kernelversion
 *             automatisch benutzt werden.
 * 16.07.1996: Die Funktion Pdomain_kernel lieferte leider nicht die
 *             Domain, sondern die PID des laufenden Prozesses...
 */

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
/*
 * Ein XFS kann man schlecht bis �berhaupt nicht mit konventionellen
 * Mitteln (sprich: Pure Debugger) debuggen, daher verwende ich
 * ganz einfach an den wichtigsten Stellen Debugausgaben, mit deren
 * Hilfe man Fehler schnell einkreisen kann. Selbstverst�ndlich
 * sind diese im tats�chlichen Betrieb st�rend, daher werden sie nur
 * eincompiliert, wenn DEBUG definiert ist. LOGFILE legt dabei fest,
 * in welches File die Ausgaben geschrieben werden sollen, LOGBACK
 * ist das Backupfile (bei jedem Start wird das alte Backupfile
 * gel�scht, das letzte Debugfile in LOGBACK umbenannt und ein neues
 * Logfile begonnen). Hier kann man auch u:\\dev\\prn verwenden, wenn
 * man zuviel Papier hat ;)
 * LOGFILE und LOGBACK m�ssen absolute Pfade mit Laufwerkskennung
 * sein und auf dem gleichen physikalischen Laufwerk liegen.
 * Wird beim Start eine der Umschalttasten festgehalten, wird direkt
 * auf die Console (also normalerweise auf den Bildschirm)
 * ausgegeben. Den gleichen Effekt erh�lt man durch u:\\dev\\con
 * f�r LOGFILE. LOGBACK sollte dann weggelassen werden.
 * Selbstverst�ndlich wird das Filesystem durch die Debug-Ausgaben
 * sehr stark gebremst, vor allem, wenn man sie in eine Datei auf
 * der Festplatte ausgeben l��t. Wer's ganz trickreich machen will,
 * legt das Logfile der Ramdisk auf eine andere(!) Ramdisk, damit ist
 * die Geschwindigkeit einigerma�en ertr�glich.
 * Ach ja, das Ganze ist nur der Default, da man in der Infodatei
 * auch andere Dateien festlegen kann.
 * Das Logfile wird �brigens recht schnell sehr gro�, daher sollte
 * man es ab und an l�schen, wenn keine Fehler aufgetreten sind. Das
 * L�schen schadet nichts, da die Datei nur direkt f�r Ausgaben
 * ge�ffnet wird.
 */
#ifdef DEBUG
#define LOGFILE	"c:\\gemsys\\magic\\xtension\\ramdebug.log"
#define LOGBACK	"c:\\gemsys\\magic\\xtension\\ramdebug.olg"
#include <stdarg.h>
#endif /* DEBUG */
#define ONLY_EXTERN
#include "ramdisk.h"

static char	mountname[256];
#ifdef DEBUG
static char	logfile[256];
static char logback[256];
#endif

#define NUM_DRIVES 32

static int letter_from_drive(int drv)
{
	return drv >= 26 ? drv - 26 + '1' : drv + 'A';
}


static int drive_from_letter(int drv)
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


int main(void)
{
	char	help[2];

/* MagX-Cookie suchen und abbrechen, wenn nicht vorhanden */
	if (!get_cookie('MagX', NULL))
	{
		Cconws("The Ramdisk-XFS only works with MagiC 3 or better!"
			"\r\n");
		return(-1);
	}
	Cconws("\r\nRamdisk-XFS dated "VERSION"\r\n");
	Cconws("(c) 1995-1996 by Thomas Binder\r\n");
/* Die Parameter mit Defaultwerten belegen */
	leave_free = LEAVE_FREE;
	ram_type = RAM_TYPE;
	ramdisk_drive = -1;
	strcpy(mountname, "");
	strcpy(volume_label, "");
	eight_bit = 0;
#ifdef DEBUG
	strcpy(logfile, LOGFILE);
#ifdef LOGBACK
	strcpy(logback, "");
#else
	strcpy(logback, LOGBACK);
#endif /* LOGBACK */
#endif /* DEBUG */
	read_infofile();
/*
 * Zun�chst ein/das Laufwerk f�r die Ramdisk ermitteln. Leider bietet
 * MagiC nicht die M�glichkeit, ein Filesystem direkt zu mounten; man
 * man mu� also immer mindestens ein BIOS-Laufwerk belegen, ob man es
 * nun braucht, oder nicht.
 */
	if (ramdisk_drive < 0)
	{
		if ((ramdisk_drive = (WORD)Supexec(get_and_set_drive)) < 0)
		{
			Cconws("Installation failed (no free drive)!r\n");
			return(-1);
		}
	}
	else
	{
		if (Supexec(set_ramdisk_drive) == 0L)
		{
			Cconws("Installation failed (drive already in use)!"
				"\r\n");
			return(-1);
		}
	}
/*
 * Die Kernelstruktur ermitteln und pr�fen, ob die per int_malloc
 * angeforderten Speicherst�cke gro� genug sind, um einen tempor�ren
 * Filenamen der Ramdisk aufzunehmen.
 */
	if ((real_kernel = (MX_KERNEL *)Dcntl(KER_GETINFO, NULL, 0L)) ==
		NULL)
	{
		Cconws("Installation failed (kernel structure unavailable)!"
			"\r\n");
		return(-1);
	}
	kernel = install_kernel(real_kernel);
	if (kernel->int_msize < (RAM_MAXFNAME + 2))
	{
		Cconws("Installation failed (kernel blocksize too small)!"
			"\r\n");
		return(-1);
	}
/*
 * Jetzt das XFS mit der Funktion install_xfs aus pc_xfs.h beim
 * Kernel anmelden. Zur�ckgeliefert wird der Zeiger auf die
 * angepa�te Kernelstruktur, die man f�r Funktionsaufrufe benutzen
 * mu�. Die tats�chliche Struktur (wie sie schon weiter oben per
 * Dcntl ermittelt wurde) findet sich jetzt im Zeiger real_kernel.
 */
	if (install_xfs(&ramdisk_xfs) <= 0)
	{
		Cconws("Installation failed!\r\n");
		return(-1);
	}
/*
 * Die Ramdisk ist jetzt beim Kernel angemeldet und kann danach nicht
 * mehr entfernt werden. Sollte also bei dem Versuch, den Namen in
 * U:\ zu �ndern, etwas schiefgehen, mu� der Benutzer damit leben.
 */
	if (ramdisk_drive == 1)
	{
/*
 * F�r Laufwerk B: mu� erst noch der Link in Laufwerk U: angelegt
 * werden
 */
		Fsymlink("B:\\", "U:\\b");
	}
	Cconws("Installed as U:\\");
	if (*mountname)
	{
		Dsetdrv('U' - 'A');
		Dsetpath("\\");
		help[0] = letter_from_drive(ramdisk_drive);
		help[1] = 0;
		if (Frename(0, help, mountname) != 0L)
		{
			Cconws(help);
			Cconws("! (Frename failed)\r\n");
		}
		else
		{
			Cconws(mountname);
			Cconws("!\r\n");
		}
	}
	else
	{
		Cconout(65 + ramdisk_drive);
		Cconws("!\r\n");
	}
#ifdef DEBUG
	Cconws("MagiC-Kernelversion ");
	Cconout(48 + real_kernel->version);
	Cconws("\r\nDebug-output to ");
	if (Kbshift(-1) & 31)
	{
		debug_to_screen = 1;
		Cconws("screen\r\n");
	}
	else
	{
		if (*logback)
		{
			Fdelete(logback);
			Frename(0, logfile, logback);
		}
		debug_to_screen = 0;
		Cconws(logfile);
		Cconws("\r\n");
	}
#endif
/*
 * Ermitteln, ob Pdomain �ber GEMDOS oder die Kernel-Struktur
 * abgewickelt werden kann
 */
	p_Pdomain = Pdomain_gemdos;
	if ((real_kernel->version >= 2) &&
		((kernel->proc_info)(0, _BasPag) >= 2))
	{
		p_Pdomain = Pdomain_kernel;
	}
/*
 * Ermitteln, ob Mxalloc und Mfree �ber GEMDOS oder die Kernel-
 * Struktur aufgerufen werden k�nnen.
 */
	_Mxalloc = Mxalloc;
	_Mfree = Mfree;
	if (real_kernel->version >= 4)
	{
		_Mxalloc = Mxalloc_kernel;
		_Mfree = Mfree_kernel;
	}
/* Startzeit und -datum f�r das Wurzelverzeichnis merken */
	starttime = Tgettime();
	startdate = Tgetdate();
/*
 * Ein XFS mu�, sobald es erfolgreich mit install_xfs angemeldet
 * wurde, dauerhaft im Speicher verbleiben, deswegen mu� hier
 * Ptermres aufgerufen werden. Das nachfolgende return ist eigentlich
 * sinnlos, h�lt Pure C aber vom Meckern ab...
 */
	Ptermres(_PgmSize, 0);
	return(0);
}

/*
 * read_infofile
 *
 * Liest die INF-Datei des Ramdisk-XFS und wertet sie aus. Ung�ltige
 * Zeilen werden gemeldet und nicht beachtet.
 */
void read_infofile(void)
{
	static char	filename[128],
				input[256];
	char		*prgname,
				*filename2,
				*arg,
				*pos;
	LONG		err;
	WORD		handle;

/*
 * Die Datei findet sich entweder im Ordner \gemsys\magic\xtension
 * des aktuellen Laufwerks, in dessen Wurzelverzeichnis oder im
 * aktuellen Verzeichnis
 */
	strcpy(filename, "\\gemsys\\magic\\xtension\\");
	filename2 = strrchr(filename, '\\');
/*
 * Versuchen, den Namen des Filesystems �ber den von MagiC angelegte
 * Environment-Variable _PNAM zu ermittlen. Geht das nicht, wird der
 * Name der INF-Datei auf ramdisk.inf gesetzt und direkt zum �ffnen
 * der Datei verzweigt (per unbeliebtem goto...)
 */
	if ((prgname = getenv("_PNAM")) == NULL)
	{
		strcat(filename, "ramdisk.inf");
		goto open_file;
	}
/*
 * Enth�lt der Programmname keinen Punkt, wird direkt .inf angeh�ngt
 * und zum File�ffnen verzweigt (schon wieder goto...)
 */
	if ((pos = strrchr(prgname, '.')) == NULL)
	{
		if (*prgname == '\\')
		{
			strcpy(filename, prgname);
			filename2 = NULL;
		}
		else
			strcat(filename, prgname);
		strcat(filename, ".inf");
		goto open_file;
	}
/* Ansonsten wird die Extension durch ".inf" ersetzt */
	*pos = 0;
	if (*prgname == '\\')
	{
		filename2 = NULL;
		strcpy(filename, prgname);
	}
	else
		strcat(filename, prgname);
	*pos = '.';
	strcat(filename, ".inf");
/*
 * Die Datei �ffnen; wenn der Programmname ein absoluter Pfad war,
 * wird nur dort gesucht, sonst auch im Wurzelverzeichnis und im
 * aktuellen Verzeichnis
 */
open_file:
	if (((err = Fopen(filename, FO_READ)) < 0L) && (!filename2 ||
		(((err = Fopen(filename2, FO_READ)) < 0L) &&
		((err = Fopen(++filename2, FO_READ)) < 0L))))
	{
		return;
	}
	handle = (WORD)err;
/* Die Datei zeilenweise auslesen und auswerten */
	while (readline(handle, input))
	{
/* Leerzeilen werden komplett ignoriert */
		if (!*input)
			continue;
/* Jede Zeile mu� mindestens ein Gleichheitszeichen enthalten */
		if ((arg = strchr(input, '=')) == NULL)
		{
/*
 * Ung�ltige Zeilen werden gemeldet und �bergangen; au�erdem wird
 * ein Flag gesetzt, damit vor Programmende auf einen Tastendruck
 * gewartet wird (sonst sind die Meldungen u.U. zu schnell wieder
 * weg)
 */
invalid_line:
			if (arg != NULL)
				*arg = '=';
			Cconws("Invalid line in INF-file (ignored):\r\n");
			Cconws(input);
			Cconws("\r\n");
			continue;
		}
		*arg = 0;
/*
 * Folgt hinter dem Gleichheitszeichen nichts mehr, ist die Zeile
 * ung�ltig
 */
		if (!arg[1])
			goto invalid_line;
/*
 * Hinter dem Kommando drive= mu� ein Laufwerksbuchstabe zwischen
 * 'A' und 'Z' (jeweils einschlie�lich) au�er 'U' folgen, sonst ist
 * die Zeile falsch
 */
		if (!stricmp(input, "drive"))
		{
			int drv;

			if (arg[2])
				goto invalid_line;
			drv = drive_from_letter(arg[1]);
			if (drv < 0 || drv == 'U' - 'A')
				goto invalid_line;
			ramdisk_drive = drv;
			continue;
		}
/*
 * Der Text hinter mountname= wird ohne weitere Pr�fungen �bernommen
 */
		if (!stricmp(input, "mountname"))
		{
			strcpy(mountname, &arg[1]);
			continue;
		}
/*
 * Hinter ramtype= d�rfen stonly, altonly, storalt oder altorst
 * folgen, alles andere macht die Zeile ung�ltig
 */
		if (!stricmp(input, "ramtype"))
		{
			if (!stricmp(&arg[1], "stonly"))
				ram_type = 0;
			else if (!stricmp(&arg[1], "altonly"))
				ram_type = 1;
			else if (!stricmp(&arg[1], "storalt"))
				ram_type = 2;
			else if (!stricmp(&arg[1], "altorst"))
				ram_type = 3;
			else
				goto invalid_line;
			continue;
		}
/*
 * Der Inhalt der Zeile hinter leavefree= wird in eine Zahl gewandelt
 * und mit 1024 multipliziert. Weitere �berpr�fungen finden nicht
 * statt.
 */
		if (!stricmp(input, "leavefree"))
		{
			leave_free = atol(&arg[1]) * 1024L;
			continue;
		}
/* Hinter 8bit= mu� entweder "true" oder "false" folgen */
		if (!stricmp(input, "8bit"))
		{
			if (!stricmp(&arg[1], "true"))
				eight_bit = 1;
			else if (!stricmp(&arg[1], "false"))
				eight_bit = 0;
			else
				goto invalid_line;
			continue;
		}
/* Die ersten 32 Zeichen hinter label= werden direkt �bernommen */
		if (!stricmp(input, "label"))
		{
			volume_label[RAM_MAXFNAME] = 0;
			strncpy(volume_label, &arg[1], RAM_MAXFNAME);
			continue;
		}
#ifdef DEBUG
		if (!stricmp(input, "logfile"))
		{
			strcpy(logfile, &arg[1]);
			strcpy(logback, "");
			continue;
		}
		if (!stricmp(input, "logbackup"))
		{
			strcpy(logback, &arg[1]);
			continue;
		}
#endif
/*
 * Sollte die Zeile nicht mit drive, mountname, ramtype, leavefree
 * oder 8bit begonnen haben, ist sie ebenfalls ung�ltig
 */
		goto invalid_line;
	}
	Fclose(handle);
}

/*
 * readline
 *
 * Liest eine Zeile aus einer GEMDOS-Datei ein,
 * die wahlweise mit CRLF oder nur LF enden darf.
 * Beginnt sie mit einem '#', wird gleich die
 * n�chste Zeile eingelesen.
 *
 * Eingabe:
 * handle: Zu benutzendes GEMDOS-Handle
 * buffer: Zeiger auf 255 Byte gro�en Zeilenpuffer
 *
 * R�ckgabe:
 * 0: Fehler beim Lesen (oder: Zeile zu lang)
 * 1: Alles OK
 */
WORD readline(WORD handle, char *buffer)
{
    WORD    count;
    LONG	fpos,
    		add,
    		bytes_read;

    for (;;)
    {
		fpos = Fseek(0L, handle, 1);
		if (fpos < 0L)
			return(0);
		if ((bytes_read = Fread(handle, 255, buffer)) <= 0L)
		{
			return(0);
		}
        count = 0;
		add = 1L;
        for (;;)
        {
        	if (count == bytes_read)
        	{
        		add = 0L;
        		break;
        	}
            if (buffer[count] == '\n')
                break;
            if (count == 255)
                return(0);
            if (buffer[count] == '\t')
            	buffer[count] = ' ';
            count++;
        }
        if (Fseek((LONG)count + fpos + add, handle, 0) < 0L)
        {
        	return(0);
        }
        if (count)
        {
            if (buffer[count - 1] == '\r')
                count--;
        }
        buffer[count] = 0;
        if (*buffer != '#')
            break;
    }
    return(1);
}

/*
 * get_and_set_drive
 *
 * Parameterfunktion f�r Supexec, die ein freies Laufwerk in _drvbits
 * sucht und belegt. Von der Suche ausgenommen sind A, B und U.
 *
 * R�ckgabe:
 * -1: Keine freie Laufwerkskennung mehr vorhanden.
 * sonst: Belegte Laufwerksnummer (2 = C, 3 = D, etc.)
 */
LONG get_and_set_drive(void)
{
	LONG	*_drvbits;
	int i;

	_drvbits = (LONG *)0x4c2;
	for (i = 2; i < NUM_DRIVES; i++)
	{
		if ((i != ('U' - 'A')) && !(*_drvbits & (1L << i)))
		{
			*_drvbits |= (1L << i);
			return i;
		}
	}
	return -1;
}

/*
 * set_ramdisk_drive
 *
 * �hnlich wie get_and_set_drive, versucht aber nur, das durch
 * ramdisk_drive gebenene Laufwerk in _drvbits zu belegen.
 *
 * R�ckgabe:
 * 0L: Das gew�nschte Laufwerk war schon belegt.
 * 1L: Alles OK.
 */
LONG set_ramdisk_drive(void)
{
	LONG	*_drvbits;

	_drvbits = (LONG *)0x4c2;
	if (*_drvbits & (1L << ramdisk_drive))
	{
/*
 * Sonderbehandlung bei Laufwerk B: Soll die Ramdisk dieses Laufwerk
 * belegen, wird gepr�ft, ob wirklich zwei Laufwerke angeschlossen
 * sind. Falls nicht, wird B: als Kennung akzeptiert.
 */
		if ((ramdisk_drive != 1) || (*(WORD *)0x4a6 > 1))
			return(0L);
	}
	*_drvbits |= (1L << ramdisk_drive);
	return(1L);
}

/*
 * Pdomain_gemdos
 *
 * Ruft direkt das GEMDOS-Pdomain auf.
 *
 * Eingabe:
 * domain: Neue Domain, -1 fragt ab.
 *
 * R�ckgabe:
 * Alte bzw. aktuelle Domain (0 = TOS, 1 = MiNT)
 */
LONG Pdomain_gemdos(WORD domain)
{
	return Pdomain(domain);
}

/*
 * Pdomain_kernel
 *
 * Ruft die Kernel-Funktion proc_info zur Ermittlung der aktuellen
 * Domain auf.
 *
 * Eingabe:
 * ignore: Wie domain f�r Pdomain_gemdos, wird aber ignoriert
 *
 * R�ckgabe:
 * Aktuelle Domain (0 = TOS, 1 = MiNT)
 */
#pragma warn -par
LONG Pdomain_kernel(WORD ignore)
{
	LONG	domain;

	domain = (kernel->proc_info)(1, *(real_kernel->act_pd));
	TRACE(("Kernel-Pdomain liefert %L!\r\n", domain));
	return(domain);
}
#pragma warn .par

/*
 * Mxalloc_kernel
 *
 * Ruft die Kernel-Funktion mxalloc zur Anforderung von Speicher auf.
 *
 * Eingabe:
 * amount: Anzahl der Bytes oder -1L
 * mode: Speichertyp
 *
 * R�ckabe:
 * Zeiger auf allozierten Speicher oder NULL bzw. L�nge des gr��ten
 * freien Speicherblocks
 */
void *Mxalloc_kernel(LONG amount, short mode)
{
	return (void *)((kernel->mxalloc)(amount, mode & ~0x4000, _BasPag));
}

/*
 * Mfree_kernel
 *
 * Ruft die Kernel-Funktion mfree zur Freigabe von Speicher auf.
 *
 * Eingabe:
 * block: Zeiger auf freizugebenden Speicher.
 *
 * R�ckgabe:
 * 0: Alles OK
 * sonst: GEMDOS-Fehlercode (z.B. EIMBA)
 */
short Mfree_kernel(void *block)
{
	return((WORD)(kernel->mfree)(block));
}

/*
 * increase_refcnts
 *
 * Erh�ht den Referenzz�hler eines DDs und den "Elternschaftsz�hler"
 * aller seiner Vorfahren, wenn er bislang noch nicht referenziert
 * wurde.
 *
 * Eingabe:
 * dd: Zeiger auf den zu bearbeitenden RAMDISK_FD
 */
void increase_refcnts(RAMDISK_FD *dd)
{
	dd->fd_refcnt++;
	if (dd->fd_refcnt > 1)
		return;
	for (dd = dd->fd_parent; dd != NULL; dd = dd->fd_parent)
	{
		dd->fd_is_parent++;
		TRACE(("increase_refcnts: is_parent von %L jetzt %L!\r\n", dd, (LONG)dd->fd_is_parent));
	}
}

/*
 * prepare_dir
 *
 * Initialisiert ein Verzeichnis der Ramdisk. Der Speicher wird
 * mit Nullen gel�scht, anschlie�end werden die Pseudoeintr�ge "."
 * und ".." eingerichtet.
 *
 * Eingabe:
 * dir: Zeiger auf das Verzeichnis
 * maxentries: Soviele Eintr�ge soll das Verzeichnis haben
 * parent: Zeiger auf das Elternverzeichnis, oder ROOT_DE, wenn
 *         dir das Wurzelverzeichnis ist.
 */
void prepare_dir(DIRENTRY *dir, WORD maxentries, DIRENTRY *parent)
{
	(kernel->fast_clrmem)(dir, &dir[maxentries]);
	strcpy(dir[0].de_fname, ".");
	dir[0].de_faddr = (char *)dir;
	dir[0].de_nr = 0;
	dir[0].de_maxnr = maxentries;
	dir[0].de_xattr.st_mode = S_IFDIR | 0777;
	dir[0].de_xattr.st_ino = (LONG)dir;
	dir[0].de_xattr.st_dev = ramdisk_drive;
	dir[0].de_xattr.st_rdev = ramdisk_drive;
	dir[0].de_xattr.st_nlink = 1;
	dir[0].de_xattr.st_uid = 0;
	dir[0].de_xattr.st_gid = 0;
	dir[0].de_xattr.st_size = 0;
	if (parent != ROOT_DE)
		dir[0].de_xattr.st_blocks = 1;
	else
		dir[0].de_xattr.st_blocks = 0;
	dir[0].de_xattr.st_mtim.u.d.time = Tgettime();
	dir[0].de_xattr.st_mtim.u.d.date = Tgetdate();
	dir[0].de_xattr.st_atim.u.d.time = Tgettime();
	dir[0].de_xattr.st_atim.u.d.date = Tgetdate();
	dir[0].de_xattr.st_ctim.u.d.time = Tgettime();
	dir[0].de_xattr.st_ctim.u.d.date = Tgetdate();
	dir[0].de_xattr.st_attr = FA_DIR;
	dir[0].de_xattr.res1 = 0;
	dir[0].de_xattr.res2[0] = 0L;
	dir[0].de_xattr.res2[1] = 0L;
	strcpy(dir[1].de_fname, "..");
	if (parent != ROOT_DE)
	{
		parent[0].de_xattr.st_atim.u.d.time = parent[0].de_xattr.st_mtim.u.d.time =
			Tgettime();
		parent[0].de_xattr.st_atim.u.d.date = parent[0].de_xattr.st_mtim.u.d.date =
			Tgetdate();
		dir[1].de_faddr = (char *)parent;
		dir[1].de_nr = 1;
		dir[1].de_maxnr = 0;
		dir[1].de_xattr = parent[0].de_xattr;
	}
	else
	{
		dir[1].de_faddr = (char *)&root_de;
		dir[1].de_nr = 1;
		dir[1].de_maxnr = 0;
		dir[1].de_xattr.st_mode = S_IFDIR | 0777;
		dir[1].de_xattr.st_ino = (LONG)parent;
		dir[1].de_xattr.st_dev = ramdisk_drive;
		dir[1].de_xattr.st_rdev = ramdisk_drive;
		dir[1].de_xattr.st_nlink = 1;
		dir[1].de_xattr.st_uid = 0;
		dir[1].de_xattr.st_gid = 0;
		dir[1].de_xattr.st_size = 0;
		dir[1].de_xattr.st_blocks = 1;
		dir[1].de_xattr.st_mtim.u.d.time = Tgettime();
		dir[1].de_xattr.st_mtim.u.d.date = Tgetdate();
		dir[1].de_xattr.st_atim.u.d.time = Tgettime();
		dir[1].de_xattr.st_atim.u.d.date = Tgetdate();
		dir[1].de_xattr.st_ctim.u.d.time = starttime;
		dir[1].de_xattr.st_ctim.u.d.date = startdate;
		dir[1].de_xattr.st_attr = FA_DIR;
		dir[1].de_xattr.res1 = 0;
		dir[1].de_xattr.res2[0] = 0L;
		dir[1].de_xattr.res2[1] = 0L;
	}
}

/*
 * findfile
 *
 * Funktion zum Suchen einer Datei. Hier mu� das Problem angemessen
 * ber�cksichtigt werden, da� Programme, die in der TOS-Domain
 * laufen, m�glicherweise verst�mmelte Filenamen liefern, die mit dem
 * tats�chlichen nur noch sehr wenig gemeinsam haben. Besonders
 * unangenehm ist das Ganze mit MagiC 3, da es dort noch kein Pdomain
 * gibt. Es l��t sich daher dort nicht feststellen, ob ein Proze�
 * lange Dateinamen versteht.
 *
 * Eingabe:
 * dd: Zeiger auf den RAMDISK_FD des Verzeichnisses, in dem gesucht
 *     werden soll.
 * pathname: Name des gesuchten Files/Directories.
 * spos: Nummer des Eintrags, ab dem die Suche beginnen soll (0, wenn
 *       auch "." und ".." gefunden werden d�rfen, sonst >= 2).
 * s_or_e: Bestimmt, ob pathname f�r einen Zugriff gesucht wird
 *         (FF_SEARCH) oder ob f�r eine Neuanlage des Names gepr�ft
 *         werden soll, ob er schon existiert (FF_EXIST). Je nach
 *         Modus und aktiver Domain verh�lt sich die Funktion anders.
 * maybe_dir: Legt fest, ob pathname leer sein darf (ungleich Null)
 *            oder nicht (0). Wenn ja, und pathname ist tats�chlich
 *            leer, wird das aktuelle Verzeichnis selbst gefunden.
 *            Dies ist dann n�tig, wenn ein Programm beispielsweise
 *            Fxattr f�r "c:\gemsys\" aufruft.
 *
 * R�ckgabe:
 * Zeiger auf den gefundenen Verzeichniseintrag, oder NULL.
 */
DIRENTRY *findfile(RAMDISK_FD *dd, const char *pathname, WORD spos,
	WORD s_or_e, WORD maybe_dir)
{
	WORD		i,
				max;
	DIRENTRY	*search;
	char		*temp,
				*dos;

/* Sicherheitscheck f�r den DD */
	if (!is_dir(dd->fd_file->de_xattr.st_mode))
		return(NULL);
/* Ein leerer Suchname bedeutet u.U. das aktuelle Verzeichnis */
	if (!*pathname && maybe_dir)
		return(dd->fd_file);
/*
 * Das aktuelle Verzeichnis mu� �berschreitbar sein. Dieser Test
 * erfolgt absichtlich nach der Abfrage auf leeren Suchnamen, da
 * dann ja das Verzeichnis selbst gefunden werden soll, wozu keine
 * �berschreitungsrechte vorhanden sein m�ssen.
 */
	if (!xaccess(dd->fd_file))
		return(NULL);
/* Zweimal Speicher f�r tempor�re Filenamen anfordern */
	temp = (void *)(kernel->int_malloc)();
	dos = (void *)(kernel->int_malloc)();
	temp[RAM_MAXFNAME] = 0;
	strncpy(temp, pathname, RAM_MAXFNAME);
	search = (DIRENTRY *)dd->fd_file->de_faddr;
	max = search[0].de_maxnr;
/*
 * Zun�chst den Filenamen mit exakten Vergleichen suchen, wenn die
 * MiNT-Domain aktiv ist oder der Directoryeintrag f�r einen Zugriff
 * ermittelt werden soll
 */
	if ((p_Pdomain(-1) == EINVFN) || (p_Pdomain(-1) == 1) ||
		(s_or_e == FF_SEARCH))
	{
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
	}
/*
 * Wurde so nichts gefunden, mu� NULL geliefert werden, wenn der
 * Proze� in der MiNT-Domain l�uft, oder wenn die Domain nicht
 * ermittelt werden kann _und_ nur auf Existenz gepr�ft werden soll
 */
	if ((p_Pdomain(-1) == 1) ||
		((p_Pdomain(-1) == EINVFN) && (s_or_e == FF_EXIST)))
	{
		(kernel->int_mfree)(temp);
		(kernel->int_mfree)(dos);
		return(NULL);
	}
/*
 * Sonst den Filenamen in Kleinbuchstaben wandeln und wieder suchen,
 * wenn die TOS-Domain aktiv ist
 */
	if (p_Pdomain(-1) == 0)
	{
		strlwr(temp);
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
/*
 * Wurde immer noch nichts gefunden, ist die Suche erfolglos, wenn
 * nur auf Existenz des Namens gepr�ft werden soll
 */
		if (s_or_e == FF_EXIST)
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(NULL);
		}
	}
/*
 * Jetzt den Suchnamen in's 8+3-Format quetschen und nochmal mit
 * TOS-Gleichheit suchen
 */
	tostrunc(temp, pathname, 0);
	for (i = spos; i < max; i++)
	{
		if (search[i].de_faddr == NULL)
			continue;
		tostrunc(dos, search[i].de_fname, 0);
		TRACE(("findfile: temp = %S, dos = %S\r\n", temp, dos));
		if (!strcmp(temp, dos))
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(&search[i]);
		}
	}
/* Es wurde wirklich nichts gefunden */
	(kernel->int_mfree)(temp);
	(kernel->int_mfree)(dos);
	return(NULL);
}

/*
 * findfd
 *
 * Sucht einen FD, der entweder frei oder bereits durch einen
 * bestimmten Verzeichniseintrag belegt ist.
 *
 * Eingabe:
 * fname: Zeiger auf Verzeichniseintrag, der im zu suchenden FD
 *        vorhanden sein soll, oder NULL.
 *
 * R�ckgabe:
 * Zeiger auf den gefundenen FD, oder NULL.
 */
RAMDISK_FD *findfd(DIRENTRY *fname)
{
	WORD	i;

#if 1
/*
 * Ist ein Verzeichniseintrag gegeben, zun�chst schauen, ob einer der
 * FDs bereits durch ihn belegt ist. Falls ja, diesen FD liefern.
 */
	if (fname != NULL)
	{
		for (i = 0; i < MAX_FD; i++)
		{
			if (fd[i].fd_file == fname)
				return(&fd[i]);
		}
	}
#endif
/*
 * War fname gleich NULL oder noch nicht vorhanden, wird jetzt ein
 * freier FD gesucht, gel�scht und zur�ckgeliefert
 */
	for (i = 0; i < MAX_FD; i++)
	{
		if (fd[i].fd_file == NULL)
		{
			(kernel->fast_clrmem)(&fd[i], &fd[i + 1]);
			return(&fd[i]);
		}
	}
/* Sollte kein FD mehr frei sein, NULL liefern */
	return(NULL);
}

/*
 * new_file
 *
 * Erstellt einen neuen Eintrag in einem Verzeichnis an und belegt
 * die wichtigsten Felder vor.
 *
 * Eingabe:
 * curr: Zeiger auf den FD des Verzeichnisses, in dem der neue
 *       Eintrag angelegt werden soll.
 * name: Gew�nschter Name des neuen Files.
 *
 * R�ckgabe:
 * Zeiger auf den neuen Eintrag, oder NULL.
 */
DIRENTRY *new_file(RAMDISK_FD *curr, const char *name)
{
	DIRENTRY	*dir,
				*new_dir;
	WORD		i,
				max;

/* Ist der Filename unzul�ssig, NULL zur�ckliefern */
	if (!check_name(name))
		return(NULL);
	dir = (DIRENTRY *)curr->fd_file->de_faddr;
/*
 * Zum Anlegen eines Eintrags mu� das Verzeichnis �berschreit- und
 * beschreibbar sein
 */
	if (!waccess(curr->fd_file) || !xaccess(curr->fd_file))
		return(NULL);
/* Einen noch leeren Eintrag suchen */
	max = dir[0].de_maxnr;
	for (i = 2; i < max; i++)
	{
		if (dir[i].de_faddr == NULL)
			break;
	}
	if (i == max)
	{
/*
 * War kein leerer Eintrag mehr vorhanden, mu� das Verzeichnis um
 * einen Block erweitert werden. Klappt auch das nicht, liefert die
 * Funktion NULL.
 */
		new_dir = Krealloc(dir,
			dir[0].de_xattr.st_blocks * DEFAULTDIR * sizeof(DIRENTRY),
			(dir[0].de_xattr.st_blocks + 1L) * DEFAULTDIR *
			sizeof(DIRENTRY));
		if (new_dir == NULL)
			return(NULL);
		dir = new_dir;
		dir[0].de_maxnr += (WORD)DEFAULTDIR;
		dir[0].de_xattr.st_blocks++;
		dir[0].de_faddr = (char *)new_dir;
		dir[0].de_xattr.st_ino = (LONG)new_dir;
		curr->fd_file->de_maxnr = dir[0].de_maxnr;
		curr->fd_file->de_xattr.st_blocks = dir[0].de_xattr.st_blocks;
		curr->fd_file->de_faddr = (char *)new_dir;
		curr->fd_file->de_xattr.st_ino = (LONG)new_dir;
		/*** work_entry f�r Anpassung von index ***/
	}
/* Den neuen Eintrag komplett l�schen und den Namen eintragen */
	(kernel->fast_clrmem)(&dir[i], &dir[i + 1]);
	strncpy(dir[i].de_fname, name, RAM_MAXFNAME);
	if (p_Pdomain(-1) == 0)
	{
/*
 * In der TOS-Domain den Namen in Kleinbuchstaben wandeln, weil
 * solche Prozesse oft Filenamen wie STGUIDE.APP liefern, die auf
 * einem casesensitiven Filesystem aber nicht so toll ausehen
 */
		TRACE(("new_file: Wandele Filenamen in Lowercase!\r\n"));
		strlwr(dir[i].de_fname);
	}
	else
		TRACE(("new_file: Filename nicht gewandelt!\r\n"));
/*
 * Die wichtigsten Felder des Eintrags belegen. Dabei wird das Feld
 * de_faddr bewu�t noch nicht gef�llt, der Eintrag bleibt also bis
 * zur Belegung durch die aufrufende Funktion frei.
 */
	dir[i].de_nr = i;
	dir[i].de_xattr.st_atim.u.d.time = dir[i].de_xattr.st_mtim.u.d.time =
		dir[i].de_xattr.st_ctim.u.d.time = Tgettime();
	dir[i].de_xattr.st_atim.u.d.date = dir[i].de_xattr.st_mtim.u.d.date =
		dir[i].de_xattr.st_ctim.u.d.date = Tgetdate();
	dir[i].de_xattr.st_dev = ramdisk_drive;
	dir[i].de_xattr.st_rdev = ramdisk_drive;
	dir[i].de_xattr.st_nlink = 1;
	dir[i].de_xattr.st_blksize = DEFAULTFILE;
	return(&dir[i]);
}

/*
 * dir_is_open
 *
 * Pr�ft, ob ein gegebenes Verzeichnis per Dopendir ge�ffnet ist.
 *
 * Eingabe:
 * dir: Zeiger auf den Verzeichniseintrag des Directories.
 *
 * R�ckgabe:
 * 0, wenn das Verzeichnis nicht offen ist, 1 sonst.
 */
WORD dir_is_open(DIRENTRY *dir)
{
	WORD	i;

/*
 * Alle Directory-Handles durchgehen und pr�fen, ob sie das gesuchte
 * Verzeichnis repr�sentieren
 */
	for (i = 0; i < MAX_DHD; i++)
	{
		if (dhd[i].dhd_dir == dir)
			return(1);
	}
	return(0);
}

/*
 * check_name
 *
 * �berpr�ft einen Filenamen auf G�ltigkeit. Erlaubt sind auf der
 * Ramdisk alle ASCII-Zeichen von 32 bis 127/255 (mit Ausnahme des
 * Backslash). Die Obergrenze richtet sich dabei nach dem Wert von
 * eight_bit.
 *
 * Eingabe:
 * name: Zu pr�fender Filename.
 *
 * R�ckgabe:
 * 0, wenn der Name ung�ltig ist, 1 sonst.
 */
WORD check_name(const char *name)
{
	WORD	i;
	unsigned short max;
	unsigned short check;

/* Leere Namen sind auch nicht zul�ssig */
	if (!*name)
		return(0);
	max = eight_bit ? 255 : 127;
	for (i = 0; name[i] != '\0'; i++)
	{
		check = (unsigned char)name[i];
		if (check < 0x20 || check > max ||
			check == '\\' || check == '/')
		{
			return(0);
		}
	}
	return(1);
}

/*
 * check_dd
 *
 * Pr�ft einen Directory-Deskriptor auf G�ltigkeit. Zwar sollte man
 * sich darauf verlassen k�nnen, da� der Kernel den Funktionen eines
 * XFS nur korrekte DDs liefert, aber schlie�tlich ist Vorsicht die
 * Mutter der Porzellankiste...
 *
 * Eingabe:
 * dd: Zu pr�fender DD.
 *
 * R�ckgabe:
 * E_OK: DD ist nicht erkennbar falsch.
 * EDRIVE: DD geh�rt nicht dem Ramdisk-XFS.
 * EPTHNF: DD ist in Wirklichkeit ein FD, repr�sentiert also kein
 *         Verzeichnis.
 */
LONG check_dd(RAMDISK_FD *dd)
{
	if (dd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_dir(dd->fd_file->de_xattr.st_mode))
		return(EPTHNF);
	return(E_OK);
}

/*
 * check_fd
 *
 * Wie check_dd, nur f�r Filedeskriptoren.
 *
 * Eingabe:
 * fd: Zu �berpr�fender FD.
 *
 * R�ckgabe:
 * E_OK: FD ist nicht erkennbar falsch.
 * EDRIVE: FD geh�rt nicht dem Ramdisk-XFS.
 * EFILNF: FD repr�sentiert keine Datei.
 */
LONG check_fd(RAMDISK_FD *fd)
{
	if (fd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_file(fd->fd_file->de_xattr.st_mode))
		return(EFILNF);
	return(E_OK);
}

/*
 * work_entry
 *
 * Hilfsfunktion, die f�r einen bestimmten Directoryeintrag eine
 * gegebene Aktion durchf�hrt und dabei darauf achtet, da� alle
 * Repr�sentanten dieses Eintrags (also auch die Pseudoeintr�ge
 * "." des gleichen und ".." der untergeordneten Verzeichnisse)
 * mit angepa�t werden. Damit lassen sich alle Funktionen, die sich
 * auf Verzeichniseintr�ge beziehen, realisieren, ohne sich um die
 * genannten Details k�mmern zu m�ssen.
 *
 * Eingabe:
 * dd: Zeiger auf den DD, in dessen Verzeichnis sich der zu �ndernde
 *     Eintrag befindet.
 * name: Name des Eintrags.
 * symlink: Zeiger auf Stringzeiger, hier wird ggf. ein Zeiger auf
 *          das Ziel eines symbolischen Links eingetragen. Ist
 *          symlink NULL, werden keine symbolischen Links verfolgt.
 * writeflag: Wenn ungleich Null, wird der Eintrag durch die
 *            Aktionsfunktion eventuell ver�ndert. Dann, und nur
 *            dann, werden auch die anderen Repr�sentanten
 *            bearbeitet.
 * par1: Erster Parameter, den action erhalten soll.
 * par2: Zweiter Parameter f�r action.
 * action: Zeiger auf die Aktionsfunktion, die als Parameter den
 *         Zeiger auf den zu bearbeitenden Eintrag und par1/par2
 *         bekommt. Zur�ckliefern mu� die Funktionen einen GEMDOS-
 *         Returncode. Ist action ein Nullzeiger, mu� name ein
 *         symbolischer Link sein, sonst liefert work_entry sofort
 *         EINVFN.
 *
 * R�ckgabe:
 * GEMDOS-Fehlercode, der meist der Returncode von action ist.
 */
LONG work_entry(RAMDISK_FD *dd, const char *name, void **symlink,
	WORD writeflag, LONG par1, LONG par2,
	LONG (*action)(DIRENTRY *entry, LONG par1, LONG par2))
{
	DIRENTRY	*found,
				*help;
	LONG		retcode;
	WORD		i,
				max;
	XATTR		new;

/* DD �berpr�fen */
	if (check_dd(dd) < 0)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(check_dd(dd));
	}
/* Eintrag suchen */
	if ((found = findfile(dd, name, 0, FF_SEARCH, 1)) == NULL)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(EFILNF);
	}
/* Test auf symbolischen Link */
	if (is_link(found->de_xattr.st_mode) && (symlink != NULL))
	{
		TRACE(("work_entry: Folge symbolischem Link auf %S!\r\n",
			&found->de_faddr[2]));
		*symlink = found->de_faddr;
		return(ELINK);
	}
	if (action == NULL)
		return(EINVFN);
/*
 * Sollen �nderungen vorgenommen werden, obwohl sich name nicht auf
 * das gleiche Verzeichnis bezieht, das auch der DD repr�sentiert,
 * m�ssen Schreibrechte vorhanden sein
 */
	if (writeflag && (dd->fd_file->de_faddr != found->de_faddr) &&
		!waccess(dd->fd_file))
	{
		return(EACCDN);
	}
/*
 * action aufrufen und den Returncode liefern, falls es ein Fehler
 * war, oder wenn keine �nderungen an Eintrag vorgesehen sind
 */
	retcode = (action)(found, par1, par2);
	if ((retcode < 0L) || !writeflag)
		return(retcode);
/*
 * Ist der Eintrag kein Verzeichnis, gibt es auch keine weiteren
 * Eintr�ge, die ihn ebenfalls repr�sentieren und mitge�ndert werden
 * m��ten
 */
	if (!is_dir(found->de_xattr.st_mode))
		return(retcode);
/* Sonst den neuen Inhalt des Eintrags zwischenspeichern */
	new = found->de_xattr;
/* Den Ursprungseintrag des Verzeichnisses ermitteln */
	if (!strcmp(found->de_fname, "."))
		found = dd->fd_file;
	if (!strcmp(found->de_fname, ".."))
	{
/* ".." des Wurzelverzeichnisses hat keine weiteren Repr�sentanten */
		if (dd->fd_parent == NULL)
			return(retcode);
		found = dd->fd_parent->fd_file;
	}
/*
 * Jetzt den Inhalt an alle n�tigen Positionen kopieren, dabei m�ssen
 * auch alle Unterverzeichnisse, soweit vorhanden, ber�cksichtigt
 * werden, da hier ".." ge�ndert werden mu�.
 */
	found->de_xattr = new;
	found = (DIRENTRY *)found->de_faddr;
	found->de_xattr = new;
	max = found->de_maxnr;
	for (i = 2; i < max; i++)
	{
		if ((found[i].de_faddr != NULL) &&
			is_dir(found[i].de_xattr.st_mode))
		{
			help = (DIRENTRY *)found[i].de_faddr;
			help[1].de_xattr = new;
		}
	}
	return(retcode);
}

/*
 * set_amtime
 *
 * Fungiert als Parameterfunktion f�r work_entry und setzt die letzte
 * Zugriffs- bzw. die letzte �nderungszeit auf die aktuellen Werte.
 *
 * Eingabe:
 * entry: Zu bearbeitender Verzeichniseintrag.
 * set_amtime: Wenn 0, soll die �nderungszeit ge�ndert werden, sonst
 *             die Zugriffszeit.
 *
 * R�ckgabe:
 * Immer E_OK, weil nichts schieflaufen kann.
 */
#pragma warn -par
LONG set_amtime(DIRENTRY *entry, LONG set_atime, LONG unused)
{
	if (set_atime)
	{
		entry->de_xattr.st_atim.u.d.time = Tgettime();
		entry->de_xattr.st_atim.u.d.date = Tgetdate();
	}
	else
	{
		entry->de_xattr.st_mtim.u.d.time = Tgettime();
		entry->de_xattr.st_mtim.u.d.date = Tgetdate();
	}
	return(E_OK);
}
#pragma warn .par

/*
 * tostrunc
 *
 * Quetscht einen Ramdisk-Filenamen in das 8+3-Format, und zwar nach
 * folgenden Regeln:
 * - "." und ".." werden direkt �bernommen
 * - alle unerlaubten Zeichen werden durch "X" ersetzt
 * - alle Punkte, au�er dem letzten, werden durch Kommata ersetzt;
 *   ist der letzte Punkt auch das letzte Zeichen des Namens, wird
 *   er gestrichen, ist er das erste Zeichen des Namens, wird er
 *   doch in ein Komma gewandelt
 * - alle Zeichen werden in Gro�buchstaben gewandelt
 * - die ersten acht Zeichen vor dem letzten Punkt werden �bernommen
 * - die ersten drei Zeichen nach dem letzten Punkt werden �bernommen
 *   (falls es einen letzten Punkt gibt)
 *
 * Beispiele:
 * Langer Dokumentenanme.txt -> LANGERXD.TXT
 * name.mit.vielen.punkten -> NAME,MIT.PUN
 * .profile -> ,PROFILE
 * punkt.am.ende. -> PUNKT,AM
 *
 * Nat�rlich k�nnen so zwei eigentlich verschiedene Dateinamen auf
 * den selben TOS-Namen abgebildet werden, was mit nicht angepa�ten
 * Programmen durchaus Probleme bereiten kann. Der Aufwand, dieses
 * Problem absolut sicher zu umgehen, �bersteigt allerdings meiner
 * Meinung nach den m�glichen Nutzen.
 *
 * Eingabe:
 * dest: Zeiger auf den Zielnamen, hier wird also das Ergebnis der
 *       Umwandlung abgelegt.
 * src: Zeiger auf den Ursprungsnamen.
 * wildcards: Wenn ungleich Null, werden ? und * im Ursprungsnamen
 *            �bernommen, sonst durch X ersetzt.
 */
void tostrunc(char *dest, const char *src, WORD wildcards)
{
	WORD	i;
	char	*lastdot,
			temp[] = "a";

/* Nur zu Debug-Zwecken */
#ifdef DEBUG
	if (!check_name(src))
	{
		TRACE(("tostrunc: Falscher Dateiname: %S\r\n", src));
	}
#endif
	TRACE(("tostrunc: %S -> %L\r\n", src, dest));
/* "." und ".." unver�ndert kopieren */
	if (!strcmp(src, ".") || !strcmp(src, ".."))
	{
		strcpy(dest, src);
		return;
	}
/*
 * Den letzten Punkt im Namen suchen. Ist er das erste oder letzte
 * Zeichen des Namens, wird er "versteckt".
 */
	lastdot = strrchr(src, '.');
	if (lastdot != NULL)
	{
		if ((lastdot == src) || !lastdot[1])
			lastdot = NULL;
	}
/*
 * Den Zielstring vorbereiten und die ersten acht Zeichen vor dem
 * letzten Punkt einsetzen
 */
	strcpy(dest, "");
	for (i = 0; i < 8; i++)
	{
		if (!*src || (src == lastdot))
			break;
/* Punkte als Kommas eintragen */
		if (*src == '.')
			strcat(dest, ",");
		else
		{
/*
 * Unerlaubte Zeichen als "X" �bernehmen, alle anderen als
 * Gro�buchstaben in den Zielstring einsetzen. "*" und "?" werden
 * dabei in Abh�ngigkeit des Parameters wildcard behandelt.
 */
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
		}
		src++;
	}
/*
 * Gab es einen letzten Punkt, wird er jetzt samt den ersten drei
 * dahinter folgenden Zeichen (gewandelt wie oben) an den Zielstring
 * angeh�ngt.
 */
	if (lastdot)
	{
		strcat(dest, ".");
		src = lastdot;
		src++;
		for (i = 0; i < 3; i++)
		{
			if (!*src)
				break;
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
			src++;
		}
	}
}

/*
 * fill_tosname
 *
 * F�llt einen von tostrunc gelieferten Namen auf exakt 8+3 Zeichen
 * auf; tritt dabei im Namen oder in der Extension ein "*" auf, wird
 * der betroffene Teil des Filenamens ab dieser Position mit "?"
 * aufgef�llt (f�r sp�tere Vergleiche).
 *
 * Beispiele:
 * "PC.PRG" -> "PC      .PRG"
 * "FOO.C" -> "FOO     .C  "
 * "AUTO" -> "AUTO    .   "
 * "*.TXT" -> "????????.TXT"
 * "ABC*.?X*" -> "ABC?????.?X?"
 *
 * Eingabe:
 * dest: Zeiger auf Zielstring, der mindestens f�r 13 Zeichen (inkl.
 *       abschlie�endem Nullbyte) Platz bieten mu�.
 * src: Zeiger auf zu f�llenden String, der dem von tostrunc
 *      gelieferten Format entsprechen mu�.
 */
void fill_tosname(char *dest, char *src)
{
	WORD	i;
	char	*dot;

	TRACE(("fill_tosname...\r\n"));
/* "." und ".." werden direkt behandelt */
	if (!strcmp(src, "."))
	{
		strcpy(dest, ".       .   ");
		return;
	}
	if (!strcmp(src, ".."))
	{
		strcpy(dest, "..      .   ");
		return;
	}
/* Ansonsten den Zielstring mit einem leeren Namen belegen */
	strcpy(dest, "        .   ");
/*
 * Alle Zeichen bis zum Punkt werden an den Anfang von dest kopiert
 */
	dot = strchr(src, '.');
	for (i = 0; *src && (src != dot); i++)
		dest[i] = *src++;
/*
 * Alle Zeichen nach dem Punkt (sofern es einen gab) werden hinter
 * den Punkt des Zielstrings kopiert
 */
	if (dot != NULL)
	{
		src = ++dot;
		for (i = 0; *src; i++)
			dest[9 + i] = *src++;
	}
/*
 * Jetzt noch in beiden Namensteilen nach einem "*" suchen, wird
 * einer gefunden, wird der Rest des Teilnamens mit "?" gef�llt
 * (inklusive der Fundposition)
 */
	for (i = 0; i < 8; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(8 - i));
			break;
		}
	}
	for (i = 9; i < 12; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(12 - i));
			break;
		}
	}
	TRACE(("fill_tosname liefert: %S\r\n", dest));
}

/*
 * match_tosname
 *
 * Vergleicht zwei von fill_tosname gelieferte Namen, wobei einer von
 * beiden "?" als Wildcards enthalten darf (der andere darf sie auch
 * enthalten, hier werden sie aber als normale Zeichen angesehen).
 * Diese Funktion stellt den Maskenvergleich f�r sfirst/snext dar und
 * arbeitet zuverl�ssiger als manche GEMDOS-Version (bei denen laut
 * Profibuch z.B. "A*.**" auf alle Dateien pa�t).
 *
 * Eingabe:
 * to_check: Zu �berpr�fender Dateiname, im fill_tosname-Format.
 * sample: Vergleichsname, ebenfalls im fill_tosname-Format, der "?"
 *         als Wildcards enthalten darf.
 *
 * R�ckgabe:
 * 0: to_check und sample sind nicht miteinander vereinbar.
 * 1: to_check pa�t zu sample.
 */
WORD match_tosname(char *to_check, char *sample)
{
	WORD	i;

	TRACE(("match_tosname: %S, %S\r\n", to_check, sample));
/*
 * Es werden einfach der Reihe nach alle Zeichen der Namen verglichen
 * (hier wird der Vorteil des von fill_tosname erzeugten Formats
 * deutlich). Ist an der aktuellen Stelle in sample ein "?" zu
 * finden, wird nicht verglichen, womit die Wildcardfunktion einfach
 * erf�llt ist. Beim ersten fehlgeschlagenen Vergleich wird die
 * Funktion vorzeitig verlassen.
 */
	for (i = 0; i < 12; i++)
	{
		if (sample[i] != '?')
			if (sample[i] != to_check[i])
			{
				TRACE(("Warnix\r\n"));
				return(0);
			}
	}
	TRACE(("Alles klar, pa�t\r\n"));
	return(1);
}

/*
 * xext enth�lt die Filenamensendungen (verkehrt herum), bei denen
 * beim Anlegen in der TOS-Domain automatisch das x-Flag f�r
 * "Ausf�hrbar" gesetzt wird
 */
static char const xext[][5] = {
	"sot.",
	"ptt.",
	"grp.",
	"ppa.",
	"ptg.",
	"cca."
};

/*
 * has_xext
 *
 * Diese Funktion pr�ft, ob ein Filename eine Extension hat, die
 * normalerweise ein ausf�hrbares Programm kennzeichnet. Dieser Test
 * schl�gt immer fehl, wenn gerade die MiNT-Domain aktiv ist, weil
 * solche Programme die Flags f�r "ausf�hrbar" selbst setzen sollten.
 * Die Vergleichsnamen sind oben im Array xext festgelegt.
 *
 * Eingabe:
 * name: Zeiger auf zu �berpr�fenden Filenamen.
 *
 * R�ckgabe:
 * 0: name hat keine passende Extension bzw. die MiNT-Domain ist
 *    aktiv
 * 1: Die TOS-Domain ist aktiv und name hat eine passende Endung.
 */
WORD has_xext(const char *name)
{
	char temp[RAM_MAXFNAME + 1];
	WORD	i;

	if (p_Pdomain(-1) == 1)
		return(0);
	strncpy(temp, name, RAM_MAXFNAME);
	temp[RAM_MAXFNAME] = 0;
	strrev(temp);
	for (i = 0; i < (sizeof(xext) / sizeof(xext[0])); i++)
	{
		if (!strnicmp(temp, xext[i], 4))
		{
			return(1);
		}
	}
	return(0);
}

/*
 * Kmalloc
 *
 * Funktion, die dauerhaften Speicher anfordert, der also nur durch
 * ein explizites Kfree (nur ein Makro f�r _Mfree) wieder freigegeben
 * wird. G�be es diese M�glichkeit in MagiC nicht, w�re ein XFS wie
 * dieses nutzlos, weil bei einem Programmende der Teil der Daten,
 * der von diesem Programm angelegt wurde, wieder verschwinden w�rde.
 * Der Name ist nicht nur zuf�llig an den der Funktion aus der MiNT-
 * Kernelstruktur angelehnt...
 * Die Funktion achtet au�erdem darauf, da� der gr��te freie
 * Speicherblock die in leave_free festgelegte Mindestgr��e nicht
 * unterschreitet und fordert immer den durch ram_type festgelegten
 * Speichertyp an. Wenn m�glich, wird der neue Block am Ende des
 * zur Zeit gr��ten freien Blocks alloziert, um die Fragmentierung
 * des freien Speichers zu entsch�rfen.
 *
 * Eingabe:
 * len: Wieviele Bytes sollen belegt werden, bei -1L wird die L�nge
 *      des gr��ten zusammenh�ngenden Speicherblocks abz�glich der
 *      freizuhaltenden Bytes geliefert (ggf. 0L).
 *
 * R�ckgabe:
 * Zeiger auf den allozierten Speicherblock, oder NULL.
 */
void *Kmalloc(LONG len)
{
	LONG	free,
			new_free;
	void	*block,
			*temp;

/* L�nge des gr��en verf�gbaren Speicherblocks ermitteln */
	free = (LONG)_Mxalloc(-1L, ram_type);
	if (len == -1)
	{
/*
 * Soll die Zahl der f�r die Ramdisk noch freien Bytes geliefert
 * werden, mu� von der gerade ermittelten Zahl noch die Anzahl der
 * mindestens freizuhaltenden Bytes abgezogen werden. Ggf. ist das
 * Ergebnis Null.
 */
		if (free < leave_free)
			return(0L);
		return((void *)(free - leave_free));
	}
/*
 * Wenn noch soviel Speicher am St�ck frei ist, da� nach Abzug des
 * zu allozierenden Speichers immer noch mehr als leave_free �brig
 * bleibt, wird versucht, den neuen Block am Ende dieses St�cks zu
 * belegen, um eine �berm��ige Fragmentierung zu vermeiden. Vorsicht:
 * Sehr stark auf die MagiC-Speicherverwaltung zugeschnitten und
 * nicht unbedingt zur Nachahmung empfohlen.
 */
	if ((free - leave_free) >= (len + 16))
	{
		temp = _Mxalloc(free - len - 16, ram_type);
		if (temp != NULL)
		{
			block = _Mxalloc(len, 0x4000 | ram_type);
			Kfree(temp);
			if (block != NULL)
				return(block);
		}
	}
/*
 * Versuchen, einen Block der gew�nschten Gr��e anzufordern; klappt
 * das nicht, mu� NULL geliefert werden
 */
	if ((block = _Mxalloc(len, 0x4000 | ram_type)) == NULL)
		return(NULL);
/*
 * Sonst pr�fen, ob sich die L�nge des gr��ten verf�gbaren
 * Speicherblock ge�ndert hat. Falls nicht, kann der Block so als
 * Ergebnis geliefert werden. Dabei wird absichtlich nicht gepr�ft,
 * ob der gr��te verf�gbare Block noch gro� genug ist, da seine L�nge
 * durch unser Mxalloc ohnehin nicht beeinflu�t wurde.
 */
	new_free = (LONG)_Mxalloc(-1L, ram_type);
	if (new_free == free)
		return(block);
/*
 * Hat sich die Gr��e jedoch ver�ndert, mu� der neue Wert noch gro�
 * genug sein. Falls nicht, wird der Block wieder freigegeben und
 * NULL geliefert.
 */
	if (new_free < leave_free)
	{
		Kfree(block);
		return(NULL);
	}
/* Ansonsten ist alles OK, der Block ist damit das Ergebnis */
	return(block);
}

/*
 * Krealloc
 *
 * Funktion, um einen Speicherblock auf eine neue Gr��e zu bringen.
 * Dabei bleibt der alte Inhalt intakt (nat�rlich nur bis zum
 * Minimum aus alter und neuer L�nge).
 *
 * Eingabe:
 * ptr: Bisheriger Zeiger auf den Speicherblock.
 * old_len: Alte L�nge des Blocks.
 * new_len: Neue L�nge des Blocks.
 *
 * R�ckgabe:
 * Entweder Zeiger auf neuen Speicherblock in gew�nschter Gr��e, oder
 * NULL. In letzterem Fall ist der alte Pointer weiterhin g�ltig,
 * der Inhalt unver�ndert.
 */
void *Krealloc(void *ptr, LONG old_len, LONG new_len)
{
	char *new_ptr;

/*
 * Versuchen, einen Speicherblock der neuen Gr��e anzufordern;
 * notfalls gleich NULL liefern
 */
	if ((new_ptr = Kmalloc(new_len)) == NULL)
		return(NULL);
/*
 * Alle Bytes des alten Blocks, die in den neuen Block passen,
 * dorthin kopieren
 */
	memcpy(new_ptr, ptr, (old_len < new_len) ? old_len : new_len);
/* Bei Bedarf den noch freien Bereich des neuen Blocks l�schen */
	if (new_len > old_len)
	{
		(kernel->fast_clrmem)(&new_ptr[old_len],
			&new_ptr[new_len - 1L]);
	}
/* Alten Pointer freigeben */
	Kfree(ptr);
	return(new_ptr);
}

#ifdef DEBUG

#include <mint/arch/nf_ops.h>

#undef O_RDWR
#undef O_APPEND
#undef O_CREAT
#define O_RDWR		0x02
#define O_APPEND	0x08
#define O_CREAT		0x200

/*
 * trace
 *
 * Hilfsfunktion f�r Debuggingzwecke, die �ber die Kernelfunktion
 * _sprintf einen Ausgabestring erzeugt und diesen dann in das
 * Logfile schreibt.
 *
 * Eingabe:
 * format: Formatstring, wie in der MagiC-Doku beschrieben.
 * params: Anzahl der Parameter, die noch folgen.
 * ...: Die Parameter f�r den Formatstring, soweit n�tig.
 */
void trace(const char *format, ...)
{
	va_list		args;
	static char	output[512];

	va_start(args, format);
	(kernel->_sprintf)(output, format, (LONG *)args);
	va_end(args);
	if (debug_to_screen)
		Cconws(output);
	else
	{
#if 1
		LONG		err;
		WORD		handle;

		if ((err = Fopen(logfile, O_RDWR|O_APPEND|O_CREAT)) >= 0L)
		{
			handle = (WORD)err;
			Fwrite(handle, strlen(output), output);
			Fclose(handle);
		}
		else
			Cconws(output);
#else
		nf_debugprintf("%s", output);
#endif
	}
}
#endif /* DEBUG */

/*
 * get_cookie
 *
 * Pr�ft, ob ein bestimmter Cookie vorhanden ist
 * und liefert, wenn gew�nscht, dessen Wert.
 *
 * Eingabe:
 * cookie: Zu suchender Cookie (z.B. 'MiNT')
 * value: Zeiger auf einen vorzeichenlosen Long,
 *        in den der Wert des Cookies geschrieben
 *        werden soll. Ist dies nicht gew�nscht/
 *        erforderlich, einen Nullzeiger �ber-
 *        geben.
 *
 * R�ckgabe:
 * 0: Cookie nicht vorhanden, value unbeeinflu�t
 * 1: Cookie vorhanden, Wert steht in value (wenn
 *    value kein Nullpointer ist)
 */
WORD get_cookie(ULONG cookie, ULONG *value)
{
    LONG    *jar,
            old_stack;
    
    /*
     * Den Zeiger auf den Cookie-Jar ermitteln,
     * dabei ggf. in den Supervisor-Modus
     * wechseln.
     */
    if (Super((void *)1L) == 0L)
    {
        old_stack = Super(0L);
        jar = *((LONG **)0x5a0L);
        Super((void *)old_stack);
    }
    else
        jar = *(LONG **)0x5a0;
    
    /*
     * Ist die "Keksdose" leer, gleich Null zu-
     * r�ckliefern, da ja gar kein Cookie
     * vorhanden ist.
     */
    if (jar == 0L)
        return(0);
    
    /*
     * Sonst den Cookie-Jar bis zum Ende durch-
     * suchen und im Erfolgsfall 1 zur�ckliefern.
     * Falls value kein Nullpointer war, vorher
     * den Wert des Cookies dort eintragen.
     */
    while (jar[0])
    {
        if (jar[0] == cookie)
        {
            if (value != 0L)
                *value = jar[1];
            
            return(1);
        }
        
        jar += 2;
    }
    /*
     * Bis zum Ende gesucht und nichts gefunden,
     * also 0 zur�ckgeben.
     */
    return(0);
}

/* EOF */
