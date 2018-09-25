Andreas Kromke
2018-05-06


ATARI/
	BIOS sources for Atari (Mega)ST(e), Atari TT, Atari Falcon, Hades and MagicPC

MAGICMAC
	BIOS sources for MagicMac (classic Mac OS)

MAGCMACX
	BIOS sources for MagicMacX

COMMON/
	BIOS sources used by more than one platform
	PROTOBT.S is only used for MagicMac and MagicMacX

XFS95/
	Code for MagicPC, provided by Franz Schmerbeck


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
     		INCLUDE "IVID.S"		only for Atari
     		INCLUDE "HAD_IVID.S"	only for Hades
     INCLUDE "KEYB.S"
            INCLUDE "HANDLKEY.S"
     INCLUDE "FDC.S"				only for Atari
     INCLUDE "COOK.S"				only for Atari
     INCLUDE "HAD_FDC.S"			only for Hades
     INCLUDE "HAD_COOK.S"			only for Hades
     INCLUDE "HAD_SCSI.S"			only for Hades
     INCLUDE "UNIM_INT.S"			only for Hades
     INCLUDE "HAD_EXC.S"			only for Hades


	MAGICMAC/MAC_BIOS.S

     INCLUDE "LOWMEM.INC"
     INCLUDE "BIOS.INC"
     INCLUDE "DOS.INC"
     INCLUDE "ERRNO.INC"
     INCLUDE "KERNEL.INC"
     INCLUDE "MAC_KER.INC"
     INCLUDE "DEBUG.INC"
     INCLUDE "AUTO.S"
     INCLUDE "PUNTAES.S"
     INCLUDE "PROTOBT.S"
     INCLUDE "PRIV_EXC.S"
     INCLUDE "HANDLKEY.S"


	MAGCMACX/MACXBIOS.S

     INCLUDE "LOWMEM.INC"
     INCLUDE "BIOS.INC"
     INCLUDE "DOS.INC"
     INCLUDE "ERRNO.INC"
     INCLUDE "KERNEL.INC"
     INCLUDE "MACXKER.INC"
     INCLUDE "DEBUG.INC"
     INCLUDE "AUTO.S"
     INCLUDE "PUNTAES.S"
     INCLUDE "DRIVE.S"
     INCLUDE "PROTOBT.S"
     INCLUDE "PRIV_EXC.S"
     INCLUDE "HANDLKEY.S"

	MILAN/MILNBIOS.S

     INCLUDE "DOS.INC"
     INCLUDE "ERRNO.INC"
     INCLUDE "KERNEL.INC"
     INCLUDE "MILAN.INC"
     INCLUDE "BIOS.INC"
     INCLUDE "LOWMEM.INC"
     INCLUDE "DEBUG.INC"
     INCLUDE "AUTO.S"
     INCLUDE "PUNTAES.S"
     INCLUDE "HANDLKEY.S"


	COMMON/AUTO.S

	 INCLUDE "READ_KTB.S"


All BIOS sources are converted to UTF-8 and must be converted back to AtariST before passed to compiler or assembler.
Localisation for German, French and English

Some of the files have not or not entirely been written by me. These code parts are differently formatted,
i.e. with tab size 3 or 8 and different comments.

The file "DSP.S" seems to be based on a Facon TOS disassembly.
