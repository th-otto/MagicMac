Andreas Kromke
2018-05-06


ATARI/
	BIOS sources for Atari (Mega)ST(e), Atari TT, Atari Falcon, and Hades

COMMON/
	BIOS sources used by more than one platform


Dependencies:

	ATARI/MAGIBIOS.S

     INCLUDE "LOWMEM.INC"
     INCLUDE "BIOS.INC"
     INCLUDE "DOS.INC"
     INCLUDE "ERRNO.INC"
     INCLUDE "KERNEL.INC"
     INCLUDE "HARDWARE.INC"
     INCLUDE "DEBUG.INC"
     INCLUDE "AUTO.S"
     INCLUDE "PUNTAES.S"
     INCLUDE "SCSI.S"
     INCLUDE "DRIVE.S"
     INCLUDE "DSP.S"
     INCLUDE "SERIAL.S"
     INCLUDE "CLOCK.S"
     INCLUDE "VIDEO.S"
     INCLUDE "KEYB.S"
     INCLUDE "FDC.S"				only for Atari
     INCLUDE "COOK.S"				only for Atari
     INCLUDE "HAD_FDC.S"			only for Hades
     INCLUDE "HAD_COOK.S"			only for Hades
     INCLUDE "HAD_SCSI.S"			only for Hades
     INCLUDE "UNIM_INT.S"			only for Hades
     INCLUDE "HAD_EXC.S"			only for Hades


	COMMON/AUTO.S

	 INCLUDE "READ_KTB.S"


All BIOS sources are converted to UTF-8 and must be converted back to AtariST before passed to compiler or assembler.
Localisation for German, French and English

