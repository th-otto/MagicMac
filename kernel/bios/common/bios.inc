
;OSHEADER structure
os_version     EQU  2
os_start       EQU  4
os_base        EQU  8
os_membot      EQU  $c
os_shell       EQU  $10
os_magic       EQU  $14
os_gendat      EQU  $18
os_palmode     EQU  $1c
os_gendatg     EQU  $1e
os_root        EQU  $20
os_kbshift     EQU  $24
os_run         EQU  $28

;IOREC structure
ibuf              EQU 0
ibufsiz           EQU 4
ibufhd            EQU 6
ibuftl            EQU 8
ibuflow           EQU 10
ibufhi            EQU 12

; Country- Codes laut Atari Doku
	include "country.inc"

;Funktionsnummern
FLOPRD         EQU  8
FLOPWR         EQU  9
FLOPFMT        EQU  10
FLOPVER        EQU  19
FLOPRATE       EQU  41
DMAREAD        EQU  42
DMAWRITE       EQU  43
