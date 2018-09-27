/*
*
* Binding fÅr die Benutzung einer "shared library"
*
* Andreas Kromke
* 22.10.97
*
*/

#include <tos.h>

/*****************************************************************
*
* ôffnet eine "shared lib".
*
* Eingabe:
*	name			Name der Bibliothek inkl. Extension.
*	path			Suchpfad mit '\', optional
*	min_ver		Minimale benîtigte Versionsnummer
* RÅckgabe:
*	sl			Bibliotheks-Deskriptor
*	fn			Funktion zum Aufruf einer Bibliotheksfunktion
*	<ret>		tatsÑchliche Versionsnummer oder Fehlercode
*
*****************************************************************/

LONG Slbopen( char *name, char *path, LONG min_ver,
				SHARED_LIB *sl, SLB_EXEC *fn,
				LONG param )
{
	return(gemdos(0x16, name, path, min_ver, sl, fn, param));
}


/*****************************************************************
*
* Schlieût eine "shared lib".
*
* RÅckgabe:
*	<ret>		EACCDN, falls Lib nicht geîffnet
*
*****************************************************************/

extern LONG Slbclose( SHARED_LIB sl )

{
	return(gemdos(0x17, sl));
}
