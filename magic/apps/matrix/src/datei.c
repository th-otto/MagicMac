#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stddef.h>


static char path[80] = "\0", filename[20];


char *makepath(char *path, char *typ);
char *makenam(char *path, char *wahl);
int 	dateiname_ok(char extension[]);
int	save(char *name, int (*schreibe)(), char typ[]);


/********************************************************************
*
* Fileselector fÅr alle TOS- Versionen.
* Ab TOS 1.4 (AES 1.40) und nicht >= GEM 2.0 wird die öberschrift
* vewendet.
*
********************************************************************/

int fsel(char *path, char *sel, int *button, char *label)
{
	if	(_GemParBlk.global[0] < 0x0200 && _GemParBlk.global[0] >= 0x0140)
		return(fsel_exinput(path, sel, button, label));
	else return(fsel_input  (path, sel, button));
}


/********************************************************************
*
* ôffnet (liest) eine Datei ein.
* FÅr das Lesen wird die Funktion <lesen()> benutzt, die bei Fehlern
* einen Wert ungleich Null zurÅckgibt.
* Der Dateityp ist von der Form "EXT".
* Die Routine gibt FALSE zurÅck, falls korrekt gelesen wurde.
*
********************************************************************/

int oeffnen(int (*lesen)(int handle), char *dateityp)
{
	int	exit, handle, fehler;
	char *makepath(), *makenam();


	fehler = TRUE;
	again:
	makepath(path, dateityp);
	if	(fsel(path, filename, &exit, "Matrixdatei lesen..."))
		if (exit == 1) {
			if	((handle = (int) Fopen(makenam(path,filename), 0)) > 0) {
				if	( !(*lesen) (handle) )
					fehler = FALSE;		  /* alles ok */
				else form_alert(1,"[3][Datei- Lesefehler!][ABBRUCH]");
				Fclose(handle);
				}
			else {
				form_alert(1,"[3][Datei lÑût sich nicht îffnen.][ABBRUCH]");
				goto again;
				}
			}
	return(fehler);
}

/********************************************************************
*
* Speichert eine Datei, fragt vorher nach dem Namen.
* FÅr das Schreiben wird die Funktion <schreiben()> benutzt, die bei
* Fehlern einen Wert ungleich Null zurÅckgibt.
* Der Dateityp ist von der Form "EXT".
* Die Routine gibt FALSE zurÅck, falls korrekt geschrieben wurde.
*
********************************************************************/

int saveas(int (*schreibe)(int handle), char *dateityp)
{
	int	exit;
	char *makepath(), *makenam();

	again:
	makepath(path, dateityp);
	if	(fsel(path, filename, &exit, "Matrixdatei speichern..."))
		if (exit == 1) {
			if	((!dateiname_ok(dateityp)) ||
				 (save(makenam(path,filename), schreibe, dateityp)))
				goto again;
			else return(FALSE);
			}
	return(TRUE);
}


/********************************************************************
*
* Speichert eine Datei, benutzt den letzten Namen.
* FÅr das Schreiben wird die Funktion <schreiben()> benutzt, die bei
* Fehlern einen Wert ungleich Null zurÅckgibt.
* Der Dateityp ist von der Form "EXT".
* Die Routine ruft close_work() auf, falls korrekt geschrieben wurde.
*
********************************************************************/

void schliess(int (*schreibe)(), char *dateityp)
{
	extern void close_work(void);



	if	(!save(path, schreibe, dateityp))
		{
		wind_update(END_UPDATE);
		close_work();
		}
}


/********************************************************************
*
* Speichert eine Datei unter <name>, wenn <name> keine Wildcards
* enthÑlt und den korrekten Dateityp hat.
* FÅr das Schreiben wird die Funktion <schreiben()> benutzt, die bei
* Fehlern einen Wert ungleich Null zurÅckgibt.
* <typ> ist von der Form "EXT".
* Die Routine gibt FALSE zurÅck, falls korrekt geschrieben wurde.
*
********************************************************************/

int save(char *name, int (*schreibe)(int handle), char typ[])
{
	int handle;


	if	((!dateiname_ok(typ)) || strchr(name, '*') || strchr(name, '?'))
		return(TRUE);	  /* Extension stimmt nicht oder Wildcards */
	if	(Fsfirst(name, 255 ) == 0L ) {    /* Datei existiert schon */
		if	(form_alert(2, "[2][Datei öberschreiben ?][OK|ABBRUCH]") == 2)
			return(TRUE);
		if	(Fdelete(name) < 0L) {
			err: form_alert(1, "[3][Datei- Schreibfehler!][ABBRUCH]");
			return(TRUE);
			}
		}
	if	((handle = (int) Fcreate(name, 0 )) > 0 ) {
		if	( (*schreibe) (handle) ) {
			Fclose(handle);
			Fdelete(name);
			goto err;
			}
		Fclose(handle);
		}
	else goto err;
	return(FALSE);
}

/***********************************************************

Erzeugt einen Pfad mit Wildcard fÅr den Dateityp <typ>.
<typ> ist von der Form "EXT".
Beim ersten Aufruf wird der Pfad als aktueller Pfad des
 aktuellen Laufwerks gesetzt und der Wildcard- Ausdruck
 "\*.EXT" angehÑngt.
Sonst wird vom vorhandenen Pfadnamen der Dateiname bzw.
 der vorhandene Wildcard- Ausdruck entfernt und der neue
 angehÑngt.

***********************************************************/

char *makepath(char *path, char *typ)
{
		  char *ret;
	static int  init = FALSE;

	ret = path;
	if	(init) {
		path += strlen(path);
		while((path > ret) && (*(--path) != '\\'))
			;
		*path = '\0';
		}
	else {
		*path++ = Dgetdrv()+'A';
		*path++ = ':';
		Dgetpath(path, 0);
		init = TRUE;
		}
	strcat(ret, "\\*.");
	strcat(ret, typ);
	return(ret);
}

/*****************************************/

char *makenam(char *path, char *wahl)	   /* wahl an path anhÑngen */
{
 char *ret;

 ret = path;
 path += strlen( path );
 while(0 != (*--path != '\\'	 ) ) ;
 while(0 != (*++path =  *wahl++) ) ;
 return( ret );
}


/********************************************************************
*
* PrÅft, ob in filename[] die korrekte <extension> vorliegt.
* Wenn bisher "*" die Extension war, wird sie = <extension> gesetzt.
* Die Extension ist von der Form "EXT".
* Die Routine gibt TRUE zurÅck, falls alles in Ordnung ist.
*
********************************************************************/

int dateiname_ok(char extension[])
{
	register char *typ;

	if	((typ = strrchr(filename,'.')) == NULL) {
		err:
		form_alert(1,"[3][Falscher Dateityp!][ABBRUCH]");
		return(FALSE);
		}

	if	(*(++typ) == '*') {
		strcpy(typ, extension);
		}
	else {
		if	(strcmp(typ, extension))
			goto err;
		}
    return(TRUE);
}
