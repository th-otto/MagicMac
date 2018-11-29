;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                                                                            *;
;*                    (C) 1990-95 by Sven & Wilfried Behne                    *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Header'

;Referenzen fuers Linken von MAGX.RAM

                  .EXPORT __a_vdi
                  .EXPORT __e_vdi
                  .EXPORT vdi_blinit
                  .EXPORT vt52_init
                  .EXPORT vdi_init
                  .EXPORT vdi_entry  ;VDI-Dispatcher (wird mit rts verlassen)
                  .EXPORT int_linea  ;LINEA-Dispatcher (wird mit rte verlassen)
                  .EXPORT Blitmode   ;Xbios-Funktion Blitmode() (wird mit rte verlassen)
                  .EXPORT vdi_rawout ;Bios-Vektor $586
                  .EXPORT vdi_conout ;Bios-Vektor $592
                  .EXPORT vdi_cursor ;Bios-Cursor-Routine
                  .EXPORT vt_seq_e   ;Show cursor (VT52 ESC e)
                  .EXPORT vt_seq_f   ;Hide cursor (VT52 ESC f)

;Referenzen aus dem BIOS
                  .IMPORT  MM_init   ;VDI_SETUP_DATA   *MM_init( VDI_SETUP_DATA *in_setup );
                                     ;sorgt bei der Initialisierung fuer Kompatibilitaet zun alten MagiCMac

;sonstige Referenzen

                  .EXPORT cpu020     ;wird in MATH.S benoetigt
                  .EXPORT gdos_path

                  .EXPORT nvdi_struct
                  .EXPORT OSC_ptr
                  .EXPORT OSC_count
                  .EXPORT init_mono_NOD
                  .EXPORT clear_cpu_caches  ;fuer DRIVERS

                  .IMPORT Malloc_sys
                  .IMPORT Mfree_sys
                  .IMPORT Mshrink_sys

                  .EXPORT clear_bitmap
                  .EXPORT transform_bitmap
                  .EXPORT wk_init
                  .EXPORT wk_tab
                  .EXPORT closed
                  .IMPORT create_bitmap
                  .IMPORT delete_bitmap

                  .IMPORT init_NOD_drivers
                  .IMPORT load_NOD_driver
                  .IMPORT unload_NOD_driver
                  .IMPORT load_prg
                  .IMPORT load_file

                  .IMPORT load_MAC_driver    ;void *load_MAC_driver( VDI_DISPLAY *display, BYTE *gdos_path )
                  .IMPORT load_ATARI_driver  ;void *load_ATARI_driver( WORD res, WORD modecode, BYTE *gdos_path );

                  .IMPORT clear_mem          ;void clear_mem( LONG len, void *s );

                  .IMPORT strgcpy
                  .IMPORT strgcat

   .IMPORT MSys
BehneError equ $78
	.EXPORT vdi_display
	.EXPORT vdi_setup
   
MAX_HANDLES       EQU 128                 ;Maximale Handlenummer
MAX_PTS           EQU 1024                ;Maximale Anzahl der Koordinatenpaare in ptsin
NVDI_BUF_SIZE     EQU 16384               ;Groesse des Buffers

.INCLUDE "include\nvdi_div.inc"
.INCLUDE "include\memory.inc"
.INCLUDE "include\tos.inc"
.INCLUDE "include\vdi.inc"
.INCLUDE "include\linea.inc"
.INCLUDE "include\hardware.inc"
.INCLUDE "include\driver.inc"
.INCLUDE "include\seedfill.inc"
.INCLUDE "include\nvdi_wk.inc"
.INCLUDE "include\pixmap.inc"
.INCLUDE "include\mxvdi.inc"
.INCLUDE "include\aesvars.inc"


ALLOC             EQU 1
ALLOC_BIT         EQU 0

MAX_ID            EQU 10                  ;Maximale Geraetenummer

AES_HANDLE        EQU 1                   ;Handle des AES

ON                EQU 1                   ;...
ERROR             EQU -1
BAD_ID            EQU -1
NO_NVDI_DRVR      EQU -1
NOT_ENOUGH_WKS    EQU -1
NOT_ENOUGH_MEM    EQU -3

TAB               EQU 9                   ;Tabulator
SPACE             EQU 32                  ;Leerzeichen

;Defines fuer dicke Linie
ST_MIDRES         EQU -1
TT_LOWRES         EQU 1

CLOSED            EQU -1


__a_vdi           EQU   $1200             ;Anfang der VDI-Variablen
__e_vdi           EQU   SAVAREA+8*16*4    ;Ende der VDI-Variablen

                  .OFFSET  __a_vdi        ;ab hier beginnen die VDI-Variablen

tmp_buffer:                               ;kurzzeiger Buffer fuer Schweinereien, der ptsin, ..., contrl zerstoeren darf
;VDI-Arrays
ptsin:            DS.W 128*2              ;128 Koordinaten
intin:            DS.W 12                 ;12  Worte
intout:           DS.W 12                 ;12  Worte
ptsout:           DS.L 12                 ;12  Koordinaten
contrl:           DS.W 12                 ;12  Worte
vdipb:            DS.L 5                  ;5   Langworte

;************** Fontheader **************
font_hdr1:        DS.B sizeof_FONTHDR     ;Header des 6*6  Systemfonts
font_hdr2:        DS.B sizeof_FONTHDR     ;Header des 8*8  Systemfonts
font_hdr3:        DS.B sizeof_FONTHDR     ;Header des 8*16 Systemfonts
font_hdr4:        DS.B sizeof_FONTHDR     ;Header des 16*32 Systemfonts (hier unbenutzt)

;**************** Diverses ***************

atxt_off_table:   DS.L 1                  ;Dummy-off_table fuer TextBlt

old_etv_timer:    DS.L 1
key_state:        DS.L 1                  ;*kbshift, Tasten-Status-Adresse

nvdi_pool:        DS.B sizeof_FMP         ;Pool fuer NVDI-mallocs (Texteffekte, Beziers..)

buffer_ptr:       DS.L 1                  ;Zeiger auf den Buffer

system_boot:      DS.W 1                  ;Flag ist waehrend der Startphase, d.h. vor vdi_init gesetzt

gdos_path:        DS.B 128                ;GDOS-Pfad
screen_driver:    DS.B sizeof_driver      ;Treiberdaten des Bildschirmtreibers

vt52_falcon_rez:  DS.W 4

;*********** Offscreen-Treiber **************
OSC_ptr:
OFFSCREEN_ptr:    DS.L 1                  ;Zeiger auf die Liste der Offscreen-Treiber
OSC_count:
OFFSCREEN_count:  DS.W 1                  ;Anzahl der Offscreen-Treiber

mono_DRVR:        DS.L 1                  ;Zeiger auf die Treiberstruktur fuer den monochromen Offscreen-Treiber
mono_bitblt:      DS.L 1                  ;Zeiger auf die Bitblt-Routine des monochromen Offscreen-Treibers
mono_expblt:      DS.L 1                  ;Zeiger auf die Expblt-Routine des monochromen Offscreen-Treibers

;***************** Workstations ****************
wk_tab0:          DS.L 1                  ;Zeiger auf die LINE-A-Workstation
wk_tab:           DS.L MAX_HANDLES        ;Zeiger auf die sonstigen Workstations

linea_wk_ptr:     DS.L 1                  ;Zeiger auf die LINEA-Workstation
aes_wk_ptr:       DS.L 1                  ;Zeiger auf die AES-Workstation

;**************** Ausgabevektoren *****************
bconout_vec:      DS.L 1                  ;Sprungvektor fuer den VT52

bconout_tab:
cursor_cnt_vec:   DS.L 1                  ;Zeiger auf cursor_cnt
cursor_vbl_vec:   DS.L 1                  ;Zeiger auf die Cursor-Routine im VBL
vt52_vec_vec:     DS.L 1                  ;Zeiger auf bconout_vec
con_vec:          DS.L 1                  ;Vektor fuer Bios-Ausgabe ueber CON
rawcon_vec:       DS.L 1                  ;Vektor fuer Bios-Ausgabe ueber RAWCON

color_map_ptr:    DS.L 1
color_remap_ptr:  DS.L 1

mouse_tab:
mouse_buffer:     DS.L 1                  ;Zeiger auf den Hintergrundbuffer
draw_spr_vec:     DS.L 1                  ;Vektor fuer DRAW SPRITE
undraw_spr_vec:   DS.L 1                  ;Vektor fuer UNDRAW SPRITE

xbios_tab:
call_old_xbios:   DS.L 1                  ;Zeiger auf die Routine, die XBIOS anspringt
xbios_vec:        DS.L 1                  ;Zeiger auf die NVDI-XBIOS-Routinen

gemdos_tab:
call_old_gemdos:  DS.L 1                  ;Zeiger auf die Routine, die GEMDOS anspringt
gemdos_vec:       DS.L 1                  ;Zeiger auf die NVDI-GEMDOS-Routinen

;****************** NVDI-Struktur ****************
nvdi_struct:
nvdi_version:     DS.W 1                  ;Versionsnummer im BCD-Format
nvdi_datum:       DS.L 1                  ;TTMMJJJJ
nvdi_conf:        DS.B 1                  ;NVDI-Konfigurationswort
nvdi_conf_low:    DS.B 1
nvdi_aes_wk:      DS.L 1                  ;Zeiger auf die AES-WK
nvdi_fills:       DS.L 1                  ;Zeiger aufs erste Fuellmuster
nvdi_wk_tab:      DS.L 1                  ;Zeiger auf die Tabelle mit den WKs
nvdi_path:        DS.L 1                  ;Pfad
nvdi_drvr_tab:    DS.L 1                  ;Zeiger auf die Tabelle mit den Treibern
nvdi_font_tab:    DS.L 1                  ;Zeiger auf Bitmap-Fontlisten-Tabelle

nvdi_fonthdr:     DS.L 1                  ;.l Zeiger auf den ersten Systemfontheader
nvdi_sys_font_info: DS.L 1                ;.l
nvdi_colmaptab:   DS.L 1                  ;.l Zeiger auf Farbtabellen
nvdi_opn_wo_ptr:  DS.L 1                  ;.l Zeiger auf die Standard-Ausgaben fuer v_opnwk/v_opnvwk/v_opnbm
nvdi_ext_wo_ptr:  DS.L 1                  ;.l Zeiger auf die Standard-Ausgaben fuer vq_extnd
                  DS.W 1                  ;.w Maximale Anzahl der Workstations
                  DS.W 1                  ;.w hoechste VDI-Funktionsnummer
nvdi_status:      DS.B 1                  ;NVDI-Statuswort
nvdi_status_low:  DS.B 1                  ;Low-Bytes des Statusworts
                  DS.W 1                  ;frei
nvdi_vectab:
nvdi_vdi_tab:     DS.L 1                  ;Zeiger auf 256 VDI-Funtionen
nvdi_linea_tab:   DS.L 1                  ;Zeiger auf 16 LINE-A-Funktionen
nvdi_gemdos_vec:  DS.L 1                  ;Zeiger auf den GEMDOS-Sprungvektor
nvdi_bios_vec:    DS.L 1                  ;Zeiger auf die Bconout-Tabelle
nvdi_xbios_vec:   DS.L 1                  ;Zeiger auf den XBIOS-Sprungvektor
nvdi_mouse_tab:   DS.L 1                  ;Zeiger auf die Maustabelle
                  DS.W 1                  ;frei
blitter:          DS.W 1                  ;.w Blitter-Flag
modecode:         DS.W 1                  ;.w Falcon-modecode
resolution:       DS.W 1                  ;XBIOS-Aufloesung + 1 fuer v_opnwk

nvdi_cookie_CPU:  DS.L 1
nvdi_cpu_type equ nvdi_cookie_CPU+2
nvdi_cookie_VDO:  DS.L 1                  ;Videohardware
nvdi_cookie_MCH:  DS.L 1
first_device:     DS.W 1                  ;Nummer des allerersten Geraets
cpu020:           DS.W 1                  ;Flag das angibt, ob mindestens ein 020 vorhanden ist
magix:            DS.W 1
mint:             DS.W 1                  ;Flag das angibt, ob MiNT vorhanden ist

n_search_cookie:  DS.L 1
n_init_cookie:    DS.L 1
n_reset_cookie:   DS.L 1
n_init_virtual_vbl:  DS.L 1
n_reset_virtual_vbl: DS.L 1
n_Malloc_sys:     DS.L 1
n_Mfree_sys:      DS.L 1
n_nmalloc:        DS.L 1
n_nmfree:         DS.L 1
n_load_file:      DS.L 1
n_load_prg:       DS.L 1
n_load_NOD_driver:   DS.L 1
n_unload_NOD_driver: DS.L 1
n_init_NOD_drivers:  DS.L 1
n_id_to_font_file:   DS.L 1
n_set_FONT_pathes:   DS.L 1
n_get_FONT_path:  DS.L 1
n_set_caches:     DS.L 1
n_get_caches:     DS.L 1
n_get_FIF_path:   DS.L 1
n_get_INF_name:   DS.L 1
vdi_setup_ptr:    DS.L 1                                ;Zeiger auf VDI_SETUP_DATA oder 0 (direkter Zugriff auf ATARI-Hardware)

                  DS.L 32  ;Platz fuer weitere Variablen

nstruct_ende:

	IFNE NEW_SETUP_API
vdi_display:      ds.b sizeof_VDI_DISPLAY
vdi_setup:        ds.b sizeof_VDI_SETUP
    ENDC

IF *+0 > CUR_FONT                ;sind die Variablen fuer NVDI zu lang?
   error "vdi variables too long"
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  TEXT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   INCLUDE  "fonts.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;geschlossene Workstation
closed:           DC.L handle_err         ;Fehlerbehandlungsroutine
                  DC.L  0                 ;kein zweiter Dispatcher
                  DC.W  -1                ;wk_handle -1: geschlossene Workstation
                  DC.W  -1                ;devce_id -1: geschlossene Workstation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   INCLUDE  "tables.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'NVDI-Struktur'

nvdi_struct_rom:  DC.W  NVDI_VERSION      ;Versionsnummer im BCD-Format
                  DC.B  NVDI_DAY          ;Tag im BCD-Format
                  DC.B  NVDI_MONTH        ;Monat im BCD-Format
                  DC.W  NVDI_YEAR         ;Jahr im BCD-Format
                  DC.W  0                 ;NVDI-Konfigurationswort
                  DC.L  0                 ;Zeiger auf die AES-WK
                  DC.L  fill0             ;Zeiger aufs erste Fuellmuster
                  DC.L  wk_tab            ;Zeiger auf die Tabelle mit den WKs
                  DC.L  gdos_path         ;Pfad
                  DC.L  0                 ;Zeiger auf die Tabelle mit den Treibern
                  DC.L  0                 ;Zeiger auf Fontlisten-Tabelle

                  DC.L  font_hdr1         ;Zeiger auf den ersten Fontheader
                  DC.L  sys_font_info     ;Zeiger auf Informationsstruktur ueber die Bildschirm-Systemfonts
                  DC.L  color_map_ptr     ;Zeiger auf die Farbumwandlungstabellen
                  DC.L  work_out0         ;.l Zeiger auf die Standard-Ausgaben fuer v_opnwk/v_opnvwk/v_opnbm
                  DC.L  extnd_out0        ;.l Zeiger auf die Standard-Ausgaben fuer vq_extnd
                  DC.W  MAX_HANDLES       ;Anzahl der Workstations
                  DC.W  VQT_FONTINFO      ;hoechste VDI-Funktionsnummer

                  DC.W  0                 ;NVDI-Statuswort
                  DC.W  0                 ;frei

                  DC.L  vdi_tab           ;Zeiger auf 256 VDI-Funtionen
                  DC.L  linea_tab         ;Zeiger auf 16 LINE-A-Funktionen
                  DC.L  0                 ;Zeiger auf Tabelle mit GEMDOS-Sprungvektoren
                  DC.L  bconout_tab       ;Zeiger auf Tabelle mit BIOS-Sprungvektoren
                  DC.L  0                 ;Zeiger auf Tabelle mit XBIOS-Sprungvektoren
                  DC.L  mouse_tab         ;.l Zeiger auf Tabelle fuer die Maus

                  DC.W  0                 ;frei
                  DC.W  0                 ;Blitter-Status
                  DC.W  0                 ;.w Falcon-modecode
                  DC.W  0                 ;.w XBIOS-Aufloesung fuer v_opnwk
                  DC.L  0                 ;.l Inhalt des _CPU-Cookies
                  DC.L  0                 ;.l Inhalt des _VDO-Cookies
                  DC.L  0                 ;.l Inhalt des _MCH-Cookies
                  DC.W  0                 ;.w Nummer des zuerst geoeffneten Geraets (Haupt-Bildschirm)
                  DC.W  0                 ;.w CPU-Flag: ist gesetzt, wenn mindestens ein 68020 vorhanden ist
                  DC.W  0                 ;.w MagiX-Flag
                  DC.W  0                 ;.w MiNT-Flag
                  DC.L  search_cookie     ;LONG search_cookie( LONG name );
                  DC.L  init_cookie       ;LONG init_cookie( LONG name, LONG val );
                  DC.L  reset_cookie      ;LONG reset_cookie( LONG name );
                  DC.L  init_virtual_vbl  ;void init_virtual_vbl();  
                  DC.L  reset_virtual_vbl ;void reset_virtual_vbl(); 
                  DC.L  Malloc_sys        ;void *Malloc_sys( LONG len );
                  DC.L  Mfree_sys         ;WORD Mfree_sys( void *addr );
                  DC.L  0                 ;void *nmalloc( LONG len );
                  DC.L  0                 ;void nmfree( void *addr );
                  DC.L  load_file         ;void *load_file( BYTE *name, LONG *length );
                  DC.L  load_prg          ;void *load_prg( BYTE *name );
                  DC.L  load_NOD_driver   ;DRIVER  *load_NOD_driver( ORGANISATION *info );
                  DC.L  unload_NOD_driver ;WORD unload_NOD_driver( DRIVER *drv );
                  DC.L  init_NOD_drivers  ;WORD init_NOD_drivers( void );
                  DC.L  0
                  
nvdi_struct_rom_end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Initialisierung'

;Vektor setzen
;Eingaben
;d0.w Vektornummer
;a0.l neue Adresse
;a1.l Zeiger auf Platz zum Speichern des alten Vektors oder -1 (ignorieren)
;Ausgaben
;kein Register wird veraendert
change_vec:       movem.l  d0-d1/a0,-(sp)
                  moveq.l  #-1,d1
                  cmpa.l   d1,a1          ;ignorieren?
                  beq.s    change_svec
                  movea.l  d1,a0
                  bsr.s    setexc
                  move.l   d0,(a1)        ;alten Vektor speichern
                  movem.l  (sp),d0-d1/a0
change_svec:      bsr.s    setexc
                  movem.l  (sp)+,d0-d1/a0
                  rts

;Aufruf von Setexc()
;Eingaben
;d0.l Vektornummer
;a0.l neue Vektoradresse
;Ausgaben
;d0.l alte Vektoradresse
;a0.l alte Vektoradresse
setexc:           movem.l  d1-d2/a1-a2,-(sp)
                  move.l   a0,-(sp)       ;neue Vektoradresse
                  move.w   d0,-(sp)       ;Nummer des Vektors
                  move.w   #SETEXC,-(sp)
                  trap     #BIOS
                  addq.l   #8,sp
                  movea.l  d0,a0
                  movem.l  (sp)+,d1-d2/a1-a2
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'ASSIGN.SYS-Parser'


;GDOS initialisieren
;ASSIGN.SYS laden und analysieren
;residente Geraetetreiber und Zeichensaetze laden
;Eingaben
; -

;Ausgaben
;d0-a6 werden zerstoert
init_gdos:        lea.l    (screen_driver).w,a1 ;Treibertabelle
                  move.l   #$4E564449,(a1)+     ; 'NVDI'
                  clr.l    (a1)+
                  clr.b    (a1)+                ;Ende des Namens
                  move.b   #DRIVER_NVDI,(a1)+   ;Treiberstatus
                  clr.w    (a1)+                ;Semaphore = 0, bisher nicht geoeffnet
                  clr.l    (a1)+                ;Treiberadresse = 0, bisher nicht geladen
                  clr.l    (a1)+
                  clr.l    (a1)+
                  clr.l    (a1)+
                  clr.l    (a1)+

                  movea.l  (sysbase).w,a0       ;Zeiger auf Sysheader
                  movea.l  os_magic(a0),a0      ;Zeiger auf die AES-Variablen
                  move.w   AESVARS_idrive(a0),d0   ;Installationslaufwerk

                  lea.l    (gdos_path).w,a0
                  add.w    #'A',d0
                  move.b   d0,(a0)+       ;Laufwerksbuchstabe
                  move.b   #':',(a0)+
                  move.b   #$5C,(a0)+
                  move.b   #'G',(a0)+
                  move.b   #'E',(a0)+
                  move.b   #'M',(a0)+
                  move.b   #'S',(a0)+
                  move.b   #'Y',(a0)+
                  move.b   #'S',(a0)+
                  move.b   #$5C,(a0)+
                  
                  clr.b    (a0)           ;Ende des GDOS-Pfads

                  rts

;Speicher allozieren
;Eingaben
;d0.l Laenge des Speicherbereichs
;Ausgaben
;d0.l Adresse des Speicherblocks oder 0 (Fehler)
MallocA:          movem.l  d1-d2/a0-a2,-(sp)
                  bsr      Malloc_sys
                  movem.l  (sp)+,d1-d2/a0-a2
                  rts

;Allozierten Speicher verkleinern

;Eingaben
;d0.l Adresse des Speicherblocks
;d1.l neue Laenge des Speicherblocks
;Ausgaben
;d0.w evtl. -40 (falsche Adresse) oder -67 (Speicherblock vergroessert)
Mshrink: ; not exported!
                  movem.l  d1-d2/a0-a2,-(sp)
                  movea.l  d0,a0
                  move.l   d1,d0
                  bsr      Mshrink_sys
                  movem.l  (sp)+,d1-d2/a0-a2
                  rts

;Allozierten Speicher zurueckgeben
;Eingaben
; d0.l Adresse des Speicherblocks
;Ausgaben
;d0.w evtl. -40 (falsche Adresse)
Mfree: ; not exported!
                  movem.l  d1-d2/a0-a2,-(sp)
                  move.l   d0,a0
                  bsr      Mfree_sys
                  movem.l  (sp)+,d1-d2/a0-a2
                  rts

clear_cpu_caches: move.w   (nvdi_cpu_type).w,d0    ;CPU-Kennung
                  cmp.w    #40,d0
                  blt.s    clear_cpu030
                  move.w   sr,-(sp)                ;Statusregister sichern
                  ori.w    #$0700,sr               ;Interrupts sperren
                  dc.w     $f4f8                   ; cpusha bc; clear both caches
                  move.w   (sp)+,sr                ;Statusregister zurueck
                  rts

clear_cpu030:     cmpi.w   #20,d0                  ;68020 oder 68030?
                  blt.s    clear_cpu_exit

                  move.w   sr,-(sp)                ;Statusregister sichern
                  move.l   d0,-(sp)
                  ori.w    #$0700,sr               ;Interrupts sperren
                  dc.w     $4e7a,$0002             ; movec cacr,d0
                  or.l     #$00000808,d0
                  dc.w     $4e7b,$0002             ; movec d0,cacr
                  move.l   (sp)+,d0
                  move.w   (sp)+,sr                ;Statusregister zurueck
clear_cpu_exit:   rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Blitter initialisieren (diese Routine wird normalerweise vor vdi_init aufgerufen!)
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;a0.l Zeiger auf VDI_SETUP_DATA-Struktur oder PixMap (altes MagiCMac)
;     oder 0 (direkter Zugriff auf ATARI-Hardware)
;Ausgaben:
;-
vdi_blinit:       movem.l  d0-d2/a0-a2,-(sp)

                  IFNE NEW_SETUP_API
                  bsr      MM_init              ;bei alten MagiCMac-Versionen den Zeiger auf die PixMap konvertieren
                  ENDC
                  move.l   a0,vdi_setup_ptr.w   ;Zeiger auf die PixMap des Macintosh
                  move.w   #1,system_boot       ;wir sind gerade beim Systemstart
                  
                  bsr      copy_nvdi_struct     ;NVDI-Struktur kopieren

                  lea.l    (bconout_tab).w,a0
                  move.l   #V_HID_CNT,(a0)+     ;cursor_cnt_vec: Zeiger auf den Cursor-Zaehler
                  move.l   #vbl_cursor,(a0)+    ;cursor_vbl_vec: Zeiger auf die Cursor-VBL-Routine
                  move.l   #con_state,(a0)+     ;vt52_vec_vec: Zeiger auf den VT52-Sprungvektor
                  move.l   #vt_con,(a0)+        ;con_vec: Zeiger auf die Standardroutine fuer CON
                  move.l   #vt_rawcon,(a0)+     ;rawcon_vec: Zeiger auf die Standardroutine fuer RAWCON
                  move.l   #vt_con,(con_state).w ;Sprungvektor fuer VT52

                  lea.l    (xbios_tab).w,a0
                  move.l   #dummy_rte,(a0)+  ;call_old_xbios
                  move.l   #dummy_rte,(a0)+  ;xbios_vec

                  lea.l    (gemdos_tab).w,a0
                  move.l   #dummy_rte,(a0)+  ;call_old_gemdos
                  move.l   #dummy_rte,(a0)+  ;gemdos_vec

                  lea.l    (mouse_tab).w,a0
                  move.l   #tmp_buffer,(a0)+ ;mouse_buffer
                  move.l   #draw_sprite_in,(a0)+   ;draw_spr_vec
                  move.l   #undraw_sprite_in,(a0)+ ;undraw_spr_vec

                  bsr      init_fonts        ;Fontheader kopieren

                  lea.l    (screen_driver).w,a0  ;Zeiger auf die Treiberstruktur
                  clr.l    driver_addr(a0)   ;Treiberadresse loeschen

                  clr.w    (blitter).w       ;kein Blitter

                  tst.l    (vdi_setup_ptr).w                  ;kein direkter Hardware-Zugriff (Mac)?
                  bne.s    vdi_blinit_exit

                  move.l   d0,-(sp)
                  bsr.s    chk_blitter
                  move.w   d0,(blitter).w
                  move.l   (sp)+,d0
vdi_blinit_exit:  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Testen, ob der Blitter vorhanden ist
;Vorgaben:
;Nur Register d0 wird veraendert
;Eingaben:
;-
;Ausgaben:
;d0.w Bit 1 gibt an,ob der Blitter vorhanden ist
chk_blitter:      movem.l  d1/a0-a1,-(sp)
                  move.w   sr,d1             ;Statusregister sichern
                  ori.w    #$0700,sr         ;Interrupts sperren
                  movea.l  sp,a0             ;Stackpointer sichern
                  movea.l  8.w,a1            ;Busfehler-Vektor sichern
                  move.l   #bus_err_tst,8.w  ;eigenen Vektor eintragen
                  moveq.l  #0,d0
                  tst.w    ($ffff8a00).w     ;auf Hardware zugreifen
                  moveq.l  #2,d0             ;Blitter ist vorhanden
bus_err_tst:      move.l   a1,8.w            ;Busfehler-Vektor zurueck
                  movea.l  a0,sp             ;Stackpointer zurueck
                  move.w   d1,sr             ;Statusregister zurueck
                  movem.l  (sp)+,d1/a0-a1
                  rts

rez_bps_tab:      DC.W     1,2,4,8,16

;VT52-Daten fuer Falcon generieren
;Eingaben:
;modecode.w
;Ausgaben:
;a0.l Zeiger auf Aufloesungen
create_falcon_rez:
                  movem.l  d0-d2,-(sp)
                  move.w   (modecode).w,d0
                  lea.l    (vt52_falcon_rez).w,a0

                  moveq.l  #7,d1
                  and.w    d0,d1          ;Farbtiefe
                  add.w    d1,d1
                  move.w   rez_bps_tab(pc,d1.w),d1 ;Ebenenanzahl
                  move.w   d1,(a0)+

                  mulu.w   #40,d1         ;Bytes pro Zeile (40 Spalten)
                  move.w   #320,d2        ;320 Pixel
                  btst     #CLM_BIT,d0    ;80 Spalten?
                  beq.s    falcon_hor_over
                  add.w    d1,d1          ;80 Spalten
                  add.w    d2,d2          ;640 Pixel
falcon_hor_over:  btst     #OVS_BIT,d0    ;Overscan?
                  beq.s    falcon_lwidth
                  mulu.w   #12,d1
                  mulu.w   #12,d2
                  divu.w   #10,d1         ;Overscan-Faktor 1.2
                  divu.w   #10,d2         ;Overscan-Faktor 1.2
falcon_lwidth:    move.w   d1,(a0)+       ;Bytes pro Zeile
                  move.w   d2,(a0)+       ;Breite in Pixeln

                  btst     #STC_BIT,d0    ;ST-Kompatibilitaet?
                  beq.s    falcon_vga
                  move.w   #200,d2        ;200 Zeilen in Farbe
                  moveq.l  #7,d1

                  and.w    d0,d1          ;Farbtiefe
                  bne.s    falcon_height
                  add.w    d2,d2          ;400 Zeilen in monochrom
                  bra.s    falcon_height

falcon_vga:       btst     #VGA_BIT,d0    ;VGA-Monitor?
                  beq.s    falcon_tv
                  move.w   #240,d2        ;240 Zeilen
                  btst     #VTF_BIT,d0    ;Interlace oder Doublescan?
                  bne.s    falcon_ver_over
                  add.w    d2,d2          ;480 Zeilen
                  bra.s    falcon_ver_over
falcon_tv:        move.w   #200,d2        ;200 Zeilen
                  btst     #VTF_BIT,d0    ;Interlace oder Doublescan?
                  beq.s    falcon_ver_over
                  add.w    d2,d2          ;400 Zeilen
falcon_ver_over:  btst     #OVS_BIT,d0    ;Overscan?
                  beq.s    falcon_height
                  muls.w   #12,d2
                  divs.w   #10,d2         ;Overscan-Faktor 1.2
falcon_height:    move.w   d2,(a0)+

                  subq.l   #8,a0
                  movem.l  (sp)+,d0-d2
                  rts

;Anzahl der Bildebenen
;Bytes pro Zeile
;Anzahl der Pixel pro Zeile
;Anzahl der Zeilen
vt52_rez_tab:     DC.W 4,160,320,200      ;0 320 * 200 ST
                  DC.W 2,160,640,200      ;1 640 * 200 ST
                  DC.W 1,80,640,400       ;2 640 * 400 ST
                  DC.W 0,0,0,0            ;3 Dummy-Eintrag
                  DC.W 4,320,640,480      ;4 640 * 480 TT
                  DC.W 0,0,0,0            ;5 Dummy-Eintrag
                  DC.W 1,160,1280,960     ;6 1280 * 960 TT
                  DC.W 8,320,320,480      ;7 320 * 480 TT

;VT52 intialisieren
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;d0.w neuer modecode falls es ein Falcon ist
;Ausgaben:
;-
vt52_init:        movem.l  d0-d2/a0-a2,-(sp)
                  move.w   (PLANES).w,-(sp)           ;alte Plane-Anzahl merken

                  move.l   (vdi_setup_ptr).w,d0       ;kein direkter Hardware-Zugriff (Mac)?
                  bne.s    vt52_init_MAC

                  moveq.l  #0,d0
                  move.b   (sshiftmd).w,d0            ;XBIOS-Aufloesung
                  cmp.w    #FALCONMDS,d0              ;Falcon?
                  bne.s    init_vt52_st_tt
                  move.w   4(sp),(modecode).w         ;neuen modecode setzen
                  bsr      create_falcon_rez
                  bra.s    init_vt52_fad
init_vt52_st_tt:  lsl.w    #3,d0                      ;*8 (4 Worteintraege pro Zeile)
                  lea.l    vt52_rez_tab(pc,d0.w),a0   ;Zeiger auf die Aufloesungstabelle
init_vt52_fad:    move.w   (a0)+,(PLANES).w           ; number of planes
                  move.w   (a0),(BYTES_LIN).w         ; bytes per line
                  move.w   (a0)+,(WIDTH).w
                  move.w   (a0)+,(V_REZ_HZ).w         ;width
                  move.w   (a0)+,(V_REZ_VT).w         ;height
                  bra.s    vt52_init_exit

vt52_init_MAC:    movea.l  d0,a0
                  IFNE NEW_SETUP_API
                  movea.l  VSD_displays(a0),a0        ;pointer to first screen description (VDI_DISPLAY structure)
                  move.l   VDISPLAY_addr(a0),(v_bas_ad).w  ;screen address
                  move.l   VDISPLAY_width(a0),d2
                  move.w   d2,(BYTES_LIN).w           ; bytes per line
                  move.w   d2,(WIDTH).w
                  move.l   VDISPLAY_bits(a0),d0
                  move.w   d0,(PLANES).w              ; number of planes
                  move.l   VDISPLAY_xmax(a0),d0
                  sub.l    VDISPLAY_xmin(a0),d0
                  addq.l   #1,d0
                  bclr     #0,d0
                  move.w   d0,(V_REZ_HZ).w            ;width
                  move.l   VDISPLAY_ymax(a0),d1
                  sub.l    VDISPLAY_ymin(a0),d1
                  addq.l   #1,d0
                  bclr     #0,d0
                  move.w   d1,(V_REZ_VT).w            ;height
                  ELSE
                  move.l   PM_baseAddr(a0),(v_bas_ad).w ; pointer to pixel data
                  move.w   PM_rowBytes(a0),d2         ; number of bytes per line
                  and.w    #$3FFF,d2                  ; mask off flags used by QuickDraw
                  move.w   d2,(BYTES_LIN).w           ; bytes per line
                  move.w   d2,(WIDTH).w
                  move.w   PM_pixelSize(a0),(PLANES).w ; number of planes
                  move.w   PM_bounds+R_right(a0),d0
                  sub.w    PM_bounds+R_left(a0),d0
                  addq.w   #1,d0
                  bclr     #0,d0
                  move.w   d0,(V_REZ_HZ).w            ;width
                  move.w   PM_bounds+R_bottom(a0),d1
                  sub.w    PM_bounds+R_left(a0),d1
                  addq.w   #1,d0
                  bclr     #0,d0
                  move.w   d1,(V_REZ_VT).w            ;height
                  ENDC

vt52_init_exit:   bsr.s    init_vt52_vars             ;VT52-Variablen initialisieren
                  move.w   (sp)+,d0                   ;zuletzt eingestellte Plane-Anzahl

                  tst.w    (system_boot).w            ;noch waehrend der Bootphase?
                  bne.s    vt52_init_return

                  sub.w    (PLANES).w,d0              ;wurde die Plane-Anzahl veraendert?
                  bsr      unload_scr_drvr            ;vorhandenen Treiber entfernen
                  bsr      load_scr_drvr              ;neuen Bilschirmtreiber laden

vt52_init_return: movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Keine Parameter
init_vt52_vars:   movem.l  d0-d3/a0-a2,-(sp)

                  move.w   (V_REZ_HZ).w,d0            ;Breite in Pixeln
                  move.w   (V_REZ_VT).w,d1            ;Hoehe in Zeilen
                  move.w   (BYTES_LIN).w,d2           ;Bytes pro Zeile

                  lea.l    header_09pt,a1             ;8*8 Systemfont
                  cmpi.w   #320,d1                    ;weniger als 320 Zeilen?
                  blt.s    init_vt52_font
                  lea.l    header_10pt,a1             ;8*16 Systemfont
init_vt52_font:   move.l   dat_table(a1),(V_FNT_AD).w ;Adresse des Fontimage
                  move.l   off_table(a1),(V_OFF_AD).w ;Adresse der HOT
                  move.w   form_width(a1),(V_FNT_WD).w ;Breite des Fontimages in Bytes
                  move.w   first_ade(a1),(V_FNT_ND).w ;Nummer des ersten Zeichens
                  move.w   last_ade(a1),(V_FNT_ST).w  ;Nummer des letzten Zeichens
                  move.w   form_height(a1),d3         ;Zeichenhoehe
                  move.w   d3,(V_CEL_HT).w            ;Zeichenhoehe
                  lsr.w    #3,d0
                  subq.w   #1,d0                      ;Textspaltenanzahl -1
                  divu.w   d3,d1
                  subq.w   #1,d1                      ;Textzeilenanzahl -1
                  mulu.w   d3,d2                      ;Bytes pro Textzeile
                  movem.w  d0-d2,(V_CEL_MX).w         ;V_CEL_MX, V_CEL_MY, V_CEL_WR
                  move.l   #255,(V_COL_BG).w          ;Hinter-/Vordergrundfarbe
                  move.w   #1,(V_HID_CNT).w           ;TOS-Cursor aus!
                  move.w   #256,(V_STAT_0).w          ;blinken
                  move.w   #$1e1e,(V_PERIOD).w        ;Blinkrate des Cursors/Zaehler
                  move.l   (v_bas_ad).w,(V_CUR_AD).w  ;Cursoradresse
                  clr.l    (V_CUR_XY).w               ;Cursor nach links oben
                  clr.w    (V_CUR_OF).w               ;Offset von v_bas_ad

                  movem.l  (sp)+,d0-d3/a0-a2
                  rts

no_offscreen_drivers:
                  DC.B  'Offscreen-Treiber nicht gefunden.',13,10
                  DC.B  'MCMD wird gestartet...',13,10,0

no_screen_driver:
                  DC.B  'Bildschirm-Treiber nicht gefunden.',13,10
                  DC.B  'MCMD wird gestartet...',13,10,0

empty_cmd:        DC.B  0
mcmd_path:        DC.B  'GEMDESK\MCMD.TOS',0
system_halted:    DC.B  'System wird angehalten.',13,10,0

                  EVEN

;WORD Cconws( const BYTE *buf );
Cconws:           movem.l  d1-d2/a0-a2,-(sp)
                  move.l   a0,-(sp)
                  move.w   #CCONWS,-(sp)
                  trap     #GEMDOS
                  addq.l   #6,sp
                  movem.l  (sp)+,d1-d2/a0-a2
                  rts

;VDI initialisieren
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;-
;Ausgaben:
;-
vdi_init:         movem.l  d0-d2/a0-a3/a6,-(sp)

                  bsr      search_cookies       ;Cookies suchen
                  bsr      init_vdi_vecs        ;VDI-interne Vektoren vorbesetzen
                  bsr      init_gdos            ;GDOS-Teil installieren
                  jsr      init_NOD_drivers     ;Offscreen-Treiber initialisieren
                  tst.w    d0                   ;alles in Ordnung?
                  bne.s    vdi_init_fonts
                  tst.l    (vdi_setup_ptr).w    ;kein direkter Hardware-Zugriff (Mac)?
                  bne      load_scr_err

                  lea.l    no_offscreen_drivers(pc),a0
                  jsr      Cconws               ;Meldung ausgeben

                  lea.l    -128(sp),sp          ;Platz auf dem Stack reservieren

                  movea.l  sp,a0
                  lea.l    (gdos_path).w,a1     ;x:\GEMSYS\
                  jsr      strgcpy
                  movea.l  sp,a0
                  lea.l    mcmd_path(pc),a1
                  jsr      strgcat              ;GEMDESK\MCMD.TOS
                  
                  movea.l  sp,a0
                  clr.l    -(sp)                ;Environment
                  pea.l    empty_cmd(pc)        ;leere Kommandozeile
                  move.l   a0,-(sp)             ;Name
                  clr.w    -(sp)                ;Modus 0
                  move.w   #PEXEC,-(sp)
                  trap     #GEMDOS
                  lea.l    16(sp),sp
                  lea.l    128(sp),sp           ;Platz fuer den Pfad zurueckgeben

                  lea.l    system_halted(pc),a0
                  jsr      Cconws               ;Meldung ausgeben

vdi_init_halt:    nop
                  bra.s    vdi_init_halt

vdi_init_fonts:   bsr      init_fonts           ;Fonts initialisieren

                  bsr      load_scr_drvr        ;Bildschirmtreiber laden

                  lea.l    (screen_driver).w,a0
                  movea.l  driver_offscreen(a0),a1
                  movea.l  (linea_wk_ptr).w,a6
                  bsr      wk_defaults          ;LINEA-Workstation initialisieren
                  movea.l  (aes_wk_ptr).w,a6
                  bsr      wk_defaults          ;AES-Workstation initialisieren

                  bsr      init_cookies         ;eigene Cookies setzen

                  clr.w    (system_boot).w      ;VDI ist initialisiert
                  movem.l  (sp)+,d0-d2/a0-a3/a6
                  rts

;Bildschirmtreiber laden
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;-
;Ausgaben:
;-
load_scr_drvr:    movem.l  d0-d2/a0-a2,-(sp)

                  movea.l  (screen_driver+driver_addr).w,a0
                  move.l   a0,d0
                  bne      load_scr_call

                  tst.l    (vdi_setup_ptr).w    ;kein direkter Hardware-Zugriff (Mac)?
                  bne.s    load_scr_MAC

                  moveq.l  #0,d0
                  move.b   (sshiftmd).w,d0      ;XBIOS-Aufloesung
                  move.w   (modecode).w,d1      ;Falcon-Moduswort
                  lea.l    (gdos_path).w,a0
                  bsr      load_ATARI_driver    ;Treiber fuer den Atari laden
                  move.l   a0,d0                ;Treiber vorhanden?
                  bne.s    load_scr_call

                  lea.l    no_screen_driver(pc),a0
                  jsr      Cconws               ;Meldung ausgeben

                  lea.l    -128(sp),sp          ;Platz auf dem Stack reservieren

                  movea.l  sp,a0
                  lea.l    (gdos_path).w,a1     ;x:\GEMSYS\
                  jsr      strgcpy
                  movea.l  sp,a0
                  lea.l    mcmd_path(pc),a1
                  jsr      strgcat              ;GEMDESK\MCMD.TOS
                  
                  movea.l  sp,a0
                  clr.l    -(sp)                ;Environment
                  pea.l    empty_cmd(pc)        ;leere Kommandozeile
                  move.l   a0,-(sp)             ;Name
                  clr.w    -(sp)                ;Modus 0
                  move.w   #PEXEC,-(sp)
                  trap     #GEMDOS
                  lea.l    16(sp),sp
                  lea.l    128(sp),sp           ;Platz fuer den Pfad zurueckgeben

                  lea.l    system_halted(pc),a0
                  jsr      Cconws               ;Meldung ausgeben

load_scr_halt:    nop
                  bra.s    load_scr_halt

load_scr_MAC:     
                  movea.l  (vdi_setup_ptr).w,a0             ;kein direkter Hardware-Zugriff (Mac)
                  IFNE NEW_SETUP_API
                  movea.l  VSD_displays(a0),a0              ;Zeiger auf VDI_DISPLAY-Struktur
                  ENDC
                  lea.l    (gdos_path).w,a1
                  bsr      load_MAC_driver                  ;Treiber fuer den Mac laden
                  move.l   a0,d0                            ;Treiber vorhanden?
                  beq.s    load_scr_err
                  
load_scr_call:    lea.l    (screen_driver).w,a3 ;Treiberstruktur fuer den Bildschirmtreiber
                  move.l   a0,driver_addr(a3)   ;Treiberstart
                  movea.l  DRVR_init(a0),a2     ;Adresse der Initroutine
                  lea.l    (nvdi_struct).w,a0   ;NVDI-Struktur uebergeben
                  movea.l  a3,a1                ;Zeiger auf die Treiberstruktur
                  jsr      (a2)
                  move.l   d0,driver_wk_len(a3) ;Laenge der Wk fuer NVDI-Treiber
                  bne.s    load_scr_exit        ;alles in Ordnung?

                  tst.l    (vdi_setup_ptr).w    ;kein direkter Hardware-Zugriff (Mac)?
                  bne.s    load_scr_err

                  illegal                       ;VDI-Treiber meldet Fehler

load_scr_err:     
                  IFNE NEW_SETUP_API
                  movea.l  vdi_setup_ptr.w,a0               
                  movea.l  VSD_report_error(a0),a0
                  ELSE
                  movea.l  MSys+BehneError,a0
                  ENDC
                  moveq.l  #-1,d0               ;kein VDI-Treiber
                  jmp      (a0)

load_scr_exit:    movem.l  (sp)+,d0-d2/a0-a2
                  rts


;Bildschirmtreiber aus dem Speicher entfernen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;d0.w Flag dafuer, ob sich die Farbtiefe geaendert hat
;Ausgaben:
;-
unload_scr_drvr:  movem.l  d0-d2/a0-a2,-(sp)
                  lea.l    (nvdi_struct).w,a0 ;NVDI-Struktur uebergeben
                  lea.l    (screen_driver).w,a1 ;Zeiger auf die Treiberstruktur
                  move.l   driver_addr(a1),d0
                  beq.s    unload_scr_exit   ;Treiber vorhanden?
                  movea.l  d0,a2
                  movea.l  DRVR_reset(a2),a2
                  jsr      (a2)              ;Treiber-internen Speicher freigeben

                  tst.w    2(sp)             ;wurde die Plane-Anzahl veraendert?
                  beq.s    unload_scr_exit
                  
                  lea.l    (screen_driver).w,a1 ;Zeiger auf die Treiberstruktur
                  move.l   driver_addr(a1),a0
                  clr.l    driver_addr(a1)   ;Treiberadresse loeschen
                  bsr      Mfree_sys         ;Treiberspeicher freigeben
unload_scr_exit:  movem.l  (sp)+,d0-d2/a0-a2
                  rts

; Vektoren initialisieren
; zerstoert d0-d2/a0-a2
init_vdi_vecs:    move.l   #WK_SIZE,d0
                  bsr      Malloc_sys
                  move.l   a0,(linea_wk_ptr).w
                  move.l   #WK_SIZE,d0
                  bsr      clear_mem         ;Speicher der LineA-Workstation loeschen

                  move.l   #WK_SIZE,d0
                  bsr      Malloc_sys
                  move.l   a0,(aes_wk_ptr).w
                  move.l   a0,(nvdi_aes_wk).w
                  move.l   #WK_SIZE,d0
                  bsr      clear_mem         ;Speicher der AES-Workstation loeschen

                  move.l   #NVDI_BUF_SIZE,d0
                  bsr      Malloc_sys
                  move.l   a0,(buffer_ptr).w ;Buffer fuer Texteffekte usw.

                  move.w   #MAX_HANDLES-1,d0
                  lea.l    (wk_tab0).w,a1    ;Zeiger auf die Workstationtabelle-4
                  move.l   (linea_wk_ptr).w,(a1)+ ;Adresse der LINE-A-Workstation
make_wk_tab:      move.l   #closed,(a1)+
                  dbra     d0,make_wk_tab
                  move.w   #CLOSED,(first_device).w

                  lea.l    (color_map_ptr).w,a1
                  move.l   #color_map_tab,(a1)+
                  move.l   #color_remap_tab,(a1)+

                  movea.l  (sysbase).w,a0 ;Zeiger auf Sysheader

                  movea.l  os_beg(a0),a0  ;vorhandenen Ramheader uebergehen
                  move.l   kbshift(a0),(key_state).w ;Tastenstatus (Kbshift)
                  cmpi.w   #$0106,os_version(a0) ;bell_hook schon vorhanden?
                  bge.s    get_act_pd
                  move.l   #make_pling,(bell_hook).w ;Glocken-Routine
get_act_pd:       cmpi.w   #$0100,os_version(a0) ;TOS 1.0 ?
                  bne.s    init_vdi_vecs_exit
                  move.l   #$00000E1B,(key_state).w ;Tastenstatus (Kbshift) von TOS 1.0
init_vdi_vecs_exit:
                  rts

;Zeichensaetze initialisieren
;Ausgaben
;d0-d1/a0-a3 werden zerstoert
init_fonts:       movem.l  d0-d2/a0-a2,-(sp)
                  moveq.l  #2,d1          ;Zaehler
                  lea.l    (font_hdr1).w,a1
                  lea.l    linea_font_tab(pc),a2 ;neue LINE-A-Fonttabelle
init_fonts_loop:  move.l   (a2)+,d0       ;keine weiteren Fonts ?
                  movea.l  d0,a0
                  bsr.s    copy_header    ;Fontheader kopieren
                  lea.l    sizeof_FONTHDR(a1),a1    ;Adresse des naechsten Fontheaders
                  move.l   a1,-4(a1)      ;Zeiger auf den naechsten Fontheader
                  dbra     d1,init_fonts_loop
                  clr.l    -4(a1)
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Fontheader kopieren
;Eingaben
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;kein Register wird zerstoert
copy_header:      movem.l  d0/a0-a1,-(sp)
                  moveq.l  #((sizeof_FONTHDR/4)-2),d0 ; -1 for dbra, -1 to skip next pointer
copy_header_loop: move.l   (a0)+,(a1)+
                  dbra     d0,copy_header_loop
                  movem.l  (sp)+,d0/a0-a1
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Vektoren initialisieren'

copy_nvdi_struct: movem.l  d0/a0-a1,-(sp)
                  moveq.l  #((nvdi_struct_rom_end-nvdi_struct_rom)/2)-1,d0
                  lea.l    nvdi_struct_rom(pc),a0
                  lea.l    (nvdi_struct).w,a1
copy_nvdi_struct2:move.w   (a0)+,(a1)+
                  dbra     d0,copy_nvdi_struct2
                  movem.l  (sp)+,d0/a0-a1
                  rts

;Cookies setzen
init_cookies:     move.l   #$4D464D56,d0  ; 'MFMV'
                  move.l   #MFMV_cookie,d1
                  bsr.s    init_cookie
                  rts

;Cookie eintragen
;Vorgaben:
;Register d0-d2/a0-a1 werden veraendert
;Eingaben:
;d0.l Cookie-Kennung
;d1.l Cookie-Inhalt
;Ausgaben:
;-
init_cookie:      movem.l  d0-d1,-(sp)
                  move.l   (p_cookies).w,d0 ;Cookie-Jar schon vorhanden ?
                  beq.s    cookie_exit
cookie_jar:       movea.l  d0,a0          ;Adresse des Cookie-Jars
                  movea.l  d0,a1
                  moveq.l  #0,d0          ;Zaehler initialisieren
cookie_search:    addq.l   #1,d0          ;inkrementieren
                  tst.l    (a1)           ;Ende der Liste ?
                  addq.l   #8,a1          ;naechster Eintrag
                  bne.s    cookie_search
cookie_end:       move.l   -(a1),d1       ;Anzahl der vorhandenen Eintraege
                  subq.l   #4,a1
                  cmp.l    d1,d0          ;noch genuegend Platz ?
                  blt.s    cookie_found
                  move.l   d1,d2
                  subq.l   #1,d2          ;Anzahl der zu kopierenden Eintraege
                  bgt.s    cookie_count_ok
                  moveq.l  #0,d1
                  moveq.l  #0,d2
cookie_count_ok:  addq.l   #8,d1          ;acht weitere Eintraege
                  move.l   d1,d0
                  lsl.l    #3,d0          ;*8
                  bsr      MallocA
                  move.l   d0,(p_cookies).w ;Fehler ?
                  beq.s    cookie_exit
                  movea.l  d0,a1          ;neue Adresse
                  bra.s    cookie_dbf
cookie_copy:      move.l   (a0)+,(a1)+    ;alte Cookies kopieren
                  move.l   (a0)+,(a1)+
cookie_dbf:       dbra     d2,cookie_copy
cookie_found:     move.l   (sp),(a1)+     ;Cookie-Kennung
                  move.l   4(sp),(a1)+    ;Cookie-Inhalt
                  clr.l    (a1)+
                  move.l   d1,(a1)+       ;Anzahl der Eintraege
cookie_exit:      addq.l   #8,sp          ;Stack korrigieren
                  rts

;Cookies suchen
;Eingaben
;-
;Ausgaben
;d0-d2/a0 werden zerstoert
search_cookies:   move.l   #$5F435055,d0 ; '_CPU'-Cookie suchen
                  bsr      search_cookie
                  move.l   d1,(nvdi_cookie_CPU).w   ;Prozessortyp
                  sub.w    #20,d1
                  spl      d1
                  ext.w    d1
                  move.w   d1,(cpu020).w

                  move.l   #$5F56444F,d0  ; '_VDO'-Cookie suchen
                  bsr      search_cookie
                  move.l   d1,(nvdi_cookie_VDO).w
                  
                  move.l   #$5F4D4348,d0  ; '_MCH'-Cookie suchen
                  bsr      search_cookie
                  move.l   d1,(nvdi_cookie_MCH).w
                  rts

;Cookie suchen
;Eingaben
;d0.l Cookie-ID
;Ausgaben
;d0.l Cookie-ID oder 0 (Suche fehlgeschlagen)
;d1.l Cookie-Daten oder 0 (Suche fehlgeschlagen)
;d2/a0 werden zerstoert
search_cookie:    move.l   (p_cookies).w,d2 ;Zeiger auf die Cookies
                  beq.s    search_ck_err  ;keine Cookies?
                  movea.l  d2,a0
search_ck_loop:   move.l   (a0)+,d2       ;Cookie-ID
                  beq.s    search_ck_err
                  move.l   (a0)+,d1       ;Daten
                  cmp.l    d0,d2          ;gefunden?
                  bne.s    search_ck_loop
                  rts
search_ck_err:    clr.l    d0             ;keine Cookies
                  clr.l    d1
                  rts

;Cookie suchen und loeschen
;Eingaben
;d0.l Cookie-ID
;Ausgaben
;d0.l Cookie-ID oder 0 (Suche fehlgeschlagen)
;d1.l Cookie-Daten oder 0 (Suche fehlgeschlagen)
;d2/a0 werden zerstoert
reset_cookie:     move.l   (p_cookies).w,d2 ;Zeiger auf die Cookies
                  beq.s    reset_ck_err   ;keine Cookies?
                  movea.l  d2,a0
reset_ck_loop:    move.l   (a0)+,d2       ;Cookie-ID
                  beq.s    reset_ck_err
                  move.l   (a0)+,d1       ;Daten
                  cmp.l    d0,d2          ;gefunden?
                  bne.s    reset_ck_loop
reset_ck_delete:  addq.l   #4,a0
                  move.l   (a0)+,-12(a0)  ;Daten ueberschreiben
                  move.l   -8(a0),-16(a0) ;Cookie-ID ueberschreiben
                  bne.s    reset_ck_delete
reset_ck_err:     rts

;VBL-Routine fuer den virtuellen Schirm einklinken
;Eingaben:
;a0.l Zeiger auf die Interrupt-Routine
init_virtual_vbl: rts

;VBL-Routine fuer den virtuellen Schirm entfernen
;Eingaben:
;a0.l Zeiger auf die Interrupt-Routine
reset_virtual_vbl:
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MFMV-Cookie

MFMV_cookie:      DC.B     'MFMV'
                  DC.L     nvdi_struct
                  DC.L     vdi_setup_ptr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'EdDI-Funktionen'

;Vorgaben:
;Es gelten die Pure C Konventionen
;Eingaben:
;d0.w Funktionsnummer
eddi_dispatcher:  tst.w    d0
                  bhi.s    eddi_err
                  add.w    d0,d0
                  move.w   eddi_tab(pc,d0.w),d0
                  jsr      eddi_tab(pc,d0.w)
                  rts

eddi_tab:         DC.W eddi_version-eddi_tab

eddi_err:         moveq.l  #-1,d0
                  rts

;Funktion 0, EdDI-Versionsnummer im BCD-Format zurueckgeben
eddi_version:     move.w   #$0100,d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'v_countourfill'

v_contourfill_in: move.l   #contour_abort,(SEEDABORT).w
seedfill:         movem.w  (a3),d0-d1     ;x-Start/y-Start

;Startpunkt ausserhalb des Clippingrechteckes ?
                  lea.l    clip_xmin(a6),a0
                  cmp.w    (a0)+,d0       ;XMINCL
                  blt.s    Ente
                  cmp.w    (a0)+,d1       ;YMINCL
                  blt.s    Ente
                  cmp.w    (a0)+,d0       ;XMAXCL
                  bgt.s    Ente
                  cmp.w    (a0),d1        ;YMAXCL
                  bgt.s    Ente

                  movea.l  buffer_addr(a6),a5 ;Start des Buffers
                  move.w   d0,v_34(a5)    ;x-Start
                  move.w   d1,d7          ;y-Start

                  move.w   (a2),d0        ;INTIN
                  cmp.w    colors(a6),d0  ;Farbnummer zulaessig ?
                  ble.s    tst_indx
Ente:             rts

tst_indx:         tst.w    d0
                  bge.s    indx_pos

                  move.w   (a3)+,d0
                  move.w   (a3)+,d1
                  movea.l  p_get_pixel(a6),a4
                  jsr      (a4)           ;Farbwert in d0

                  move.l   d0,v_1e(a5)
                  move.w   #1,(a5)
                  bra.s    scan_once

indx_pos:         movea.l  p_vdi_to_color(a6),a4
                  jsr      (a4)
                  move.l   d0,v_1e(a5)    ;Farbwert
                  clr.w    (a5)
;
; Die Register d5-d7 duerfen in den aufgerufen Subroutinen nicht zerstoert werden
scan_once:        lea.l    v_2c(a5),a0    ;Adr. fuer linke Grenze
                  lea.l    v_2e(a5),a1    ;Adr. fuer rechte Grenze

                  move.w   v_34(a5),d0    ;x-Start
                  move.w   d7,d1          ;y-Start
                  bsr      scanline       ;Rueckgabewert in d0
                  tst.w    d0
                  beq.s    Ente           ;0: Ende

                  move.w   d0,v_3c(a5)
                  move.w   #3,d5
                  clr.w    d6

                  move.w   d7,d0
                  ori.w    #$8000,d0
                  move.w   d0,v_48(a5)
                  move.l   v_2c(a5),v_4a(a5) ;opt. $182c->$184a,$182e->$184c
                  clr.w    v_3a(a5)
                  bra.s    lbl250

lbl184:           addq.w   #3,d6
                  cmp.w    d5,d6
                  bne.s    lbl1A2

                  clr.w    d6

lbl1A2:           lea.l    v_48(a5),a0
                  adda.w   d6,a0
                  adda.w   d6,a0

                  cmpi.w   #$ffff,(a0)
                  beq.s    lbl184

                  move.w   (a0),d7
                  move.w   #$ffff,(a0)+
                  move.l   (a0)+,v_2c(a5) ;optimiert, move.w ->$182c/182e

                  addq.w   #3,d6

                  cmp.w    d5,d6
                  bne.s    lbl228

                  bsr      fillabort

lbl228:           tst.w    v_3a(a5)
                  bne      ex_seedfill

; Registerbelegung HLINE
; d0: X1
; d1: Y1
; d2: X2
                  movem.w  v_2c(a5),d0/d2 ;$182c/$182e :x1/x2
                  move.w   d7,d1          ;y1
                  andi.w   #$7fff,d1

                  jsr      fline_save_regs

lbl250:           moveq.l  #-1,d1
                  tst.w    d7
                  bpl.s    lbl262
                  moveq.l  #1,d1

lbl262:           move.w   d1,v_38(a5)    ;+/- 1
                  lea.l    v_46(a5),a2    ;& Flag
                  lea.l    v_32(a5),a1    ;& rechte Grenze
                  lea.l    v_30(a5),a0    ;& linke Grenze
                  add.w    d7,d1          ;y +/- 1
                  move.w   v_2c(a5),d0    ;x
                  bsr      draw_to
                  move.w   d0,v_3c(a5)
                  move.w   v_38(a5),v_40(a5)
                  move.w   d0,v_42(a5)
                  move.w   v_46(a5),v_44(a5)
                  move.w   d7,v_3e(a5)    ;y
                  bra.s    lbl372

lbl2D4:           lea.l    v_44(a5),a2    ;& Flag
                  lea.l    v_36(a5),a1    ;& rechte Grenze
                  lea.l    v_34(a5),a0    ;& linke Grenze
                  move.w   v_3e(a5),d1
                  eori.w   #$8000,d1      ;y
                  subq.w   #1,v_34(a5)
                  move.w   v_34(a5),d0    ;x
                  bsr      draw_to
                  move.w   d0,v_42(a5)

lbl30E:           move.w   v_34(a5),d0
                  cmp.w    v_30(a5),d0
                  bgt.s    lbl2D4

                  move.w   v_30(a5),d0
                  move.w   d0,v_2c(a5)
                  subq.w   #1,d0
                  cmp.w    v_34(a5),d0
                  ble.s    lbl372

                  tst.l    v_42(a5)       ;optimiert, tst.w $1842/$1844
                  beq.s    lbl372

lbl346:           move.w   v_34(a5),v_30(a5)
                  move.w   v_40(a5),d0
                  add.w    d0,v_3e(a5)
                  neg.w    v_40(a5)
                  eori.w   #$8000,v_3e(a5)

lbl372:           move.w   v_2c(a5),d0
                  subq.w   #1,d0
                  cmp.w    v_30(a5),d0
                  ble.s    lbl3D2

                  tst.l    v_42(a5)       ;optimiert, $1842/1844
                  beq.s    lbl3D2

                  move.w   v_2c(a5),v_34(a5)
                  bra.s    lbl30E

lbl398:           lea.l    v_46(a5),a2    ;& Flag
                  lea.l    v_32(a5),a1    ;& rechte Grenze
                  lea.l    v_34(a5),a0    ;& linke Grenze
                  move.w   d7,d1
                  add.w    v_38(a5),d1    ;y
                  addq.w   #1,v_32(a5)
                  move.w   v_32(a5),d0    ;x
                  bsr      draw_to
                  move.w   d0,v_3c(a5)

lbl3D2:           move.w   v_32(a5),d0
                  cmp.w    v_2e(a5),d0
                  blt.s    lbl398

                  bra.s    lbl48E

lbl3E4:           move.w   v_2e(a5),v_36(a5)
                  bra.s    lbl42A

lbl3F0:           lea.l    v_46(a5),a2    ;& Flag
                  lea.l    v_36(a5),a1    ;& rechte Grenze
                  lea.l    v_34(a5),a0    ;& linke Grenze
                  move.w   d7,d1
                  eori.w   #$8000,d1      ;y
                  addq.w   #1,v_36(a5)
                  move.w   v_36(a5),d0    ;x
                  bsr.s    draw_to
                  move.w   d0,v_3c(a5)

lbl42A:           move.w   v_32(a5),d0
                  cmp.w    v_36(a5),d0
                  bgt.s    lbl3F0

                  move.w   d0,v_2e(a5)

                  addq.w   #1,d0
                  cmp.w    v_36(a5),d0
                  bge.s    lbl48E

                  tst.w    v_3c(a5)
                  bne.s    lbl462

                  tst.w    v_46(a5)
                  beq.s    lbl48E

lbl462:           move.w   v_36(a5),v_32(a5)
                  move.w   v_38(a5),d0
                  add.w    d0,d7
                  neg.w    v_38(a5)
                  eori.w   #$8000,d7

lbl48E:           move.w   v_2e(a5),d0
                  addq.w   #1,d0
                  cmp.w    v_32(a5),d0
                  bge.s    lbl4B2

                  tst.w    v_3c(a5)
                  bne.s    lbl3E4

                  tst.w    v_46(a5)
                  bne.s    lbl3E4

lbl4B2:           tst.w    d5
                  bne      lbl1A2

ex_seedfill:      rts

drawto_failed:    clr.w    d0
ex_drawto:        rts
;
; DRAW_TO
;
; d0: X
; d1: Y
; a0: & linke Grenze
; a1: & rechte Grenze
; a2: & Flag(.w)
;
; Rueckgabewert in d0
;
; Register d6/d7/a5/a6 duerfen NICHT zerstoert werden !!
; Register d5 wird veraendert (+/- 3)
;
draw_to:          clr.w    (a2)           ;Flag loeschen
                  tst.w    v_3a(a5)
                  bne.s    drawto_failed  ;!= 0, Fuellvorgang abbrechen

                  move.w   d1,-(sp)       ;y sichern
                  and.w    #$7fff,d1
                  bsr      scanline       ;Rueckgabewert in d0
                  tst.w    d0             ;0: Ende
                  bne.s    lbl575
                  addq.w   #2,sp          ;Stack korrigieren
                  rts

lbl575:           moveq.l  #0,d3
                  moveq.l  #-1,d4         ;Flag
                  lea.l    v_48(a5),a3    ;Basisadr.
                  bra.s    lbl646

lbl576:           movea.l  a3,a4
                  adda.w   d3,a4
                  adda.w   d3,a4
                  move.l   (a4),d0        ;nur Lo-Wort gesucht !
                  cmp.w    (a0),d0        ;Vergleich mit linker Grenze
                  bne.s    lbl618

                  swap     d0             ;High-Wort
                  cmp.w    #$ffff,d0
                  beq.s    lbl61e

                  eori.w   #$8000,d0
                  cmp.w    (sp),d0        ;Vergleich mit Y
                  bne.s    lbl618

; Registerbelegung HLINE
; d0: X1
; d1: Y1
; d2: X2
                  move.w   (sp)+,d1       ;y - und Stackkorrektur !!
                  andi.w   #$7fff,d1
                  move.w   (a0),d0        ;X1 = linke Grenze
                  move.w   (a1),d2        ;X2 = rechte Grenze
                  jsr      fline_save_regs

                  move.w   #$ffff,(a4)
                  addq.w   #3,d3
                  cmp.w    d5,d3
                  bne.s    lbl60A

                  bsr.s    fillabort      ;zerstoert a0 !!

lbl60A:           move.w   #1,(a2)        ;Flag neu setzen
                  clr.w    d0
                  rts

lbl618:           cmpi.w   #$ffff,(a4)
                  bne.s    lbl640

lbl61e:           cmpi.w   #$ffff,d4
                  bne.s    lbl640

                  move.w   d3,d4
lbl640:           addq.w   #3,d3

lbl646:           cmp.w    d5,d3
                  blt.s    lbl576

                  cmpi.w   #$ffff,d4
                  bne.s    lbl686

                  addq.w   #3,d5

                  cmpi.w   #$0780,d5
                  ble.s    lbl690

                  move.w   #1,v_3a(a5)    ;Fuellvorgang abbrechen !!
                  addq.w   #2,sp          ;Stack korrigieren
                  clr.w    d0
                  rts

lbl686:           move.w   d4,d3

lbl690:           adda.w   d3,a3
                  adda.w   d3,a3

                  move.w   (sp)+,(a3)+    ;Y->(a3) und Stackkorrektur
                  move.w   (a0),(a3)+     ;linke Grenze -> (a3)

                  move.w   (a1),(a3)      ;rechte Grenze ->(a3)
                  moveq.l  #1,d0
                  rts
;
; zerstoert a0 !!
fillabort:        lea.l    v_42(a5),a0    ;$1848-2*3
                  adda.w   d5,a0
                  adda.w   d5,a0

                  cmpi.w   #$ffff,(a0)
                  bne.s    lbl4FC

                  tst.w    d5
                  ble.s    lbl4FC

                  subq.w   #3,d5
                  bra.s    fillabort

lbl4FC:           cmp.w    d5,d6
                  blt.s    ex_fillabort
                  clr.w    d6

                  bsr.s    contour_abort  ;d0 == weiter
                  move.w   d0,v_3a(a5)    ;d0 != 0, Fuellvorgang abbrechen
ex_fillabort:     rts

;-------------------------------------------------
scln_failed:
contour_abort:    moveq.l  #0,d0
                  rts

;Zeile fuer v_contourfill absuchen
;
;Diese Routine ermittelt die Farbe des Startpunktes (x,y) und sucht dann
;links und rechts davon solange, bis ein Farbwechsel auftritt. Diese Grenzen
;werden ueber die Pointer (a0/a1) gesichert
;
;d5-d7/a0-a2/a5/a6 duerfen nicht veraendert werden
;Eingaben
;d0.w x
;d1.w y
;a0.l Adresse der linken Grenze
;a1.l Adresse der rechten Grenze
;Ausgaben
;d0.w Rueckgabewert
;d0-d4/a3/a4 werden zerstoert
scanline:         cmp.w    clip_ymin(a6),d1
                  bmi.s    scln_failed
                  cmp.w    clip_ymax(a6),d1
                  bgt.s    scln_failed
                  move.w   clip_xmin(a6),d2
                  swap     d2
                  move.w   clip_xmax(a6),d2

                  movea.l  p_scanline(a6),a4
                  jmp      (a4)           ;Rueckgabewert in d0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dummy_rts:        rts
dummy_rte:        rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "inquire.s"                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "input.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "raster.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "attribut.s"                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "output.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "control.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "text_bmp.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  ;'Grafische Unterfunktionen'

;Ellipsenausschnitt zeichnen (gefuellt)
;Eingaben
;d0.w x1
;d1.w y1
;d2.w Radius a
;d3.w Radius b
;d4.w Startwinkel in 1/10 Grad
;d5.w Endwinkel in 1/10 Grad
;a6.l Wk-Zeiger
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
fellipse_arc:     tst.w    d4
                  bne.s    fellipse_arc2
                  cmpi.w   #3600,d5
                  beq      fellipse2      ;Vollellipse zeichnen
fellipse_arc2:    tst.w    d5
                  bne.s    fellipse_arc3
                  cmpi.w   #3600,d4
                  beq      fellipse2      ;Vollellipse zeichnen
fellipse_arc3:    movea.l  buffer_addr(a6),a1
                  move.l   buffer_len(a6),-(sp) ;Bufferlaenge speichern
                  move.l   a1,-(sp)       ;Bufferadresse speichern
                  move.w   d0,(a1)+
                  move.w   d1,(a1)+
                  bsr.s    ellipse_calc_in ;Bufferadresse uebergeben
                  movea.l  (sp),a3
                  move.l   (a3),(a1)+     ;Umriss schliessen
                  move.l   a1,d1
                  sub.l    a3,d1
                  move.l   a1,buffer_addr(a6) ;neue Bufferstartadresse
                  move.l   d1,buffer_len(a6) ;neue Bufferlaenge
                  move.w   d0,d4
                  addq.w   #1,d4          ;Koordinatenpaaranzahl - 1
                  bmi.s    fellipse_arc_ex
                  bsr      v_fillarea3
fellipse_arc_ex:  move.l   (sp)+,buffer_addr(a6) ;alte Bufferadresse
                  move.l   (sp)+,buffer_len(a6) ;alte Bufferlaenge
                  rts

;Ellipse berechnen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w Radius a
;d3.w Radius b
;d4.w Startwinkel in 1/10 Grad
;d5.w Endwinkel in 1/10 Grad
;a6.l Zeiger auf die Wk (buffer_addr)
;Ausgaben
;Register d0/d4-d7/a0-a1/a2.l werden veraendert
;d0.w Koordinatenpaaranzahl
;a1.l Zeiger auf die erste unbenutzte Bufferadresse
ellipse_calc:     movea.l  buffer_addr(a6),a1

;Ellipse berechnen
;Eingaben wie bei ellipse_calc, zusaetzlich
;a1.l Bufferadresse
;Ausgaben wie bei ellipse_calc
ellipse_calc_in:  ext.l    d4
                  ext.l    d5
                  move.w   #3600,d6
                  cmp.w    d4,d5          ;gleiche Winkel, nur ein Punkt ?
                  bne.s    ellipse_wa

                  divs.w   d6,d4
                  clr.w    d4
                  swap     d4
                  tst.w    d4
                  bpl.s    ellipse_calc1
                  add.w    d6,d4
ellipse_calc1:    divs.w   #10,d4
                  bsr      ellipse_point
                  move.l   -4(a1),(a1)+
                  moveq.l  #2,d0          ;2 Punkte fuer v_pline
                  rts

ellipse_wa:       divs.w   d6,d4
                  clr.w    d4
                  swap     d4
                  tst.w    d4
                  bpl.s    ellipse_wb
                  add.w    d6,d4

ellipse_wb:       divs.w   d6,d5
                  clr.w    d5
                  swap     d5
                  tst.w    d5

                  bpl.s    ellipse_wab
                  add.w    d6,d5

ellipse_wab:      cmp.w    d4,d5
                  bgt.s    ellipse_grad

                  add.w    d6,d5

ellipse_grad:     divs.w   #10,d4         ;in Grad umrechnen
                  divs.w   #10,d5         ;in Grad umrechnen

                  bsr      ellipse_point  ;Startpunkt berechnen
                  move.l   d5,-(sp)       ;Endwinkel sichern

                  lea.l    sin,a0
ellipse_grad8:    cmp.w    #100,d2
                  bgt.s    ellipse_grad4
                  cmp.w    #100,d3
                  bgt.s    ellipse_grad4
                  cmp.w    #20,d2
                  ble.s    ellipse_grad4
                  cmp.w    #20,d3
                  ble.s    ellipse_grad4

                  addq.w   #8,d4
                  andi.w   #$fff8,d4      ;naechste 8 degree-Position
                  movea.w  #16,a2         ;Schrittweite fuer 8 degree
                  add.w    d4,d4
                  adda.w   d4,a0
                  lsr.w    #4,d4
                  lsr.w    #3,d5          ;8 degree-Schritte
                  bra.s    ellipse_test

ellipse_grad4:    cmp.w    #300,d2
                  bgt.s    ellipse_grad2
                  cmp.w    #300,d3
                  bgt.s    ellipse_grad2

                  addq.w   #4,d4
                  andi.w   #$fffc,d4      ;naechste 4 degree-Position

                  movea.w  #8,a2          ;Schrittweite fuer 4 degree
                  add.w    d4,d4
                  adda.w   d4,a0
                  lsr.w    #3,d4
                  lsr.w    #2,d5          ;4 degree-Schritte
                  bra.s    ellipse_test

ellipse_grad2:    addq.w   #2,d4
                  andi.w   #$fffe,d4
                  movea.w  #4,a2          ;Schrittweite fuer 2 degree

                  add.w    d4,d4
                  adda.w   d4,a0
                  lsr.w    #2,d4
                  lsr.w    #1,d5
ellipse_test:     sub.w    d4,d5          ;Zaehler
                  moveq.l  #1,d4          ;Anzahl der berechneten Punkte
                  subq.w   #1,d5
                  bmi.s    ellipse_last
                  move.l   #32768,d7      ;Rundungswert

ellipse_cloop:    move.w   (a0),d6        ;sin

                  muls.w   d2,d6          ;* a
                  add.l    d6,d6          ;* 2
                  add.l    d7,d6          ;runden
                  swap     d6             ;/ 65536
                  add.w    d0,d6          ;+ x1
                  bvc.s    ell_noover1
                  tst.w    d6
                  bmi.s    ell_overmi1
                  move.w   #-32767,d6     ;grosses negatives Ergebnis
                  bra.s    ell_noover1
ell_overmi1:      move.w   #32767,d6      ;grosses positives Ergebnis
ell_noover1:      move.w   d6,(a1)+
                  move.w   cos-sin(a0),d6 ;cos
                  muls.w   d3,d6          ;* b
                  add.l    d6,d6          ;* 2
                  add.l    d7,d6          ;runden
                  swap     d6             ;/ 65536
                  add.w    d1,d6          ;+ y1
                  bvc.s    ell_noover2
                  tst.w    d6
                  bmi.s    ell_overmi2
                  move.w   #-32767,d6     ;grosses negatives Ergabenis
                  bra.s    ell_noover2
ell_overmi2:      move.w   #32767,d6      ;grosses positives Ergebnis
ell_noover2:      move.w   d6,(a1)+
                  move.l   -(a1),d6
                  cmp.l    -4(a1),d6      ;gleicher Punkt?

                  beq.s    ell_next
                  addq.l   #4,a1
                  addq.w   #1,d4
ell_next:         adda.w   a2,a0          ;um a2/2 Grad weiter
                  dbra     d5,ellipse_cloop

ellipse_last:     move.w   d4,d5
                  addq.w   #1,d5          ;Punktanzahl
                  move.l   (sp)+,d4
                  bsr.s    ellipse_point
                  move.w   d5,d0
                  rts

;Start- bzw. Endpunkt einer Ellipse annaehren
;Eingaben
;d0.w x
;d1.w y
;d2.w ra
;d3.w rb
;d4.l Winkel in Grad im unteren und Rest in 10tel Grad im oberen Wort
;a1.l Zeiger auf den Buffer
;Ausgaben
;Register d6-d7/a0-a1.l werden veraendert
;d0.w x
;d1.w y
;d2.w ra
;d3.w rb
;d4.l Winkel in Grad im unteren und Rest in 10tel Grad im oberen Wort
;a1.l wird um 4 Bytes weitergesetzt, x- und y-Koordinate wurden abgelegt
ellipse_point:    lea.l    sin,a0
                  adda.w   d4,a0
                  adda.w   d4,a0
                  swap     d4
                  move.w   (a0)+,d6
                  move.w   (a0),d7
                  sub.w    d6,d7
                  muls.w   d4,d7
                  add.l    d7,d7
                  divs.w   #10,d7         ;Interpolationsergebnis
                  addq.w   #1,d7
                  asr.w    #1,d7
                  add.w    d7,d6          ;sin
                  muls.w   d2,d6          ;* a
                  add.l    d6,d6          ;* 2
                  add.l    #32768,d6      ;runden
                  swap     d6             ;/ 65536
                  add.w    d0,d6          ;+ x1
                  bvc.s    ell_noover3
                  tst.w    d6
                  bmi.s    ell_overmi3
                  move.w   #-32767,d6     ;grosses negatives Ergebnis
                  bra.s    ell_noover3
ell_overmi3:      move.w   #32767,d6      ;grosses positives Ergebnis
ell_noover3:      move.w   d6,(a1)+
                  lea.l    cos-sin(a0),a0 ;Zeiger in die Cosinus-Tabelle
                  move.w   (a0),d7
                  move.w   -(a0),d6
                  sub.w    d6,d7
                  muls.w   d4,d7
                  add.l    d7,d7
                  divs.w   #10,d7         ;Interpolationsergebnis
                  addq.w   #1,d7
                  asr.w    #1,d7
                  add.w    d7,d6          ;cos
                  muls.w   d3,d6          ;* b
                  add.l    d6,d6          ;* 2
                  add.l    #32768,d6      ;runden
                  swap     d6             ;/ 65536
                  add.w    d1,d6          ;+ y1
                  bvc.s    ell_noover4
                  tst.w    d6
                  bmi.s    ell_overmi4
                  move.w   #-32767,d6     ;grosses negatives Ergebnis
                  bra.s    ell_noover4
ell_overmi4:      move.w   #32767,d6      ;grosses positives Ergebnis
ell_noover4:      move.w   d6,(a1)+
                  swap     d4
                  rts

;Ellipse zeichnen (gefuellt)
;Eingaben
;d0.w x1
;d1.w y1
;d2.w Radius a
;d3.w Radius b
;a6.l Workstation
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
fellipse2:        moveq.l  #0,d4
                  move.w   #3600,d5
                  cmp.w    #1000,d2       ;Radius zu gross (ueberlauf moeglich) ?
                  bgt      fellipse_arc3
                  cmp.w    #1000,d3       ;Radius zu gross (ueberlauf moeglich) ?
                  bgt      fellipse_arc3
                  bsr.s    fellipse
                  tst.w    f_perimeter(a6) ;Umrahmung ?
                  beq.s    fellipse_ex2
                  bsr      ellipse_calc   ;Koordinaten der Umrahmung berechnen
                  move.w   d0,d4          ;Koordinatenpaaranzahl
                  movea.l  buffer_addr(a6),a3
                  bra      v_pline_fill   ;Umrandung ziehen
fellipse_ex2:     rts

;Ellipse zeichnen (gefuellt, ohne Umrahmung)
;Eingaben
;d0.w x1
;d1.w y1
;d2.w Radius a
;d3.w Radius b
;a6.l Workstation
;Ausgaben
;kein Register wird zerstoert
fellipse:         movem.l  d0-d7/a0-a1,-(sp)    ;Register sichern

                  movea.l  buffer_addr(a6),a0 ;Zeiger auf Offsettabelle

                  tst.w    d2
                  bgt.s    fellipse_a
                  neg.w    d2
fellipse_a:       tst.w    d3
                  beq.s    fellipse_b0
                  bgt.s    fellipse_b
                  neg.w    d3

fellipse_b:       bsr.s    fec            ;Offsets berechnen

fellipse_b0:      move.w   d0,d4
                  sub.w    d2,d0          ;x1
                  add.w    d2,d2
                  add.w    d0,d2          ;x2
                  movem.w  d0-d2/d4,-(sp)
                  bsr      fline
                  movem.w  (sp)+,d0-d2/d4

                  tst.w    d3             ;nur eine Zeile ?
                  beq.s    fe_exit

                  sub.w    d3,d1          ;y1
                  add.w    d3,d3
                  add.w    d1,d3          ;y2

fe_loop:          move.w   d4,d0          ;x
                  move.w   d4,d2          ;x
                  sub.w    (a0),d0        ;x1
                  add.w    (a0)+,d2       ;x2

                  move.w   d4,-(sp)
                  movem.w  d0-d2,-(sp)
                  bsr      fline
                  movem.w  (sp),d0-d2
                  move.w   d3,d1
                  bsr      fline
                  movem.w  (sp)+,d0-d2
                  move.w   (sp)+,d4
                  addq.w   #1,d1          ;naechste Zeile
                  subq.w   #1,d3          ;naechste Zeile

                  cmp.w    d1,d3
                  bne.s    fe_loop

fe_exit:          movem.l  (sp)+,d0-d7/a0-a1
                  rts

;a0 buffer
;Ellipse berechnen (gefuellt) nach Bresenham
;Eingaben
;d2.w Radius a, max. 1023
;d3.w Radius b, max. 1023
;a0.l Bufferadresse
;Ausgaben
;kein Register wird zerstoert
fec:              tst.w    d2
                  beq.s    fec_small0
                  cmp.w    #1,d2
                  beq.s    fec_small1
                  cmp.w    #1,d3
                  beq      fec_small2
                  movem.l  d0-d7/a0,-(sp) ;Register sichern

                  clr.w    d0             ;Offset x = 0;
                  move.w   d3,d1          ;Offset y = b;

                  mulu.w   d2,d2          ;qa = a*a;
                  move.l   d2,d6          ;da = a*a;
                  move.l   d2,d7          ;Hilfsvariable
                  add.l    d2,d2          ;qa = 2a*a;

                  mulu.w   d3,d3          ;qb = b*b;
                  add.l    d3,d6          ;da = a*a + b*b;
                  add.l    d3,d3          ;qb = 2b*b;

                  move.l   d2,d5          ;dy = qa;
                  move.w   d5,d4          ;Low von dy
                  swap     d5             ;High von dy
                  mulu.w   d1,d5          ;dy_high = qa_high * b;
                  swap     d5
                  clr.w    d5             ;Low loeschen
                  mulu.w   d1,d4          ;dy_low = qa_low * b;
                  add.l    d4,d5          ;dy = qa * b;
                  sub.l    d7,d5          ;dy = qa * b -a*a;

                  move.l   d3,d4          ;dx = 2b*b
                  lsr.l    #1,d4          ;dx = b*b

                  subq.w   #1,d1          ;wegen dbf
                  bmi.s    fec_exit
                  bra.s    fec_plus

fec_loop:         add.l    d5,d6          ;da += dy;
                  sub.l    d2,d5          ;dy -= qa;

fec_plus:         tst.l    d6
                  bmi.s    fec_output

fec_x_loop:       sub.l    d4,d6          ;da -= dx;
                  add.l    d3,d4          ;dx += qb;
                  addq.w   #1,d0          ;Offsetx x += 1;
                  tst.l    d6
                  bpl.s    fec_x_loop     ;while (da >= 0)

fec_output:       subq.w   #1,d0
                  move.w   d0,(a0)+       ;*buf++ = Offset x;
                  addq.w   #1,d0

                  dbra     d1,fec_loop

fec_exit:         movem.l  (sp)+,d0-d7/a0
                  rts

fec_small0:       move.l   a0,-(sp)
                  move.w   d3,-(sp)
fec_small0_loop:  clr.w    (a0)+
                  dbra     d3,fec_small0_loop
                  move.w   (sp)+,d3
                  movea.l  (sp)+,a0
                  rts

fec_small1:       movem.l  d0/d3/a0,-(sp)
                  move.w   d3,d0
                  add.w    d0,d0
                  add.w    d3,d0
                  lsr.w    #2,d0
                  sub.w    d0,d3
                  subq.w   #1,d3
fec_small_l1:     clr.w    (a0)+
                  dbra     d3,fec_small_l1
fec_small_l2:     move.w   #1,(a0)+
                  dbra     d0,fec_small_l2
                  movem.l  (sp)+,d0/d3/a0
                  rts

fec_small2:       move.w   d0,-(sp)
                  move.w   d2,d0
                  add.w    d0,d0
                  add.w    d2,d0
                  lsr.w    #2,d0
                  move.w   d0,(a0)
                  move.w   (sp)+,d0
                  rts

;Umriss eines abgerundetes Rechtecks berechnen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Wk-Zeiger
;Ausgaben
;Register d0-d7/a3/a4.l werden veraendert
;d4.w Punktanzahl
;a3.l Zeiger auf die erste unbenutze Bufferadresse
rbox_calc:        movea.l  buffer_addr(a6),a3
                  cmp.w    d0,d2          ;x1 und x2 vertauschen ?
                  bge.s    rby1y2
                  exg      d0,d2
rby1y2:           cmp.w    d1,d3          ;y1 u. y2 vertauschen ?
                  bge.s    rbtestx
                  exg      d1,d3

rbtestx:          move.w   d2,d4
                  sub.w    d0,d4
                  cmpi.w   #15,d4
                  ble.s    rbsmall

rbtesty:          move.w   d3,d4
                  sub.w    d1,d4
                  cmpi.w   #15,d4
                  bgt.s    rbnormal

rbsmall:          subq.w   #3,d4
                  bpl.s    rbsmall2

                  move.w   d0,(a3)+       ;ptsin[0]
                  move.w   d1,(a3)+
                  move.w   d2,(a3)+       ;ptsin[1]
                  move.w   d1,(a3)+
                  move.w   d2,(a3)+       ;ptsin[2]
                  move.w   d3,(a3)+
                  move.w   d0,(a3)+       ;ptsin[3]
                  move.w   d3,(a3)+
                  move.w   d0,(a3)+       ;ptsin[4]
                  move.w   d1,(a3)+
                  moveq.l  #5,d4
                  rts

rbsmall2:         move.w   d0,d4
                  move.w   d1,d5
                  move.w   d2,d6
                  move.w   d3,d7
                  addq.w   #1,d4
                  addq.w   #1,d5
                  subq.w   #1,d6
                  subq.w   #1,d7
                  move.w   d4,(a3)+       ;ptsin[0]
                  move.w   d1,(a3)+
                  move.w   d6,(a3)+       ;ptsin[2]
                  move.w   d1,(a3)+
                  move.w   d2,(a3)+       ;ptsin[4]
                  move.w   d5,(a3)+
                  move.w   d2,(a3)+       ;ptsin[6]
                  move.w   d7,(a3)+
                  move.w   d6,(a3)+       ;ptsin[8]
                  move.w   d3,(a3)+
                  move.w   d4,(a3)+       ;ptsin[10]
                  move.w   d3,(a3)+
                  move.w   d0,(a3)+       ;ptsin[12]
                  move.w   d7,(a3)+
                  move.w   d0,(a3)+       ;ptsin[14]
                  move.w   d5,(a3)+

                  moveq.l  #8,d4          ;Anzahl
                  rts
rbnormal:
                  addq.w   #8,d0
                  subq.w   #8,d2
                  move.w   d0,(a3)+
                  move.w   d1,(a3)+
                  move.w   d2,(a3)+
                  move.w   d1,(a3)+

                  moveq.l  #7,d4
                  lea.l    round(pc),a4
rbloop1:          add.w    (a4)+,d2
                  addq.w   #1,d1
                  move.w   d2,(a3)+
                  move.w   d1,(a3)+
                  dbra     d4,rbloop1
                  subq.w   #8,d3
                  move.w   d2,(a3)+
                  move.w   d3,(a3)+
                  moveq.l  #7,d4

rbloop2:          sub.w    -(a4),d2
                  addq.w   #1,d3
                  move.w   d2,(a3)+
                  move.w   d3,(a3)+
                  dbra     d4,rbloop2
                  move.w   d0,(a3)+
                  move.w   d3,(a3)+
                  lea.l    round(pc),a4
                  moveq.l  #7,d4
rbloop3:          sub.w    (a4)+,d0
                  subq.w   #1,d3
                  move.w   d0,(a3)+
                  move.w   d3,(a3)+
                  dbra     d4,rbloop3
                  move.w   d0,(a3)+
                  move.w   d1,(a3)+
                  moveq.l  #7,d4
rbloop4:          add.w    -(a4),d0
                  subq.w   #1,d1
                  move.w   d0,(a3)+
                  move.w   d1,(a3)+
                  dbra     d4,rbloop4
                  moveq.l  #37,d4
                  rts

;gefuelltes abgerundetes Rechteck zeichnen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Wk-Zeiger
;Ausgaben
;kein Register wird veraendert
frbox:            movem.l  d0-d7/a0-a1,-(sp)

;muessen x1 und x2 vertauscht werden ?
frbx1x2:          cmp.w    d0,d2
                  bge.s    frby1y2
                  exg      d0,d2

;y1 u. y2 vertauschen ?
frby1y2:          cmp.w    d1,d3
                  bge.s    frbtestx
                  exg      d1,d3

frbtestx:         move.w   d2,d4
                  sub.w    d0,d4
                  cmpi.w   #15,d4
                  ble.s    frbsmall

frbtesty:         move.w   d3,d4
                  sub.w    d1,d4
                  cmpi.w   #15,d4
                  bgt.s    frbnormal

frbsmall:         subq.w   #3,d4
                  bpl.s    frbsb
                  bsr.s    fbox
                  bra.s    frbexit

frbsb:            addq.w   #1,d0
                  subq.w   #1,d2
                  bsr      fline_save_regs
                  addq.w   #1,d1
                  exg      d1,d3
                  bsr      fline_save_regs
                  subq.w   #1,d1
                  exg      d1,d3

                  subq.w   #1,d0
                  addq.w   #1,d2
                  bsr.s    fbox

                  bra.s    frbexit

frbnormal:        addq.w   #8,d0
                  subq.w   #8,d2
                  moveq.l  #7,d4          ;Zaehler
                  lea.l    round(pc),a0   ;Zeiger
frbloop:          move.w   d4,-(sp)
                  movem.w  d0-d2,-(sp)
                  bsr      fline
                  movem.w  (sp),d0-d2
                  move.w   d3,d1
                  bsr      fline
                  movem.w  (sp)+,d0-d2
                  move.w   (sp)+,d4
                  sub.w    (a0),d0
                  add.w    (a0)+,d2
                  addq.w   #1,d1          ;y1+1
                  subq.w   #1,d3          ;y2-1
                  dbra     d4,frbloop
                  cmp.w    d1,d3
                  blt.s    frbexit
                  bsr.s    fbox
frbexit:          movem.l  (sp)+,d0-d7/a0-a1
                  rts


;Rundungsdaten fuer RBOX
round:            DC.W 2
                  DC.W 2
                  DC.W 1
                  DC.W 1
                  DC.W 0
                  DC.W 1
                  DC.W 0
                  DC.W 1


;gefuelltes Rechteck zeichnen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Wk-Zeiger
;Ausgaben
;kein Register wird veraendert
fbox:             movem.l  d0-d7/a0-a6,-(sp)
                  bsr.s    fbox_noreg
                  movem.l  (sp)+,d0-d7/a0-a6
fbox_exit:        rts
;d0-a6 werden veraendert
fbox_noreg:
                  cmp.w    d0,d2
                  bge.s    fbox_exgy
                  exg      d0,d2
fbox_exgy:        cmp.w    d1,d3
                  bge.s    fbox_clip
                  exg      d1,d3

fbox_clip:        lea.l    clip_xmin(a6),a1

fbox_clipx1:      cmp.w    (a1)+,d0
                  bge.s    fbox_clipy1
                  move.w   -2(a1),d0
fbox_clipy1:      cmp.w    (a1)+,d1
                  bge.s    fbox_clipx2
                  move.w   -2(a1),d1
fbox_clipx2:      cmp.w    (a1)+,d2
                  ble.s    fbox_clipxx
                  move.w   -2(a1),d2
fbox_clipxx:      cmp.w    d0,d2
                  blt.s    fbox_exit
fbox_clipy2:      cmp.w    (a1),d3
                  ble.s    fbox_clipyy
                  move.w   (a1),d3
fbox_clipyy:      cmp.w    d1,d3
                  blt.s    fbox_exit

                  movea.l  p_fbox(a6),a1 ; ??? where is that set?
                  jmp      (a1)

;horizontale Linie mit Fuellmuster ausgeben
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;a6.l Zeiger auf Attribute
;Ausgaben:
;kein Register wird veraendert
fline_save_regs:  movem.l  d0-d2/d4-d7/a1,-(sp)
                  bsr.s    fline
                  movem.l  (sp)+,d0-d2/d4-d7/a1
                  rts

;horizontale Linie mit Fuellmuster ausgeben
;Vorgaben:
;d0-d2/d4-d7/a1 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;a6.l Zeiger auf Attribute
;Ausgaben:
;-
fline:            cmp.w    d0,d2          ;x1 > x2 (Tausch) ?
                  bge.s    fline_clip
                  exg      d0,d2
fline_clip:       lea.l    clip_xmin(a6),a1
fclip_x1:         cmp.w    (a1)+,d0       ;x1 < clip_xmin ?
                  bge.s    fclip_y1
                  move.w   -2(a1),d0
fclip_y1:         cmp.w    (a1)+,d1       ;y1 < clip_ymin ?
                  blt.s    fline_exit
fclip_x2:         cmp.w    (a1)+,d2       ;x2 > clip_xmax ?
                  ble.s    fclip_y2
                  move.w   -2(a1),d2
fclip_y2:         cmp.w    (a1)+,d1       ;y1 > clip_ymax ?
                  bgt.s    fline_exit
                  cmp.w    d2,d0          ;x1 > x2 (nichts zeichnen) ?
                  bgt.s    fline_exit
                  move.w   (a1),d7        ;wr_mode
                  movea.l  p_fline(a6),a1
                  jmp      (a1)
fline_exit:
hline_exit:       rts

;horizontale Linie ausgeben
;Vorgaben:
;d0-d2/d4-d7/a1 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d6.w Linienmuster
;a6.l Zeiger auf Attribute
;Ausgaben:
;-
hline:            cmp.w    d0,d2          ;x1 > x2 (Tausch) ?
                  bge.s    hline_clip
                  exg      d0,d2
hline_clip:       add.w    l_lastpix(a6),d2
                  lea.l    clip_xmin(a6),a1
hclip_x1:         cmp.w    (a1)+,d0       ;x1 < clip_xmin ?
                  bge.s    hclip_y1
                  move.w   -2(a1),d0
hclip_y1:         cmp.w    (a1)+,d1       ;y1 < clip_ymin ?
                  blt.s    hline_exit
hclip_x2:         cmp.w    (a1)+,d2       ;x2 > clip_xmax ?
                  ble.s    hclip_y2
                  move.w   -2(a1),d2
hclip_y2:         cmp.w    (a1)+,d1       ;y1 > clip_ymax ?
                  bgt.s    hline_exit
                  cmp.w    d2,d0          ;x1 > x2 (nichts zeichnen) ?
                  bgt.s    hline_exit
                  move.w   (a1),d7        ;wr_mode
                  movea.l  p_hline(a6),a1
                  jmp      (a1)

;vertikale Linie ausgeben
;Vorgaben:
;d0-d7/a1 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d3.w y2
;d6.w Linienmuster
;a6.l Zeiger auf Attribute
;Ausgaben:
;-
vline:            cmp.w    d1,d3
                  blt.s    vline_change

                  add.w    l_lastpix(a6),d3
                  lea.l    clip_xmin(a6),a1
                  cmp.w    (a1)+,d0       ;x zu klein ?
                  blt.s    vline_exit
vclip_y1:         cmp.w    (a1)+,d1       ;y1 zu klein ?
                  bge.s    vclip_x
                  move.w   -2(a1),d1
vclip_x:          cmp.w    (a1)+,d0       ;x zu gross ?
                  bgt.s    vline_exit

vclip_y2:         cmp.w    (a1)+,d3       ;y2 zu gross ?

                  ble.s    vclip_y_cmp
                  move.w   -2(a1),d3
vclip_y_cmp:      cmp.w    d3,d1
                  bgt.s    vline_exit
                  move.w   (a1)+,d7       ;wr_mode
                  movea.l  p_vline(a6),a1
                  jmp      (a1)

Clipping:
vline_change:     exg      d1,d3

                  add.w    l_lastpix(a6),d3
                  lea.l    clip_xmin(a6),a1

                  cmp.w    (a1)+,d0       ;x zu klein ?
                  blt.s    vline_exit
                  cmp.w    (a1)+,d1       ;y1 zu klein ?

                  bge.s    vclip_c_x
                  move.w   -2(a1),d1
vclip_c_x:        cmp.w    (a1)+,d0       ;x zu gross ?
                  bgt.s    vline_exit
                  cmp.w    (a1)+,d3       ;y2 zu gross ?
                  ble.s    vclip_c_y_cmp
                  move.w   -2(a1),d3
vclip_c_y_cmp:    cmp.w    d3,d1
                  bgt.s    vline_exit
                  move.w   (a1)+,d7       ;wr_mode
                  move.w   d3,d2
                  sub.w    d1,d2
                  andi.w   #15,d2
                  ror.w    d2,d6
                  movea.l  p_vline(a6),a1
                  jmp      (a1)

vline_exit:       rts

;Schraege Linie ziehen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;d6.w Linienmuster
;a6.l Workstation-Attribut-Tabelle
;Ausgaben
;d0-d7/a1 werden zerstoert
line:             cmp.w    d0,d2          ;Koordinaten vertauschen ?
                  bge.s    line_clip

                  exg      d0,d2
                  exg      d1,d3

line_clip:        lea.l    clip_xmin(a6),a1
                  cmp.w    clip_xmax(a6),d0 ;x1 zu gross ?
                  bgt.s    line_exit
                  cmp.w    (a1),d2        ;x2 zu klein ?
                  blt.s    line_exit

                  move.w   d2,d4
                  sub.w    d0,d4          ;dx = x2 - x1; (positiver Ausdruck)
                  cmp.w    d1,d3          ;y1 groesser y2, dy negativ ?
                  blt.s    line_clip2
                  beq      hline          ;horizontale Linie ?

                  move.w   d3,d5
                  sub.w    d1,d5          ;dy = y2 - y1; (positiver Ausdruck)

                  cmp.w    (a1)+,d0       ;x1 zu klein ?
                  bge.s    line_clip_y1
                  sub.w    -(a1),d0       ;x1 - clip_xmin (negativer Ausdruck)
                  neg.w    d0             ;positiver Ausdruck fuer mulu/divu
                  mulu.w   d5,d0          ;* dy
                  divu.w   d4,d0          ;/ dx
                  add.w    d0,d1          ;y1 += -(x1 - clip_xmin) * dy / dx;
                  move.w   (a1)+,d0       ;x1 = clip_xmin;

line_clip_y1:     cmp.w    clip_ymax(a6),d1 ;y1 zu gross ?
                  bgt.s    line_exit
                  cmp.w    (a1)+,d1       ;y1 zu klein ?
                  bge.s    line_clip_x2
                  sub.w    -(a1),d1       ;y1 - clip_ymin (negativer Ausdruck)
                  neg.w    d1             ;positiver Ausdruck fuer mulu/divu
                  mulu.w   d4,d1          ;* dx
                  divu.w   d5,d1          ;* dy
                  add.w    d1,d0          ;x1 += -(y1 - clip_ymin) * dx / dy;
                  move.w   (a1)+,d1       ;y1 = clip_ymin;
                  cmp.w    (a1),d0        ;x1 zu gross ?
                  bgt.s    line_exit

line_clip_x2:     cmp.w    (a1)+,d2       ;x2 zu gross ?
                  ble.s    line_clip_y2
                  sub.w    -(a1),d2       ;x2 - clip_xmax (positiver Ausdruck)
                  mulu.w   d5,d2          ;* dy
                  divu.w   d4,d2          ;/ dx
                  sub.w    d2,d3          ;y2 -= (x2 - clip_xmax) * dy / dx;
                  move.w   (a1)+,d2       ;x2 = clip_xmax;

line_clip_y2:     cmp.w    clip_ymin(a6),d3 ;y2 zu klein ?
                  blt.s    line_exit

                  cmp.w    (a1)+,d3       ;y2 zu gross ?
                  ble.s    line_clip_cmp
                  sub.w    -(a1),d3       ;y2 - clip_ymax (positiver Ausdruck)
                  muls.w   d4,d3          ;* dx
                  divs.w   d5,d3          ;/ dy
                  sub.w    d3,d2          ;x2 -= (y2 - clip_ymax) * dx / dy;
                  move.w   (a1)+,d3       ;y2 = clip_ymax;
                  cmp.w    clip_xmin(a6),d2 ;x2 zu klein ?
                  bge.s    line_clip_cmp

line_exit:        rts

line_clip2:       move.w   d1,d5
                  sub.w    d3,d5          ;dy = y1 - y2; (positiver Ausdruck)

                  cmp.w    (a1)+,d0       ;x1 zu klein ?
                  bge.s    line_clip2_y1
                  sub.w    -(a1),d0       ;x1 - clip_xmin (negativer Ausdruck)
                  neg.w    d0             ;positiver Ausdruck fuer mulu/divu
                  mulu.w   d5,d0          ;* dy
                  divu.w   d4,d0          ;/ dx
                  sub.w    d0,d1          ;y1 -= -(x1 - clip_xmin) * dy / dx;
                  move.w   (a1)+,d0       ;x1 = clip_xmin;

line_clip2_y1:    cmp.w    (a1)+,d1       ;y1 zu klein ?
                  blt.s    line_exit
                  cmp.w    clip_ymax(a6),d1 ;y1 zu gross ?
                  ble.s    line_clip2_x2
                  sub.w    clip_ymax(a6),d1 ;y1 - clip_ymax (positiver Ausdruck)
                  mulu.w   d4,d1          ;* dx
                  divu.w   d5,d1          ;/ dy
                  add.w    d1,d0          ;x1 += (y1 - clip_ymax) * dx / dy;
                  move.w   clip_ymax(a6),d1 ;y1 = clip_ymax;
                  cmp.w    (a1),d0        ;x1 zu gross ?
                  bgt.s    line_exit

line_clip2_x2:    cmp.w    (a1)+,d2       ;x2 zu gross ?
                  ble.s    line_clip2_y2
                  sub.w    -(a1),d2       ;x2 - clip_xmax (positiver Ausdruck)
                  mulu.w   d5,d2          ;* dy
                  divu.w   d4,d2          ;/ dx
                  add.w    d2,d3          ;y2 += (x2 - clip_xmax) * dy / dx;
                  move.w   (a1)+,d2       ;x2 = clip_xmax;

line_clip2_y2:    cmp.w    (a1)+,d3       ;y2 zu gross ?
                  bgt.s    line_exit
                  cmp.w    clip_ymin(a6),d3 ;y2 zu klein ?
                  bge.s    line_clip_cmp
                  sub.w    clip_ymin(a6),d3 ;y2 - clip_ymin (negativer Ausdruck)
                  neg.w    d3             ;positiver Ausdruck fuer mulu/divu
                  mulu.w   d4,d3          ;* dx
                  divu.w   d5,d3          ;/ dy
                  sub.w    d3,d2          ;x2 -= -(y2 - clip_ymin) * dx / dy;
                  move.w   clip_ymin(a6),d3 ;y2 = clip_ymin;
                  cmp.w    clip_xmin(a6),d2 ;x2 zu klein ?
                  blt.s    line_exit

line_clip_cmp:    cmp.w    d0,d2          ;x1 groesser als x2 ?
                  blt.s    line_exit

                  move.w   (a1),d7        ;wr_mode
                  movea.l  p_line(a6),a1
                  jmp      (a1)

                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "linea.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "escape.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "vt52.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "disp.s"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end: 0000a24c


/* VDI variables in lowmem */
; 00001200 A __a_vdi
; 00001200: ptsin
; 00001400: intin
; 00001418: intout
; 00001430: ptsout
; 00001460: contrl
; 00001478: vdipb
; 0000148C: font_header[4]
; 000015EC: atxt_off
; 000015F0: old_etv_timer
; 000015F4: key_state
; 000015F8: nvdi_pool
; 00001678: buffer_ptr
; 0000167e: gdos_path
; 000016FE: screen_driver
; 0000171E: vt52_falcon_rez
; 00001726: OSC_ptr
; 0000172a: OSC_count
; 0000172c: mono_DRVR
; 00001730: mono_bitblt
; 00001734: mono_expblt
; 00001738: wk_tab0
; 0000173C: WK *wk_tab[128]
; 00001940: aes_wk_ptr
; 00001948: cursor_cnt_vec
; 0000194C: cursor_vbl_vec
; 00001950: vt52_vec_vec
; 00001954: con_vec
; 00001958: rawcon_vec
; 0000195C: color_map_ptr
; 00001960: color_remap_ptr
; 00001964: mouse_buffer
; 00001968: draw_spr_vec
; 0000196C: undraw_spr_vec
; 00001970: call_old_xbios
; 00001978: call_old_gemdos
; 00001980: nvdi_struct
; 00001988: nvdi_aes_wk
; 000019D6: blitter
; 000019D8: modecode
; 000019DA: resolution
; 000019DC: nvdi_cookie_CPU
; 000019de: nvdi_cpu_type
; 000019E0: nvdi_cookie_VDO
; 000019E4: nvdi_cookie_MCH
; 000019E8: first_device
; 000019ea: cpu020
; 00001A44: PixMap_ptr/vdi_setup_ptr

; 000028d6: __e_vdi
