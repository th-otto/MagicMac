Andreas Kromke
2018-05-02


SRC/
	MagiC kernel sources (AES).
	Most source files are converted to UTF-8.

	WARNING:
		Use "atari-utf8-conversion" or command line program "recode" to convert
		to AtariST charset before processing with native Atari toolchain!

	NOTE:
		Do not get confused by the Hebrew letters, the UTF-8 editor will change
		their read direction when displaying or editing it, causing the cursor to jump.

SRC/FSEL/
	File selector sources, written in C, converted to UTF-8

SRC/FSEL/FRA
	French localisation

SRC/FSEL/GER
	German localisation

SRC/FSEL/US
	English localisation

SRC/WDIALOG
	windows dialogue sources, including font selector
	written in C, by Sven und Wilfried Behne
	coded in AtariST charset (not UTF-8)

SRC/XMEN_MGR
	Menu manager, providing sub-menus


BUILD/
	AFRGMAC.BTP		Batch file to process a single assembler file for Mac (MAC) and with German (FRG) localisation
	AS_ALL.BAT		Batch file to process every assembler file for German localisation (GER or FRG)
