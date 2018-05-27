Andreas Kromke
2018-05-27

All VDI related files are written by Sven and Wilfried Behne, except some patches, see below.
Note that VDI for MagiC is often called MVDI, contrary to NVDI.


BIN/
	VDI object files to be linked into kernel

DRIVERS/
	Drivers for Atari and Mac, to be loaded at runtime from the appropriate paths

DRIVERS/OSD.TXT
	Original mail from Wilfried Behne describing the naming scheme of .OSD and .SYS files.
	Note that .OSD files can be replaced by .NOD files from NVDI to get significantly faster graphics.
	Rough translation:

	MFA*.SYS : Screen drivers for ST/TT/Falcon/MagicPC
	MFM*.SYS : Screen drivers for MagicMac [and MagicMacX/AtariX]

	4IP : 4 colours, interleaved plane (ST Mid)
	MFA4IP.SYS : is obviously the 4-colour-driver for Atari
	MFM4IP.SYS : pendant for MagicMac, without hardware register access

	*.OSD : offscreen divers. Necessary drivers are in MIN_ATAR/, others are desirable.

	MagicMac needs all drivers from OSD/ and all from MIN/ATAR


Important notes:

	The driver "MFM16M.SYS" has an annoying bug. I patched it and put the result to MAC-patched/.
	I remember a wrong mask 0x1fff or similar, but but not the details.

	MXVDIKNP.O seems to be a patched version from MXVDIKNL.O. Its timestamp (2001-09-03)
	 is newer than those of the other files (1996-05-17 and 1998-02-06). Is is referred to
	 by the latest linker input files (.INP) and is most probably needed for MagicMacX/AtariX.
	 A binary diff reveals that I replaced two 68k instructions by NOPs.

