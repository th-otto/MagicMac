/*
*
* Header fÅr eine "shared library"
* Wird statt des Start-Codes von PureC verwendet
*
* Es sollte _dringend_ sichergestellt werden, daû Bit 3
* der Flags im Programmheader gesetzt ist, damit sich die
* Bibliothek nicht den gesamten freien Speicher reserviert.
*
* Andreas Kromke
* 22.10.97
*
*/

	XREF	slb_init
	XREF slb_exit
	XREF slb_open
	XREF slb_close
	XREF	slb_fn0,slb_fn1,slb_fn2,slb_fn3,slb_fn4

	TEXT

DC.L		$70004afc			; magischer Wert
DC.L		name				; Zeiger auf Namen der Bibliothek
DC.L		1				; Versionsnummer
DC.L		0				; Flags, z.Zt. 0L
DC.L		slb_init			; wird nach dem Laden aufgerufen
DC.L		slb_exit			; wird vor dem Entfernen aufgerufen
DC.L		slb_open			; wird beim ôffnen aufgerufen
DC.L		slb_close			; wird beim Schlieûen aufgerufen
DC.L		0				; Zeiger auf Prozedurnamen (optional)
DC.L		0,0,0,0,0,0,0,0	; unbenutzt, immer NULL
DC.L		5				; Anzahl der Funktionen
DC.L		slb_fn0			; Funktion #0
DC.L		slb_fn1			; Funktion #1
DC.L		slb_fn2			; Funktion #2
DC.L		slb_fn3			; Funktion #3
DC.L		slb_fn4			; Funktion #4

name:		DC.B	'LOAD_IMG.SLB',0

	END