/*
*
* Rumpf einer "shared library"
*
* Andreas Kromke
* 22.10.97
*
*/

#include <portab.h>
#include <tos.h>
#include <tosdefs.h>
#pragma warn -par

typedef void *PD;

char *mem;			/* hier globalen Speicher */

/*****************************************************************
*
* Die init-Funktion wird einmal beim Laden der Bibliothek
* aufgerufen. Dabei lÑuft sie im Prozeû der Bibliothek,
* d.h. es kînnen Dateien geîffnet und Speicher angefordert
* werden, die jeweils der Bibliothek gehîren.
* Achtung: Auf die dabei geîffneten Dateien darf durch die
*          Bibliotheksfunktionen _NICHT_ zugegriffen werden,
*          weil diese im Kontext des Aufrufers laufen.
*
* Achtung: Die init-Funktion lÑuft im Supervisormode, da eine
*          Bibliothek i.a. keinen Userstack hat.
*          Daher darf sie nicht zuviel Stack benutzen (max. 1kB)
*          und nicht zu lange laufen (weil das Multitasking
*          im Supervisormode blockiert ist).
*          Ggf. kann aber ein Userstack alloziert und in den
*          Usermode gewechselt werden.
*
*****************************************************************/

extern LONG cdecl slb_init( void )
{
	mem = Malloc(4096L);
	if	(mem)
		return(E_OK);
	else	return(ENSMEM);
}

/*****************************************************************
*
* Die exit-Funktion wird einmal beim Freigeben der Bibliothek
* aufgerufen. Dabei lÑuft sie im Prozeû der Bibliothek,
* d.h. es kînnen Dateien geîffnet und Speicher angefordert
* werden, die jeweils der Bibliothek gehîren.
*
* Achtung: Die exit-Funktion lÑuft im Supervisormode, da eine
*          Bibliothek i.a. keinen Userstack hat.
*          Daher darf sie nicht zuviel Stack benutzen (max. 1kB)
*          und nicht zu lange laufen (weil das Multitasking
*          im Supervisormode blockiert ist).
*          Ggf. kann aber ein Userstack alloziert und in den
*          Usermode gewechselt werden.
*
*****************************************************************/

extern void cdecl slb_exit( void )
{
	Mfree(mem);
}


/*****************************************************************
*
* Die open-Funktion wird einmal beim ôffnen der Bibliothek
* durch einen Anwenderprozeû aufgerufen. Dabei lÑuft sie im
* Prozeû des Aufrufers, d.h. es kînnen Dateien geîffnet und
* Speicher angefordert werden, die jeweils dem Aufrufer gehîren.
*
* Durch den Kernel ist sichergestellt, daû jeder Prozeû die
* Bibliothek nicht mehrmals îffnet und daû die Bibliothek immer
* ordnungsgemÑû geschlossen wird.
*
* Achtung: Die open-Funktion lÑuft im Usermode, und zwar mit dem
*          Userstack des Aufrufers. Das heiût, daû der Aufrufer,
*          auch wenn er im Supervisormode lÑuft, immer einen
*          ausreichend groûen usp zur VerfÅgung stellen muû.
*
*****************************************************************/

extern LONG cdecl slb_open( PD *pd )
{
	return(E_OK);
}


/*****************************************************************
*
* Die close-Funktion wird einmal beim Schlieûen der Bibliothek
* durch einen Anwenderprozeû aufgerufen. Dabei lÑuft sie im
* Prozeû des Aufrufers, d.h. es kînnen Dateien geîffnet bzw.
* geschlossen und Speicher angefordert und freigegeben  werden,
* die jeweils dem Aufrufer gehîren.
*
* Achtung: Die close-Funktion lÑuft im Usermode, und zwar mit dem
*          Userstack des Aufrufers. Das heiût, daû der Aufrufer,
*          auch wenn er im Supervisormode lÑuft, immer einen
*          ausreichend groûen usp zur VerfÅgung stellen muû.
*
*****************************************************************/

extern void cdecl slb_close( PD *pd )
{
}


/*****************************************************************
*
* Eine Beispiel-Bibliotheksfunktion.
* Sie wird im Kontext des Aufrufers ausgefÅhrt, und zwar mit dem
* Stack des Aufrufers (je nach Status usp oder ssp).
*
* Es wird dringend empfohlen, die Funktionen einer SLB nur im
* Usermode aufzurufen, um die KompatibilitÑt zu spÑteren
* Implementationen zu wahren.
*
*****************************************************************/

extern LONG cdecl slb_fn0( PD *pd, LONG fn, WORD nargs, char *s )
{
	Cconws(s);
	Cconws("\r\nTaste: ");
	Cconin();
	return(E_OK);
}
