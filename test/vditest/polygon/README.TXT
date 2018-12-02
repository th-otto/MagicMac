Demonstration Bildschirmtreiberfehler bei gefüllten Polygonen
=============================================================

Das Programm POLYGON malt in verschiedenen Modi und Füllmustern Dreiecke
auf den Bildschirm. Es kann einfach ohne Parameter gestartet werden.

Die Verwendung eines benutzerdefinierten Füllmusters führt offenbar in
einigen Konfigurationen zum Absturz oder zu unschönen Ergebnissen. Ich habe, da
ich das Programm in verschiedenen Auflösungen getestet habe, nur den Fall des
einfarbigen Füllmusters verwendet, aber die Variante mit 32 Bit führt
im True-Colour-Modus auch zum Absturz.

Hier die Ergebnisse im einzelnen:

MagicMacX mit MagiC-VDI, 16M Farben			Emulator-Absturz
MagicMacX mit MagiC-VDI, 32k Farben			Emulator-Absturz
MagicMacX mit MagiC-VDI, 256 Farben			OK
MagicMac mit NVDI, 16M Farben				OK
MagicMac mit NVDI, 32k Farben				totaler Systemabsturz von OS 9
MagicMac mit NVDI, 256 Farben				vermatschte Ausgabe


Offenbar haben also verschiedene Bildschirmtreiber Probleme mit benutzerdefiniert
gefüllten Polygonen. Könnt Ihr das zumindest für die MagiC-VDI-Treiber beheben?
