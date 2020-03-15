/********************************************
 *   begin options                          *
 ********************************************/
/*	Debugmodus? (=Debug Ausgaben compilieren)	*/
#define	DEBUG						OFF
/*	Debuglogbuch-Datei erstellen? (=Alle Debug Ausgaben in diese Datei)	*/
#define	DEBUG_LOG				OFF

/*	Sprache des Programms (f�r Text-Strings im Programmcode)	*/
#define	LANGUAGE				GERMAN

/*	Programm nur unter MagiC lauff�hig? (MagiC spez. Funktionen Benutzen?)	*/
#define	MAGIC_ONLY				NO

/*	VDI Workstation initialisieren?	*/
#define	USE_VDI					YES
/*	Farbpalette speichern?	*/
#define	SAVE_COLORS				NO

/*	Beim Schliessen eines Fensters (Dialog/Fenster) werden alle Strukturen 
	aus dem Speicher entfert	*/
#define	WIND_CLOSE_IS_REMOVE	NO
#define	DIAL_CLOSE_IS_REMOVE	NO

/*	Eigene Globale Tastaturkombinationen? (=ben�tigt DoUserKeybd())	*/
#define	USE_GLOBAL_KEYBOARD	YES

/*	Eigene Events abfangen?	*/
#define	USE_USER_EVENTS		NO

/*	Men�zeile installieren? (Ben�tigt eine Resource MENU)	*/
#define	USE_MENU					YES

/*	Fenster-Dialoge verwenden? (Dank WDialog)	*/
#define	USE_DIALOG				YES
/*	Normale Fenster verwenden?	*/
#define	USE_WINDOW				NO
/*	Fenster-Dateiselektor verwenden?	*/
#define	USE_FILESELECTOR		YES
/*	Fenster-Fontselektor verwenden?	*/
#define	USE_FONTSELECTOR		YES

/*	AV-Protokoll Unterst�tzung: 
		0	= deaktiviert
		1	= minimal (nur VA_START,AV_SENDCLICK und AV_SENDKEY empfangen)
		2	= normal (AV_PROTOKOL,AV_EXIT,VA_PROTOSTATUS,VA_START,
			  AV_SENDCLICK und AV_SENDKEY)
			  Also anmelden und abmelden beim AV-Server!
		3	= vollst�ndig (Empfang und Versenden aller m�glichen Nachrichten)
			  Ben�tigt die Prozedur DoVA_Message()!
*/
#define	USE_AV_PROTOCOL		1

/*	Atari Drag&Drop Protokoll Unterst�tzung	*/
#define	USE_DRAGDROP			YES

/*	Langedateinamen aktivieren (=Pdomain(PD_MINT))	*/
#define	USE_LONGFILENAMES		YES

/*	Lange Editfelder (wie sie von MagiC Unterst�tzt werden)	*/
#define	USE_LONGEDITFIELDS	YES

/*	BubbleGEM Hilfesystem	*/
#define	USE_BUBBLEGEM			YES
/*	ST-Guide Hilfesystem	*/
#define	USE_STGUIDE				YES

/*	Unterst�tzung f�r das Documen-History Protokoll	*/
#define	USE_DOCUMENTHISTORY	YES

/*	Name der Prototypen-Include-Datei angeben	*/
#define	SPEC_DEFINITION_FILE	"DEFS.H"

/*	Programmname "sch�n"	*/
#define	PROGRAM_NAME			"MagiCCfg"
/*	Programmname in Grossbuchstaben	*/
#define	PROGRAM_UNAME			"MAGICCFG"
/*	Dateiname der Resource-Datei	*/
#define	RESOURCE_FILE			"MAGICCFG.RSC"
/*	Dateiname der Resource-Header-Datei	*/
#define	RESOURCE_HEADER_FILE	"MAGICCFG.H"
/*	Dateiname der BubbleGEM-Hilfedatei	*/
#define	BUBBLEGEM_FILE			"MAGICCFG.BGH"
/*	Dateiname der ST-Guide-Hilfedatei	*/
#define	STGUIDE_FILE			"*:\\MAGICCFG.HYP "

/*	Maximale Zeilenl�nge der Konfigurationsdatei	*/
#define	CFG_MAXLINESIZE		80
/*	Soll die Konfigurationsdatei auch im HOME Verzeichnis gesucht werden?	*/
#define	CFG_IN_HOME				NO

/*	Anzahl der m�glichen Drag&Drop Formate	*/
#define	MAX_DDFORMAT			8

/*	Anzahl gleichzeitig iconifizierter Fenster	*/
#define	MAX_ICONIFY_PLACE		16
/*	Anzahl der m�glichen Rekursions-Ebenen bei Modalen Objekten	*/
#define	MAX_MODALRECURSION	1


/*	Daten f�r event_multi	*/
#define EVENTS		MU_MESAG|MU_KEYBD|MU_BUTTON
#define MBCLICKS	2|0x0100
#define MBMASK		3
#define MBSTATE	0
#define MBLOCK1	NULL
#define MBLOCK2	NULL
#define WAIT		0L

/********************************************
 *   end options                            *
 ********************************************/
