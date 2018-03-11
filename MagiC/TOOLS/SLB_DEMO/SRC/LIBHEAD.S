/*
*
* Header fÅr eine "shared library"
* Wird statt des Start-Codes von PureC verwendet
*
* Es sollte _dringend_ sichergestellt werden, daû Bit 3
* der Flags im Programmheader gesetzt ist, damit sich die
* Bibliothek nicht den gesamten freien Speicher reserviert.
*
* Achtung: Das SLB-Konzept von MagiC 5.20 hatte noch einen
* Fehler, den ich in 6.00 behoben habe. Dazu muûte der
* Aufbau leicht modifiziert werden. SLBs fÅr MagiC 6 laufen
* daher nicht mit solchen fÅr MagiC 5.20 und umgekehrt.
*
* Andreas Kromke
* 10.2.98
*
* Achtung: Der Dateiname (s.u.) muû exakt dem tatsÑchlichen
* Namen auf der Festplatte entsprechen, da andernfalls die
* SLB mehrfach geladen wird (wird dann im Speicher nicht
* gefunden)!
*
*/

	XREF	slb_init
	XREF slb_exit
	XREF slb_open
	XREF slb_close
	XREF	slb_fn0

	TEXT

DC.L		$70004afc			; magischer Wert (5.20: $42674e41)
DC.L		name				; Zeiger auf Namen der Bibliothek
DC.L		1				; Versionsnummer
DC.L		0				; Flags, z.Zt. 0L
DC.L		slb_init			; wird nach dem Laden aufgerufen
DC.L		slb_exit			; wird vor dem Entfernen aufgerufen
DC.L		slb_open			; wird beim ôffnen aufgerufen
DC.L		slb_close			; wird beim Schlieûen aufgerufen
DC.L		0				; Zeiger auf Prozedurnamen (optional)
DC.L		0,0,0,0,0,0,0,0	; unbenutzt, immer NULL
DC.L		1				; Anzahl der Funktionen (5.20: .W)
DC.L		slb_fn0			; Funktion #0

name:		DC.B	'SLB_DEMO.SLB',0

	END