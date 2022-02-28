**********************************************************************
**********************************************************************
*
* DATA
*
* keyboard tables
*

default_keytblx:
 DC.L     tab_unshift
 DC.L     tab_shift
 DC.L     tab_caps
 DC.L     tab_altgr
 DC.L     tab_shaltgr
 DC.L     tab_capsaltgr
 DC.L     tab_alt
 DC.L     tab_shalt
 DC.L     tab_capsalt
 IFNE DEADKEYS
 DC.L     tab_dead
 ENDC

 IFNE MILANCOMP
U2B  EQU  $5e       ; statt ~ ($7e, Atari-Tastatur)
S2B  EQU  $f8       ; statt | ($7c, Atari-Tastatur)
S29  EQU  $ba       ; statt ^ ($5e, Atari-Tastatur)
 ELSE
U2B  EQU  $7e
S2B  EQU  $7c
S29  EQU  $5e
 ENDC

XXX  EQU  $00       ; must not be assigned (shift keys etc.)
YYY  EQU  XXX       ; is unassigned


 IF COUNTRY=COUNTRY_US
 IFNE MAGICPC
 INCLUDE "..\bios\keytable\us-mgpc.inc"
 ELSE
 INCLUDE "..\bios\keytable\us.inc"
 ENDC
 ENDC

 IF COUNTRY=COUNTRY_DE
 INCLUDE "..\bios\keytable\de.inc"
 ENDC

 IF COUNTRY=COUNTRY_FR
 IFNE MAGICPC
 INCLUDE "..\bios\keytable\fr-mgpc.inc"
 ELSE
 INCLUDE "..\bios\keytable\fr.inc"
 ; INCLUDE "..\bios\keytable\fr-pc.inc"
 ENDC
 ENDC

 IF COUNTRY=COUNTRY_UK
 INCLUDE "..\bios\keytable\uk.inc"
 ENDC

 IF COUNTRY=COUNTRY_ES
 INCLUDE "..\bios\keytable\es.inc"
 ENDC

 IF COUNTRY=COUNTRY_IT
 INCLUDE "..\bios\keytable\it.inc"
 ENDC

 IF COUNTRY=COUNTRY_SE
 INCLUDE "..\bios\keytable\se.inc"
 ENDC

 IF COUNTRY=COUNTRY_SF
 INCLUDE "..\bios\keytable\sf.inc"
 ENDC

 IF COUNTRY=COUNTRY_SG
 INCLUDE "..\bios\keytable\sg.inc"
 ENDC

 IF COUNTRY=COUNTRY_TR
 INCLUDE "..\bios\keytable\tr.inc"
 ENDC

 IF COUNTRY=COUNTRY_FI
 INCLUDE "..\bios\keytable\fi.inc"
 ENDC

 IF COUNTRY=COUNTRY_NO
 INCLUDE "..\bios\keytable\no.inc"
 ENDC

 IF COUNTRY=COUNTRY_DK
 INCLUDE "..\bios\keytable\dk.inc"
 ENDC

 IF COUNTRY=COUNTRY_CZ
 INCLUDE "..\bios\keytable\cz_iso.inc"
 ENDC

 EVEN
