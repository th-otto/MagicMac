#include <tos.h>
#include <stddef.h>
#include "filediv.h"

/* vereinfachte Variante von FILEDIV.C */

/*----------------------------------------------------------------------------------------*/
/* Atari-Datei laden																	  */
/* Der Speicher fuer die Datei wird mit Malloc_sys angefordert							  */
/* Funktionsresultat:	Zeiger auf die Datei oder 0L (Fehler)							  */
/* name:						absoluter Pfad mit Dateinamen							  */
/* length:					Zeiger auf Langwort fuer die Dateilaenge					  */
/*----------------------------------------------------------------------------------------*/
unsigned char *load_file(const char *filename, long *length)
{
	#define	LF_FLAGS	FA_CHANGED|FA_RDONLY|FA_HIDDEN|FA_SYSTEM	/* Flags fuer Fsfirst() */

	DTA *old_dta;
	DTA dta;
	unsigned char *addr = NULL;

	old_dta = Fgetdta();													/* Adresse der bisherigen DTA */
	Fsetdta(&dta);														/* neue DTA setzen */
	
	if (Fsfirst(filename, LF_FLAGS) == 0)							/* Datei vorhanden? */
	{
		addr = (unsigned char *)Malloc_sys(dta.d_length);
		if (addr != NULL)
		{
			/* BINEXACT: order of parameter loading different */
			*length = read_file(filename, addr, 0, dta.d_length);
			if (*length != dta.d_length)							/* Datei unvollstaendig?	*/
			{
				Mfree_sys(addr);
				addr = NULL;
			}
		}
	}
	Fsetdta(old_dta);													/* alte DTA setzen */
	
	return addr;														/* Adresse zurueckgeben */

	#undef LF_FLAGS
}


/*----------------------------------------------------------------------------------------*/
/* Atari-Dateiabschnitt laden                                                             */
/* Funktionsresultat:   Laenge der eingelesenen Daten                                     */
/* name:                        Name der Datei                                            */
/*  dest:                       Zieladresse der Daten                                     */
/*  offset:                 Abstand vom Anfang der Datei                                  */
/*  len:                        Laenge der einzulesenden Daten                            */
/*----------------------------------------------------------------------------------------*/
long read_file(const char *filename, void *dest, long offset, long len)
{
	long fd;
	long retsize = 0;
	
	fd = Fopen(filename, FO_READ);									/* Datei oeffnen */
	if (fd > 0)														/* Datei offen? */
	{
		Fseek(offset, (short)fd, SEEK_SET);							/* Position relativ zum Dateianfang	*/
		retsize = Fread((short)fd, len, dest);						/* Daten einlesen */
		Fclose((short)fd);											/* Datei schliessen */
	}

	return retsize;													/* Anzahl der eingelesenen Bytes */
}
