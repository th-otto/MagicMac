öbersicht Åber die MagiC Dokumentation
======================================

Stand: 5.6.99

1. AES
------

DRAGDROP\			Routinen fÅr das Drag&Drop-Konzept von MultiTOS
				(etwas Ñlter, daher ohne MT_AES)
EDSCROLL\			Ein vollstÑndiges Beispielprogramm fÅr den 
				Gebrauch scrollender Eingabefelder
				(etwas Ñlter, ab MagiC 3)
FSLX\			vollstÑndige Dokumentation und ein 
				Beispielpgrogramm zum Gebrauch der erweiterten 
				Dateiauswahl-Funktionen, u.a. im Fenster.
				(neue Version, mit MT_AES).
MAGXLIB\			Eine etwas Ñltere Bibliothek mit drei MagiC-
				spezifischen Funktionen, wird fÅr die scrollbaren 
				Edit-Felder benîtigt.
MOD_APP\			Dienstprogramm und Dokumentation zur Manipulation 
				der APPLICAT.INF fÅr Installationsprogramme zur 
				automatischen Zuweisung von Dateitypen und Icons.
MT_AES\			vollstÑndige reentrante (!) AES-Bibliothek fÅr 
				PureC. Wird fÅr alle MT-Programme (multi 
				threaded) benîtigt, die AES aufrufen.
				(wird stets aktualisiert)
WINFRAME.DEM\		Seit MagiC 6 kann ein eigener Fensterrahmen-
				Manager installiert werden. Hier ist ein 
				einfaches Beispiel, das fÅr eigene WÅnsche 
				erweitert werden kann. Es ersetzt das 
				mitgelieferte WINFRAME.SLB.
AES.TXT			ein alter Text, der verschiedene Informationen 
				Åber MagiC und AES enthÑlt, welche nicht in die 
				anderen Dokumente passen.
COLMAPIC.C		Prozedur zur Anmeldung einer eigenen Icon-
				Farbpalette.
EDITOB.TXT		VollstÑndige Dokumentation zum Edit-Objekt, das 
				ab Version 5.20 in einer SLB (EDITOBJC.SLB) 
				mitgeliefert wird und von MGEDIT und MGNOTICE 
				verwendet wird. Es handelt sich um ein einfaches, 
				mehrzeiliges Editfeld.
OBTYPES.TXT		aktuelle Beschreibung aller AES-Objekte inklusive 
				aller Statusbits usw. Leider nicht ganz 
				vollstÑndig, enthÑlt aber alle MagiC-
				Besonderheiten.
SINGLE.TXT		Eine Ñltere Beschreibung des "single mode"
THREADS.TXT		Eine vollstÑndige, aktuelle und ausfÅhrliche 
				Beschreibung des Thread-Konzepts.
WDIALOG.TXT		Beschreibung der Fensterdialoge, der 
				Zeichensatzauswahl und der Druckdialoge (von 
				Sven & Wilfried Behne).
WINDFUN.TXT		Beschreibung der fensterorientierten 
				Zeichenfunktionen (objc_wdraw() usw.).

2. DEV_LPT1
-----------

Quelltext fÅr einen Druckertreiber, der Hintergrundtransfer unterstÅtzt,
als Beispiel fÅr einen MagiC-GerÑtetreiber


3. DOS
------

MT_DOS\			MT-sicheres Binding fÅr GEMDOS-Aufrufe, die in 
				der PCTOSLIB von PureC fehlen (mit Quelltext).

LONGFNAM.TXT		Richtlinien zum UnterstÅtzen von langen Dateinamen
MGX_DOS.TXT		Beschreibung aller GEMDOS-Aufrufe
PCMXSTRT.O		PureC-Startcode fÅr lange Dateinamen
PCMXSTRT.S		Quelltext dazu
PIPES.TXT			Beschreibung des Pipe-Konzepts
SHARELIB.TXT		Beschreibung des "shared library"-Konzepts
SIGNALE.TXT		Beschreibung des "signal"-Konzepts
VFATCONF.TXT 		Beschreibung des gleichnamigen Programms


4. FILESYS 
----------

MGX_DEVD.H		'C'-Header fÅr MagiC-GerÑtetreiber
MGX_DEVD.INC		dito fÅr Assembler
MGX_DFS.H			'C'-Header fÅr MagiC-DFS-Dateisystemtreiber
MGX_DFS.INC		dito fÅr Assembler
MGX_DFS.TXT		Beschreibung des DFS-Konzepts (einschl. DOS-
				GerÑtetreiber, z.B. in U:\dev)
MGX_HDD.TXT		Informationen fÅr Hintergrund-Plattentransfer
MGX_UDFS.TXT		Beschreibung des Laufwerks U:
MGX_XFS.H			'C'-Header fÅr MagiC-XFS-Dateisystemtreiber
MGX_XFS.INC		dito fÅr Assembler
MGX_XFS.TXT		Beschreibung des XFS-Konzepts 
				(einschl. GerÑtetreiber, Kernelfunktionen)


5. HEADERS
----------

MGX_DOS.H			Ersatz fÅr TOS.H.


6. MXDEV_DK
-----------

Dateien fÅr die Entwicklung eines GerÑtetreibers.


7. MXXFS_DK\
------------

Dateien fÅr die Entwicklung eines XFS-Treibers in 'C'. Hier ist ein 
Umsetzer von Assembler in 'C' eingebaut. Entstanden sind die Dateien 
bei Entwicklung des SPIN!-Treibers fÅr MagiC.


8. SLB_DEMO\
------------

Beispielprogramm fÅr das "shared library"-Konzept. Die SLB_xxxx-
Dateien gehîren zur Bibliothek selbst, die SLC_xxxxx-Dateien zum 
Aufrufprogramm ("client").


9. Diverse
----------

CMD.DOC			Beschreibung von (M)CMD.TOS
FATALERR.TXT		Beschreibung aller "System angehalten"-Meldungen
PROBLEME.TXT		Probleme ab MagiC 5 (teilw. InkompatibilitÑten)
README.TXT		diese Datei
SHUTDOWN.TXT 		Beschreibung des Shutdown-Mechanismus