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

                  bsr      MM_init              ;bei alten MagiCMac-Versionen den Zeiger auf die PixMap konvertieren
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
init_vt52_fad:    move.w   (a0)+,(PLANES).w           ;Anzahl der Ebenen
                  move.w   (a0),(BYTES_LIN).w         ;Bytes pro Zeile
                  move.w   (a0)+,(WIDTH).w
                  move.w   (a0)+,(V_REZ_HZ).w         ;Breite
                  move.w   (a0)+,(V_REZ_VT).w         ;Hoehe
                  bra.s    vt52_init_exit

vt52_init_MAC:    movea.l  d0,a0
                  movea.l  VSD_displays(a0),a0        ;Zeiger auf die erste Bildschirmbeschreibung (VDI_DISPLAY-Struktur)
                  move.l   VDISPLAY_addr(a0),(v_bas_ad).w  ;Bildschirmadresse
                  move.l   VDISPLAY_width(a0),d2
                  move.w   d2,(BYTES_LIN).w           ;Bytes pro Zeile
                  move.w   d2,(WIDTH).w
                  move.l   VDISPLAY_bits(a0),d0
                  move.w   d0,(PLANES).w              ;Anzahl der Ebenen
                  move.l   VDISPLAY_xmax(a0),d0
                  sub.l    VDISPLAY_xmin(a0),d0
                  move.w   d0,(V_REZ_HZ).w            ;Breite
                  move.l   VDISPLAY_ymax(a0),d1
                  sub.l    VDISPLAY_ymin(a0),d1
                  move.w   d1,(V_REZ_VT).w            ;Hoehe

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
                  move.w   #256,(V_FNT_WD).w          ;Breite des Fontimages in Bytes
                  move.l   #$ff0000,(V_FNT_ND).w      ;Nummer des letzten/ersten Zeichens
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
                  bne.s    load_NOD_err

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

load_NOD_err:     movea.l  vdi_setup_ptr.w,a0               
                  movea.l  VSD_report_error(a0),a0
                  moveq.l  #-1,d0               ;kein VDI-Treiber
                  jmp      (a0)

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

load_scr_MAC:     movea.l  (vdi_setup_ptr).w,a0             ;kein direkter Hardware-Zugriff (Mac)
                  movea.l  VSD_displays(a0),a0              ;Zeiger auf VDI_DISPLAY-Struktur
                  lea.l    (gdos_path).w,a1
                  bsr      load_MAC_driver                  ;Treiber fuer den Mac laden
                  move.l   a0,d0                            ;Treiber vorhanden?
                  bne.s    load_scr_call
                  
                  movea.l  vdi_setup_ptr.w,a0               
                  movea.l  VSD_report_error(a0),a0
                  moveq.l  #-1,d0                           ;kein VDI-Treiber
                  jmp      (a0)

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

load_scr_err:     movea.l  vdi_setup_ptr.w,a0               
                  movea.l  VSD_report_error(a0),a0
                  moveq.l  #-1,d0               ;kein VDI-Treiber
                  jmp      (a0)

load_scr_exit:    movem.l  (sp)+,d0-d2/a0-a2
                  rts

unload_scr_drvr:
                  movem.l  d0-d2/a0-a2,-(sp)
                  lea.l    (nvdi_struct).w,a0
                  lea.l    (screen_driver).w,a1
                  move.l   driver_addr(a1),d0
                  beq.s    unload_scr_drvr1
                  movea.l  d0,a2
                  movea.l  DRVR_reset(a2),a2
                  jsr      (a2)
                  tst.w    2(sp)
                  beq.s    unload_scr_drvr1
                  lea.l    (screen_driver).w,a1
                  movea.l  driver_addr(a1),a0
                  clr.l    driver_addr(a1)
                  bsr.w    Mfree_sys
unload_scr_drvr1:
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts
init_vdi_vecs:
                  move.l   #WK_SIZE,d0
                  bsr.w    Malloc_sys
                  move.l   a0,(linea_wk_ptr).w
                  move.l   #WK_SIZE,d0
                  bsr.w    clear_mem
                  move.l   #WK_SIZE,d0
                  bsr.w    Malloc_sys
                  move.l   a0,(aes_wk_ptr).w
                  move.l   a0,(nvdi_aes_wk).w
                  move.l   #WK_SIZE,d0
                  bsr.w    clear_mem
                  move.l   #NVDI_BUF_SIZE,d0
                  bsr.w    Malloc_sys
                  move.l   a0,(buffer_ptr).w
                  move.w   #MAX_HANDLES-1,d0
                  lea.l    (wk_tab-4).w,a1
                  move.l   (linea_wk_ptr).w,(a1)+
make_wk_:
                  move.l   #closed,(a1)+
                  dbf      d0,make_wk_
                  move.w   #$FFFF,(first_device).w
                  lea.l    (color_map_ptr).w,a1
                  move.l   #color_map_tab,(a1)+
                  move.l   #color_remap_tab,(a1)+
                  movea.l  (sysbase).w,a0
                  movea.l  8(a0),a0
                  move.l   36(a0),(key_state).w
                  cmpi.w   #$0106,2(a0)
                  bge.s    get_act_
                  move.l   #make_pling,(bell_hook).w
get_act_:
                  cmpi.w   #$100,2(a0)
                  bne.s    init_vdi1
                  move.l   #$00000E1B,(key_state).w
init_vdi1:
                  rts
init_fonts:
      movem.l   d0-d2/a0-a2,-(sp)
      moveq.l   #2,d1
      lea.l     (font_hdr1).w,a1
      lea.l     linea_font_tab(pc),a2
init_font1:
      move.l    (a2)+,d0
      movea.l   d0,a0
      bsr.s     copy_header
      lea.l     sizeof_FONTHDR(a1),a1
      move.l    a1,-4(a1)
      dbf       d1,init_font1
      clr.l     -4(a1)
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
copy_header:
      movem.l   d0/a0-a1,-(sp)
      moveq.l   #((sizeof_FONTHDR/4)-2),d0
copy_header1:
      move.l    (a0)+,(a1)+
      dbf       d0,copy_header1
      movem.l   (sp)+,d0/a0-a1
                  rts
copy_nvdi_struct:
      movem.l   d0/a0-a1,-(sp)
      moveq.l   #((nvdi_struct_rom_end-nvdi_struct_rom)/2)-1,d0
      lea.l     nvdi_struct_rom(pc),a0
      lea.l     (nvdi_struct).w,a1
copy_nvdi_struct1:
      move.w    (a0)+,(a1)+
      dbf       d0,copy_nvdi_struct1
      movem.l   (sp)+,d0/a0-a1
                  rts
init_cookies:
      move.l    #$4D464D56,d0
      move.l    #MFMV_cookie,d1
      bsr.s     init_cookie
                  rts
init_cookie:
      movem.l   d0-d1,-(sp)
      move.l    (p_cookies).w,d0
      beq.s     cookie_err2
cookie_jar:
      movea.l   d0,a0
      movea.l   d0,a1
      moveq.l   #0,d0
cookie_search:
      addq.l    #1,d0
      tst.l     (a1)
      addq.l    #8,a1
      bne.s     cookie_search
cookie_err1:
      move.l    -(a1),d1
      subq.l    #4,a1
      cmp.l     d1,d0
      blt.s     cookie_f
      move.l    d1,d2
      subq.l    #1,d2
      bgt.s     cookie_c1
      moveq.l   #0,d1
      moveq.l   #0,d2
cookie_c1:
      addq.l    #8,d1
      move.l    d1,d0
      lsl.l     #3,d0
      bsr       MallocA
      move.l    d0,(p_cookies).w
      beq.s     cookie_err2
      movea.l   d0,a1
      bra.s     cookie_d
cookie_c2:
      move.l    (a0)+,(a1)+
      move.l    (a0)+,(a1)+
cookie_d:
      dbf       d2,cookie_c2
cookie_f:
      move.l    (sp),(a1)+
      move.l    4(sp),(a1)+
      clr.l     (a1)+
      move.l    d1,(a1)+
cookie_err2:
      addq.l    #8,a7
                  rts
search_cookies:
      move.l    #$5F435055,d0
      bsr.w     search_cookie
      move.l    d1,(nvdi_cookie_CPU).w
      sub.w     #20,d1
      spl       d1
      ext.w     d1
      move.w    d1,(cpu020).w
      move.l    #$5F56444F,d0
      bsr.w     search_cookie
      move.l    d1,(nvdi_cookie_VDO).w
      move.l    #$5F4D4348,d0
      bsr.w     search_cookie
      move.l    d1,(nvdi_cookie_MCH).w
                  rts
search_cookie:
      move.l    (p_cookies).w,d2
      beq.s     search_cookie2
      movea.l   d2,a0
search_cookie1:
      move.l    (a0)+,d2
      beq.s     search_cookie2
      move.l    (a0)+,d1
      cmp.l     d0,d2
      bne.s     search_cookie1
                  rts
search_cookie2:
      clr.l     d0
      clr.l     d1
                  rts
reset_cookie:
      move.l    (p_cookies).w,d2
      beq.s     reset_ck3
      movea.l   d2,a0
reset_ck1:
      move.l    (a0)+,d2
      beq.s     reset_ck3
      move.l    (a0)+,d1
      cmp.l     d0,d2
      bne.s     reset_ck1
reset_ck2:
      addq.l    #4,a0
      move.l    (a0)+,-12(a0)
      move.l    -8(a0),-16(a0)
      bne.s     reset_ck2
reset_ck3:
                  rts
init_virtual_vbl:
                  rts
reset_virtual_vbl:
                  rts
MFMV_cookie:
      dc.b 'MFMV'
      dc.l      nvdi_struct
      dc.l vdi_setup_ptr
eddi_dispatch:
      tst.w     d0
      bhi.s     eddi_err
      add.w     d0,d0
      move.w    eddi_tab(pc,d0.w),d0
      jsr       eddi_tab(pc,d0.w)
                  rts
eddi_tab:
      dc.w eddi_ver-eddi_tab
eddi_err:
      moveq #-1,d0
                  rts
eddi_ver:
      move.w    #$100,d0
                  rts
v_contour:
      move.l    #scln_fail,(SEEDABORT).w
seedfill:
      movem.w   (a3),d0-d1
      lea.l     clip_xmin(a6),a0
      cmp.w     (a0)+,d0
      blt.s     Ente
      cmp.w     (a0)+,d1
      blt.s     Ente
      cmp.w     (a0)+,d0
      bgt.s     Ente
      cmp.w     (a0),d1
      bgt.s     Ente
      movea.l   buffer_addr(a6),a5
      move.w    d0,14(a5)
      move.w    d1,d7
      move.w    (a2),d0
      cmp.w     colors(a6),d0
      ble.s     tst_indx
Ente:
                  rts
tst_indx:
      tst.w     d0
      bge.s     indx_pos
      move.w    (a3)+,d0
      move.w    (a3)+,d1
      movea.l   p_get_pixel(a6),a4
      jsr       (a4)
      move.l    d0,2(a5)
      move.w    #1,(a5)
      bra.s     scan_onc
indx_pos:
      movea.l   p_vdi_to_color(a6),a4
      jsr       (a4)
      move.l    d0,2(a5)
      clr.w     (a5)
scan_onc:
      lea.l     6(a5),a0
      lea.l     8(a5),a1
      move.w    14(a5),d0
      move.w    d7,d1
      bsr       scanline
      tst.w     d0
      beq.s     Ente
      move.w    d0,22(a5)
      move.w    #3,d5
      clr.w     d6
      move.w    d7,d0
      ori.w     #$8000,d0
      move.w    d0,34(a5)
      move.l    6(a5),36(a5)
      clr.w     20(a5)
      bra.s     lbl250
lbl184:
      addq.w    #3,d6
      cmp.w     d5,d6
      bne.s     lbl1A2
      clr.w     d6
lbl1A2:
      lea.l     34(a5),a0
      adda.w    d6,a0
      adda.w    d6,a0
      cmpi.w    #$FFFF,(a0)
      beq.s     lbl184
      move.w    (a0),d7
      move.w    #$FFFF,(a0)+
      move.l    (a0)+,6(a5)
      addq.w    #3,d6
      cmp.w     d5,d6
      bne.s     lbl228
      bsr       fillabort
lbl228:
      tst.w     20(a5)
      bne       ex_seedf
      movem.w   6(a5),d0/d2
      move.w    d7,d1
      andi.w    #$7FFF,d1
      jsr       fline_sa
lbl250:
      moveq.l   #-1,d1
      tst.w     d7
      bpl.s     lbl262
      moveq.l   #1,d1
lbl262:
      move.w    d1,18(a5)
      lea.l     32(a5),a2
      lea.l     12(a5),a1
      lea.l     10(a5),a0
      add.w     d7,d1
      move.w    6(a5),d0
      bsr       draw_to
      move.w    d0,22(a5)
      move.w    18(a5),26(a5)
      move.w    d0,28(a5)
      move.w    32(a5),30(a5)
      move.w    d7,24(a5)
      bra.s     lbl372
lbl2D4:
      lea.l     30(a5),a2
      lea.l     16(a5),a1
      lea.l     14(a5),a0
      move.w    24(a5),d1
      eori.w    #$8000,d1
      subq.w    #1,14(a5)
      move.w    14(a5),d0
      bsr       draw_to
      move.w    d0,28(a5)
lbl30E:
      move.w    14(a5),d0
      cmp.w     10(a5),d0
      bgt.s     lbl2D4
      move.w    10(a5),d0
      move.w    d0,6(a5)
      subq.w    #1,d0
      cmp.w     14(a5),d0
      ble.s     lbl372
      tst.l     28(a5)
      beq.s     lbl372
lbl346:
      move.w    14(a5),10(a5)
      move.w    26(a5),d0
      add.w     d0,24(a5)
      neg.w     26(a5)
      eori.w    #$8000,24(a5)
lbl372:
      move.w    6(a5),d0
      subq.w    #1,d0
      cmp.w     10(a5),d0
      ble.s     lbl3D2
      tst.l     28(a5)
      beq.s     lbl3D2
      move.w    6(a5),14(a5)
      bra.s     lbl30E
lbl398:
      lea.l     32(a5),a2
      lea.l     12(a5),a1
      lea.l     14(a5),a0
      move.w    d7,d1
      add.w     18(a5),d1
      addq.w    #1,12(a5)
      move.w    12(a5),d0
      bsr       draw_to
      move.w    d0,22(a5)
lbl3D2:
      move.w    12(a5),d0
      cmp.w     8(a5),d0
      blt.s     lbl398
      bra.s     lbl48E
lbl3E4:
      move.w    8(a5),16(a5)
      bra.s     lbl42A
lbl3F0:
      lea.l     32(a5),a2
      lea.l     16(a5),a1
      lea.l     14(a5),a0
      move.w    d7,d1
      eori.w    #$8000,d1
      addq.w    #1,16(a5)
      move.w    16(a5),d0
      bsr.s     draw_to
      move.w    d0,22(a5)
lbl42A:
      move.w    12(a5),d0
      cmp.w     16(a5),d0
      bgt.s     lbl3F0
      move.w    d0,8(a5)
      addq.w    #1,d0
      cmp.w     16(a5),d0
      bge.s     lbl48E
      tst.w     22(a5)
      bne.s     lbl462
      tst.w     32(a5)
      beq.s     lbl48E
lbl462:
      move.w    16(a5),12(a5)
      move.w    18(a5),d0
      add.w     d0,d7
      neg.w     18(a5)
      eori.w    #$8000,d7
lbl48E:
      move.w    8(a5),d0
      addq.w    #1,d0
      cmp.w     12(a5),d0
      bge.s     lbl4B2
      tst.w     22(a5)
      bne.s     lbl3E4
      tst.w     32(a5)
      bne.s     lbl3E4
lbl4B2:
      tst.w     d5
      bne       lbl1A2
ex_seedf:
                  rts
drawto_f:
      clr.w     d0
ex_drawt:
                  rts
draw_to:
      clr.w     (a2)
      tst.w     20(a5)
      bne.s     drawto_f
      move.w    d1,-(sp)
      and.w     #$7FFF,d1
      bsr       scanline
      tst.w     d0
      bne.s     lbl575
      addq.w    #2,a7
                  rts
lbl575:
      moveq.l   #0,d3
      moveq.l   #-1,d4
      lea.l     34(a5),a3
      bra.s     lbl646
lbl576:
      movea.l   a3,a4
      adda.w    d3,a4
      adda.w    d3,a4
      move.l    (a4),d0
      cmp.w     (a0),d0
      bne.s     lbl618
      swap      d0
      cmp.w     #$FFFF,d0
      beq.s     lbl61e
      eori.w    #$8000,d0
      cmp.w     (sp),d0
      bne.s     lbl618
      move.w    (sp)+,d1
      andi.w    #$7FFF,d1
      move.w    (a0),d0
      move.w    (a1),d2
      jsr       fline_sa
      move.w    #$FFFF,(a4)
      addq.w    #3,d3
      cmp.w     d5,d3
      bne.s     lbl60A
      bsr.s     fillabort
lbl60A:
      move.w    #1,(a2)
      clr.w     d0
                  rts
lbl618:
      cmpi.w    #$FFFF,(a4)
      bne.s     lbl640
lbl61e:
      cmpi.w    #$FFFF,d4
      bne.s     lbl640
      move.w    d3,d4
lbl640:
      addq.w    #3,d3
lbl646:
      cmp.w     d5,d3
      blt.s     lbl576
      cmpi.w    #$FFFF,d4
      bne.s     lbl686
      addq.w    #3,d5
      cmpi.w    #$0780,d5
      ble.s     lbl690
      move.w    #1,20(a5)
      addq.w    #2,a7
      clr.w     d0
                  rts
lbl686:
      move.w    d4,d3
lbl690:
      adda.w    d3,a3
      adda.w    d3,a3
      move.w    (sp)+,(a3)+
      move.w    (a0),(a3)+
      move.w    (a1),(a3)
      moveq.l   #1,d0
                  rts
fillabort:
      lea.l     28(a5),a0
      adda.w    d5,a0
      adda.w    d5,a0
      cmpi.w    #$FFFF,(a0)
      bne.s     lbl4FC
      tst.w     d5
      ble.s     lbl4FC
      subq.w    #3,d5
      bra.s     fillabort
lbl4FC:
      cmp.w     d5,d6
      blt.s     ex_filla
      clr.w     d6
      bsr.s     contour_
      move.w    d0,20(a5)
ex_filla:
                  rts
contour_:
scln_fail:
      moveq.l   #0,d0
                  rts
scanline:
      cmp.w     clip_ymin(a6),d1
      bmi.s     contour_
      cmp.w     clip_ymax(a6),d1
      bgt.s     contour_
      move.w    clip_xmin(a6),d2
      swap      d2
      move.w    clip_xmax(a6),d2
      movea.l   p_scanline(a6),a4
      jmp       (a4)
dummy_rts:
                  rts
dummy_rte:
      rte
vq_extnd:
      movea.l   (a0),a1
      cmpi.w    #1,opcode2(a1)
      bne.s     vq_extnd1
      movea.l   pb_intin(a0),a1
      cmpi.w    #2,(a1)
      beq.s     vq_scrninfo
vq_extnd1:
      movem.l   a2-a5,-(sp)
      movea.l   pb_intin(a0),a4
      movem.l   pb_intout(a0),a0-a1
      move.l    device_drvr(a6),d0
      beq.s     vq_extnd2
      movea.l   d0,a2
      movea.l   driver_addr(a2),a2
      bra.s     vq_extnd3
vq_extnd2:
      movea.l   bitmap_drvr(a6),a2
      movea.l   DRIVER_code(a2),a2
vq_extnd3:
      movea.l   DRVR_extndinfo(a2),a3
      tst.w     (a4)
      bne.s     vq_extnd4
      movea.l   DRVR_opnwkinfo(a2),a3
vq_extnd4:
      jsr       (a3)
vq_extnd5:
      movem.l   (sp)+,a2-a5
                  rts
vq_scrninfo:
      move.l    a2,-(sp)
      movea.l   (a0),a1
      move.w    #$0110,n_intout(a1)
      clr.w     n_ptsout(a1)
      movea.l   pb_intout(a0),a0
      move.l    device_drvr(a6),d0
      beq.s     vq_scrninfo1
      movea.l   d0,a2
      movea.l   driver_addr(a2),a2
      bra.s     vq_scrninfo2
vq_scrninfo1:
      movea.l   bitmap_drvr(a6),a2
      movea.l   DRIVER_code(a2),a2
vq_scrninfo2:
      movea.l   DRVR_scrninfo(a2),a2
      jsr       (a2)
vq_scrninfo3:
      movea.l   (sp)+,a2
                  rts
vq_color:
      movea.l   pb_intout(a0),a1
      movea.l   pb_intin(a0),a0
      move.w    (a0)+,d0
      cmp.w     colors(a6),d0
      bhi.s     vq_color2
      move.w    d0,(a1)+
      movem.l   d1-d2,-(sp)
      move.w    (a0)+,d1
      movea.l   p_get_color(a6),a0
      move.l    a1,-(sp)
      jsr       (a0)
      movea.l   (sp)+,a1
      move.w    d0,(a1)+
      move.w    d1,(a1)+
      move.w    d2,(a1)+
      movem.l   (sp)+,d1-d2
                  rts
vq_color2:
      move.w    #$FFFF,(a1)
                  rts
vql_attributes:
      movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
      move.w    l_style(a6),d0
      addq.w    #1,d0
      move.w    d0,(a0)+
      move.w    l_color(a6),(a0)+
      move.w    wr_mode(a6),d0
      addq.w    #1,d0
      move.w    d0,(a0)+
      move.l    l_start(a6),(a0)+
      move.w    l_width(a6),(a1)
                  rts
vqm_attributes:
      movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
      move.w    m_type(a6),d0
      addq.w    #1,d0
      move.w    d0,(a0)+
      move.w    m_color(a6),(a0)+
      move.w    wr_mode(a6),d0
      addq.w    #1,d0
      move.w    d0,(a0)+
      move.w    m_width(a6),(a1)+
      move.w    m_height(a6),(a1)
                  rts
vqf_attributes:
      movea.l   pb_intout(a0),a1
      move.w    f_interior(a6),(a1)+
      move.w    f_color(a6),(a1)+
      move.w    f_style(a6),(a1)+
      move.w    wr_mode(a6),d0
      addq.w    #1,d0
      move.w    d0,(a1)+
      move.w    f_perimeter(a6),(a1)+
                  rts
vqt_attributes:
      movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
      move.w    t_number(a6),(a0)+
      move.w    t_color(a6),(a0)+
      move.w    t_rotation(a6),d0
      tst.b     t_font_type(a6)
      bne.s     vqt_attributes1
      mulu.w    #900,d0
vqt_attributes1:
      move.w    d0,(a0)+
      move.l    t_hor(a6),(a0)+
      move.w    wr_mode(a6),d0
      addq.w    #1,d0 ; note: not done by TOS VDI
      move.w    d0,(a0)
      move.l    t_width(a6),(a1)+
      move.l    t_cwidth(a6),(a1)
                  rts
vqt_extend:
      movem.l   d1-d3/a2,-(sp)
      movea.l   (a0)+,a1
      move.w    n_intin(a1),d0
      movea.l   (a0),a1 ; a1=intin
      movea.l   pb_ptsout-4(a0),a0
      moveq.l   #0,d1
      moveq.l   #0,d2
      moveq.l   #0,d3
      subq.w    #1,d0
      bmi.s     vqt_ext_7
      movea.l   t_offtab(a6),a2
      tst.b     t_grow(a6)
      beq.s     vqt_ext_4
      move.w    t_iheight(a6),d1
      add.w     d1,d1
      cmp.w     t_cheight(a6),d1
      beq.s     vqt_ext_4
      movem.l   d4-d6,-(sp)
      move.w    t_cheight(a6),d5
      move.w    t_iheight(a6),d6
vqt_ext_1:
      move.w    (a1)+,d1
      sub.w     t_first_ade(a6),d1
      cmp.w     t_ades(a6),d1
      bls.s     vqt_ext_2
      move.w    t_unknown_index(a6),d1
vqt_ext_2:
      add.w     d1,d1
      move.w    2(a2,d1.w),d4
      sub.w     0(a2,d1.w),d4
      mulu.w    d5,d4
      divu.w    d6,d4
      add.w     d4,d2
      addq.w    #2,d3
vqt_ext_3:
      dbf       d0,vqt_ext_1
      movem.l   (sp)+,d4-d6
      bra.s     vqt_ext_7
vqt_ext_4:
      move.w    (a1)+,d1
      sub.w     t_first_ade(a6),d1
      cmp.w     t_ades(a6),d1
      bls.s     vqt_ext_5
      move.w    t_unknown_index(a6),d1
vqt_ext_5:
      add.w     d1,d1
      add.w     2(a2,d1.w),d2
      sub.w     0(a2,d1.w),d2
      addq.w    #2,d3
vqt_ext_6:
      dbf       d0,vqt_ext_4
      tst.b     t_grow(a6)
      beq.s     vqt_ext_7
      add.w     d2,d2
vqt_ext_7:
      move.w    t_cheight(a6),d1
      move.w    t_effects(a6),d0
      btst      #4,d0
      beq.s     vqt_ext_8
      add.w     d3,d2
      addq.w    #2,d1
vqt_ext_8:
      btst      #2,d0
      beq.s     vqt_ext_9
      add.w     t_whole_off(a6),d2
vqt_ext_9:
      btst      #0,d0
      beq.s     vqt_ext_10
      lsr.w     #1,d3
      mulu.w    t_thicken(a6),d3
      add.w     d3,d2
vqt_ext_10:
      moveq.l   #0,d0
      swap      d2
      clr.w     d2
      swap      d2
      move.w    t_rotation(a6),d3
      bne.s     vqt_ext_11
      move.l    d0,(a0)+
      move.w    d2,(a0)+
      move.l    d2,(a0)+
      move.w    d1,(a0)+
      move.l    d1,(a0)+
      movem.l   (sp)+,d1-d3/a2
                  rts
vqt_ext_11:
      subq.w    #1,d3
      bne.s     vqt_ext_12
      move.w    d1,(a0)+
      move.l    d1,(a0)+
      move.w    d2,(a0)+
      move.l    d2,(a0)+
      move.l    d0,(a0)+
      movem.l   (sp)+,d1-d3/a2
                  rts
vqt_ext_12:
      subq.w    #1,d3
      bne.s     vqt_ext_13
      move.w    d2,(a0)+
      move.w    d1,(a0)+
      move.l    d1,(a0)+
      move.l    d0,(a0)+
      move.w    d2,(a0)+
      move.w    d0,(a0)+
      movem.l   (sp)+,d1-d3/a2
                  rts
vqt_ext_13:
      move.l    d2,(a0)+
      move.l    d0,(a0)+
      move.w    d1,(a0)+
      move.l    d1,(a0)+
      move.w    d2,(a0)+
      movem.l   (sp)+,d1-d3/a2
                  rts
vqt_width:
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      movem.l   pb_intout(a0),a0-a1
      move.w    d0,(a0)
      sub.w     t_first_ade(a6),d0
      cmp.w     t_ades(a6),d0
      bls.s     vqt_width1
      move.w    #-1,(a0)
      move.w    t_unknown_index(a6),d0
vqt_width1:
      movea.l   t_offtab(a6),a0
      add.w     d0,d0
      adda.w    d0,a0
      moveq.l   #0,d0
      sub.w     (a0)+,d0
      add.w     (a0),d0
      tst.b     t_grow(a6)
      beq.s     vqt_width2
      mulu.w    t_cheight(a6),d0
      divu.w    t_iheight(a6),d0
      and.l     #$0000FFFF,d0
vqt_width2:
      swap      d0
      move.l    d0,(a1)+
      moveq.l   #0,d0
      move.l    d0,(a1)+
      move.l    d0,(a1)+
                  rts
vqt_name:
      move.l    d1,-(sp)
      move.l    d2,-(sp)
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      movea.l   pb_intout(a0),a1
      moveq.l   #1,d1
      lea.l     (font_hdr1).w,a0
      subq.w    #1,d0
      ble.s     vqt_name4
      subq.w    #1,d0
      move.l    t_bitmap_fonts(a6),d2
      bne.s     vqt_name2
vqt_name1:
      move.l    84(a0),d2
      beq.s     vqt_name6
vqt_name2:
      movea.l   d2,a0
      cmp.w     (a0),d1
      beq.s     vqt_name1
vqt_name3:
      move.w    (a0),d1
      dbf       d0,vqt_name1
vqt_name4:
      move.w    d1,(a1)+
      moveq.l   #7,d0
      addq.l    #4,a0
      moveq.l   #0,d2
vqt_name5:
      move.l    (a0)+,d1
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      movep.l   d1,-7(a1)
      dbf       d0,vqt_name5
      move.l    (sp)+,d2
      move.l    (sp)+,d1
                  rts
vqt_name6:
      moveq.l   #1,d1
      lea.l     (font_hdr1).w,a0
      bra.s     vqt_name4
vq_cellarray:
                  rts
vqin_mode:
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      movea.l   pb_intout(a0),a1
      subq.w    #1,d0
      cmpi.w    #3,d0
      bhi.s     vqin_mode1
      moveq.l   #1,d1
      btst      d0,input_mode(a6)
      beq.s     vqin_write
      moveq.l   #2,d1
vqin_write:
      move.w    d1,(a1)
      move.l    a0,d1
vqin_mode1:
                  rts
vqt_fontinfo:
      movem.l   d1-d4,-(sp)
      movem.l   pb_intout(a0),a1
      move.l    t_first_ade(a6),d0
      add.w     buffer_len(a6),d0 ; ???
      move.l    d0,(a1)+
      movea.l   pb_ptsout(a0),a1
      lea.l     t_height(a6),a0
      moveq.l   #0,d0
      moveq.l   #0,d1
      moveq.l   #0,d4
      move.w    (a0)+,d4
      move.w    (a0)+,(a1)+
      lea.l     t_half(a6),a0
      move.l    d4,d2
      move.w    d4,d3
      sub.w     (a0)+,d2
      sub.w     (a0)+,d3
      move.w    (a0)+,d0
      move.w    (a0)+,d1
      sub.w     d4,d0
      bpl.s     vqt_fi_b
      moveq.l   #0,d0
vqt_fi_b:
      sub.w     d4,d1
      swap      d0
      swap      d1
      swap      d2
      btst      #0,t_effects+1(a6)
      beq.s     vqt_fi_i
      move.w    t_thicken(a6),d0
vqt_fi_i:
      btst      #2,t_effects+1(a6)
      beq.s     vqt_fi_s
      move.w    t_left_off(a6),d1
      move.w    t_whole_off(a6),d2
      sub.w     d1,d2
vqt_fi_s:
      move.l    d0,(a1)+
      move.l    d1,(a1)+
      move.l    d2,(a1)+
      move.w    d3,(a1)+
      move.l    d4,(a1)+
      movem.l   (sp)+,d1-d4
                  rts
vsin_mode:
      movea.l   pb_intin(a0),a1
      move.w    (a1)+,d0
      move.w    (a1),d1
      movea.l   pb_intout(a0),a1
      subq.w    #1,d0
      cmp.w     #3,d0
      bhi.s     vsin_mode2
      move.w    d1,(a1)
      subq.w    #1,d1
      beq.s     vsin_mode1
      move.w    #2,(a1)
      bset      d0,input_mode(a6)
      move.l    a0,d1
                  rts
vsin_mode1:
      move.w    #1,(a1)
      bclr      d0,input_mode(a6)
vsin_mode2:
      move.l    a0,d1
                  rts
v_locator:
      movea.l   pb_ptsin(a0),a1
v_loc_cl1:
      move.w    (a1)+,d0
      bpl.s     v_loc_cl2
      moveq.l   #0,d0
v_loc_cl2:
      cmp.w     (DEV_TAB).w,d0
      ble.s     v_loc_cl3
      move.w    (DEV_TAB).w,d0
v_loc_cl3:
      move.w    (a1)+,d1
      bpl.s     v_loc_cl4
      moveq.l   #0,d1
v_loc_cl4:
      cmp.w     (DEV_TAB+2).w,d1
      ble.s     v_loc_sa
      move.w    (DEV_TAB+2).w,d1
v_loc_sa:
      movem.w   d0-d1,(GCURX).w
      move.l    a0,d1
      movem.l   pb_intout(a0),a0-a1
      btst      #0,input_mode(a6)
      beq.s     vrq_locator
vsm_locator:
      move.w    sr,d0
      ori.w     #$0700,sr
      move.l    (GCURX).w,(a1)
      move.w    (MOUSE_BT).w,(a0)
      addi.w    #31,(a0)
      movea.l   d1,a0
      movea.l   (a0),a1
      tst.w     (MOUSE_BT).w
      beq.s     vsm_move
      move.w    #1,n_intout(a1)
vsm_move:
      btst      #5,(CUR_MS_STAT).w
      beq.s     vsm_l_ex
      move.w    #1,n_ptsout(a1)
vsm_l_ex:
      andi.b    #$03,(CUR_MS_STAT).w
      move.w    d0,sr
                  rts
vrq_locator:
      move.w    (MOUSE_BT).w,d0
      beq.s     vrq_locator
      move.l    (GCURX).w,(a1)
      addi.w    #31,d0
      move.w    d0,(a0)
                  rts
v_valuator:
                  rts
v_choice:
      movem.l   d1-d2/a2-a4,-(sp)
      movea.l   (a0),a3
      movea.l   pb_intout(a0),a4
      btst      #2,input_mode(a6)
      beq.s     vrq_choice
vsm_choice:
      bsr.s     v_status
      tst.w     d0
      beq.s     vsm_choice2
vrq_choice:
      bsr.s     v_input
      move.l    d0,d1
      swap      d1
      subi.b    #$3B,d1
      cmpi.b    #$09,d1
      bhi.s     v_choice2
      addq.b    #1,d1
      move.b    d1,d0
v_choice2:
      move.w    d0,(a4)
      movem.l   (sp)+,d1-d2/a2-a4
                  rts
vsm_choice2:
      clr.w     8(a3)
      movem.l   (sp)+,d1-d2/a2-a4
                  rts
v_status:
      move.w    #2,-(sp)
      move.w    #1,-(sp)
      trap      #13
      addq.l    #4,a7
                  rts
v_input:
      move.w    #2,-(sp)
      move.w    #2,-(sp)
      trap      #13
      addq.l    #4,a7
      move.l    d0,d1
      swap      d1
      lsl.w     #8,d1
      or.w      d1,d0
                  rts
v_string:
      movem.l   d1-d5/a2-a4,-(sp)
      movea.l   (a0)+,a3 ; a3->contrl
      movea.l   (a0)+,a2 ; a2->intin
      movea.l   4(a0),a4 ; a4->intout
      move.w    #$ff,d3
      move.w    (a2),d4
      bpl.s     v_string2
      neg.w     d4
      moveq.l   #-1,d3
v_string2:
      move.w    d4,d5
      subq.w    #1,d4
      btst      #3,input_mode(a6)
      beq.s     vrq_string
vsm_string:
      bsr.s     v_status
      tst.w     d0
      beq.s     vsm_str_1
      bsr.s     v_input
      and.w     d3,d0
      move.w    d0,(a4)+
      cmpi.b    #$0D,d0
      beq.s     vsm_str_2
      dbf       d4,vsm_string
vsm_str_1:
      addq.w    #1,d4
vsm_str_2:
      sub.w     d4,d5
      move.w    d5,8(a3)
      movem.l   (sp)+,d1-d5/a2-a4
                  rts
vrq_string:
      bsr.s     v_input
      and.w     d3,d0
      move.w    d0,(a4)+
      cmpi.b    #$0D,d0
      beq.s     vrq_str_1
      dbf       d4,vrq_string
      addq.w    #1,d4
vrq_str_1:
      sub.w     d4,d5
      move.w    d5,8(a3)
      movem.l   (sp)+,d1-d5/a2-a4
                  rts
vsc_form:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a4
      tst.w     n_intin(a1)
      bne.s     vsc_form2
vsc_form1:
      move.w    #37,n_intout(a1)
      lea.l     (M_POS_HX).w,a0
      movea.l   a4,a1
      movem.w   (a0)+,d0-d4
      movem.w   d0-d4,(a1)
      lea.l     10(a1),a1
      movem.w   (a0)+,d0-d7/a2-a5
      movem.w   d0/d2/d4/d6/a2/a4,(a1)
      movem.w   d1/d3/d5/d7/a3/a5,32(a1)
      movem.w   (a0)+,d0-d7/a2-a5
      movem.w   d0/d2/d4/d6/a2/a4,12(a1)
      movem.w   d1/d3/d5/d7/a3/a5,44(a1)
      movem.w   (a0)+,d0-d7
      movem.w   d0/d2/d4/d6,24(a1)
      movem.w   d1/d3/d5/d7,56(a1)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vsc_form2:
      move.w    colors(a6),d5
vsc_form3:
      addq.b    #1,(MOUSE_FLAG).w
      movem.w   (a2)+,d0-d4
vsc_form4:
      cmp.w     d5,d3
      bls.s     vsc_form5
      moveq.l   #1,d3
vsc_form5:
      cmp.w     d5,d4
      bls.s     vsc_form6
      moveq.l   #1,d4
vsc_form6:
      moveq.l   #15,d5
      and.w     d5,d0
      and.w     d5,d1
      movea.l   (color_map_ptr).w,a1
      move.b    0(a1,d3.w),d3
      move.b    0(a1,d4.w),d4
      movem.w   d0-d4,(M_POS_HX).w
      lea.l     32(a2),a3
      movem.w   (a2)+,d0/d2/d4/d6/a0/a4
      movem.w   (a3)+,d1/d3/d5/d7/a1/a5
      movem.w   d0-d7/a0-a1/a4-a5,(MASK_FORM).w
      movem.w   (a2)+,d0/d2/d4/d6/a0/a4
      movem.w   (a3)+,d1/d3/d5/d7/a1/a5
      movem.w   d0-d7/a0-a1/a4-a5,(MASK_FORM+24).w
      movem.w   (a2)+,d0/d2/d4/d6
      movem.w   (a3)+,d1/d3/d5/d7
      movem.w   d0-d7,(MASK_FORM+48).w
      move.w    sr,d0
      ori.w     #$0700,sr
      move.l    (GCURX).w,(CUR_X).w
      clr.b     (CUR_FLAG).w
      move.w    d0,sr
      subq.b    #1,(MOUSE_FLAG).w
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vex_timv:
      movea.l   (a0),a1
      movea.l   pb_intout(a0),a0
      move.w    sr,d0
      ori.w     #$0700,sr
      move.l    (USER_TIM).w,d_addr(a1)
      move.l    s_addr(a1),(USER_TIM).w
      move.w    d0,sr
      move.w    (timer_ms).w,(a0)
                  rts
v_show_c:
      tst.w     bitmap_width(a6)
      bne.s     v_show_c4
      movea.l   pb_intin(a0),a1
      tst.w     (a1)
      bne.s     v_show_c1
      tst.w     (M_HID_CNT).w
      beq.s     v_show_c4
      move.w    #1,(M_HID_CNT).w
v_show_c1:
      cmpi.w    #1,(M_HID_CNT).w
      bgt.s     v_show_c2
      blt.s     v_show_c3
      movem.l   d1-d7/a2-a5,-(sp)
      move.w    sr,d2
      ori.w     #$0700,sr
      movem.w   (GCURX).w,d0-d1
      clr.b     (CUR_FLAG).w
      move.w    d2,sr
      lea.l     (M_POS_HX).w,a0
      movea.l   (mouse_buffer).w,a2
      bsr       draw_sprite ; 8eaa
      movem.l   (sp)+,d1-d7/a2-a5
v_show_c2:
      subq.w    #1,(M_HID_CNT).w
                  rts
v_show_c3:
      clr.w     (M_HID_CNT).w
v_show_c4:
                  rts
v_hide_c:
      tst.w     bitmap_width(a6)
      bne.s     v_hide_c2
      movem.l   d1-d7/a2-a5,-(sp)
      lea.l     (M_HID_CNT).w,a2
      addq.w    #1,(a2)
      cmpi.w    #1,(a2)
      bne.s     v_hide_c1
      movea.l   (mouse_buffer).w,a2
      bsr       undraw_sprite
v_hide_c1:
      movem.l   (sp)+,d1-d7/a2-a5
v_hide_c2:
                  rts
vq_mouse:
      movem.l   pb_intout(a0),a0-a1
      move.w    sr,d0
      ori.w     #$0700,sr
      move.l    (GCURX).w,(a1)
      move.w    (MOUSE_BT).w,(a0)
      move.w    d0,sr
                  rts
vex_butv:
      movea.l   (a0),a1
      move.l    (USER_BUT).w,d_addr(a1)
      move.l    s_addr(a1),(USER_BUT).w
                  rts
vex_motv:
      movea.l   (a0),a1
      move.l    (USER_MOT).w,d_addr(a1)
      move.l    s_addr(a1),(USER_MOT).w
                  rts
vex_curv:
      movea.l   (a0),a1
      move.l    (USER_CUR).w,d_addr(a1)
      move.l    s_addr(a1),(USER_CUR).w
                  rts
vq_key_s:
      movea.l   pb_intout(a0),a1
      movea.l   (key_state).w,a0
      moveq.l   #15,d0
      and.b     (a0),d0
      move.w    d0,(a1)
                  rts
vro_cpyfm:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a3
      move.w    (a2),d0
      cmp.w     #15,d0
      bhi       vro_cpyfm2
      move.w    d0,r_wmode(a6)
vro_cpyfm1:
      movem.l   s_addr(a1),a4-a5
      movem.w   (a3),d0-d7
vro_sx:
      cmp.w     d0,d2
      bge.s     vro_sy
      exg       d0,d2
vro_sy:
      cmp.w     d1,d3
      bge.s     vro_dx
      exg       d1,d3
vro_dx:
      cmp.w     d4,d6
      bge.s     vro_dy
      exg       d4,d6
vro_dy:
      cmp.w     d5,d7
      bge.s     vro_src
      exg       d5,d7
vro_src:
      move.l    fd_addr(a4),r_saddr(a6)
      beq.s     vro_src_2
      move.w    fd_nplanes(a4),d7
      subq.w    #1,d7
      cmp.w     #7,d7
      bne.s     vro_src_1
      cmp.w     r_planes(a6),d7
      bge.s     vro_src_1
      move.w    r_planes(a6),d7
vro_src_1:
      move.w    d7,r_splanes(a6)
      addq.w    #1,d7
      mulu.w    fd_wdwidth(a4),d7
      add.w     d7,d7
      move.w    d7,r_swidth(a6)
      mulu.w    fd_h(a4),d7
      move.l    d7,r_snxtwork(a6)
      move.l    (v_bas_ad).w,d7
      cmp.l     r_saddr(a6),d7
      bne.s     vro_des
      move.w    fd_w(a4),d7
      cmp.w     (V_REZ_HZ).w,d7
      bne.s     vro_des
      move.w    (PLANES).w,d7
      subq.w    #1,d7
      cmp.w     r_splanes(a6),d7
      bne.s     vro_des
vro_src_2:
      move.l    (v_bas_ad).w,r_saddr(a6)
      move.w    (BYTES_LIN).w,r_swidth(a6)
      move.l    bitmap_len(a6),r_snxtwork(a6)
      move.w    r_planes(a6),r_splanes(a6)
      tst.w     bitmap_width(a6)
      beq.s     vro_des
      move.l    bitmap_addr(a6),r_saddr(a6)
      move.w    bitmap_width(a6),r_swidth(a6)
      sub.w     bitmap_off_x(a6),d0
      sub.w     bitmap_off_y(a6),d1
      sub.w     bitmap_off_x(a6),d2
      sub.w     bitmap_off_y(a6),d3
vro_des:
      move.l    fd_addr(a5),r_daddr(a6)
      beq.s     vro_des_2
      move.w    fd_nplanes(a5),d7
      subq.w    #1,d7
      cmp.w     #7,d7
      bne.s     vro_des_1
      cmp.w     r_planes(a6),d7
      bge.s     vro_des_1
      move.w    r_planes(a6),d7
vro_des_1:
      move.w    d7,r_dplanes(a6)
      addq.w    #1,d7
      mulu.w    fd_wdwidth(a5),d7
      add.w     d7,d7
      move.w    d7,r_dwidth(a6)
      mulu.w    fd_h(a5),d7
      move.l    d7,r_dnxtwork(a6)
      move.l    (v_bas_ad).w,d7
      cmp.l     r_daddr(a6),d7
      bne.s     vro_width
      move.w    fd_w(a5),d7
      cmp.w     (V_REZ_HZ).w,d7
      bne.s     vro_width
      move.w    (PLANES).w,d7
      subq.w    #1,d7
      cmp.w     r_dplanes(a6),d7
      bne.s     vro_width
      move.w    (BYTES_LIN).w,r_dwidth(a6)
      bra.s     vro_width
vro_des_2:
      move.w    d2,d6
      move.w    d3,d7
      sub.w     d0,d6
      sub.w     d1,d7
      add.w     d4,d6
      add.w     d5,d7
      lea.l     clip_xmin(a6),a1
      cmp.w     (a1)+,d4
      bge.s     vro_clip1
      sub.w     -(a1),d4
      sub.w     d4,d0
      move.w    (a1)+,d4
vro_clip1:
      cmp.w     (a1)+,d5
      bge.s     vro_clip2
      sub.w     -(a1),d5
      sub.w     d5,d1
      move.w    (a1)+,d5
vro_clip2:
      sub.w     (a1)+,d6
      ble.s     vro_clip3
      sub.w     d6,d2
vro_clip3:
      sub.w     (a1),d7
      ble.s     vro_desa
      sub.w     d7,d3
vro_desa:
      move.l    (v_bas_ad).w,r_daddr(a6)
      move.w    (BYTES_LIN).w,r_dwidth(a6)
      move.l    bitmap_len(a6),r_dnxtwork(a6)
      move.w    r_planes(a6),r_dplanes(a6)
      move.w    bitmap_width(a6),d7
      beq.s     vro_width
      move.l    bitmap_addr(a6),r_daddr(a6)
      move.w    d7,r_dwidth(a6)
      sub.w     bitmap_off_x(a6),d4
      sub.w     bitmap_off_y(a6),d5
vro_width:
      exg       d2,d4
      exg       d3,d5
      sub.w     d0,d4
      bmi.s     vro_cpyfm2
      sub.w     d1,d5
      bmi.s     vro_cpyfm2
      move.w    r_dplanes(a6),d6
      cmp.w     r_planes(a6),d6
      bne.s     vro_cpyfm3
      movea.l   p_bitblt(a6),a0
      jsr       (a0)
vro_cpyfm2:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vro_cpyfm3:
      tst.w     d6
      bne.s     vro_cpyfm2
      move.l    (mono_bitblt).w,d6
      beq.s     vro_cpyfm2
      movea.l   d6,a0
      jsr       (a0)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vrt_cpyfm:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a3
      move.w    (a2)+,d0
      subq.w    #1,d0
      cmpi.w    #3,d0
      bhi.s     vro_cpyfm2
      move.w    d0,r_wmode(a6)
      move.w    (a2)+,d0
      move.w    (a2)+,d1
      cmp.w     colors(a6),d0
      bls.s     vrt_cpyfm1
      moveq.l   #1,d0
vrt_cpyfm1:
      cmp.w     colors(a6),d1
      bls.s     vrt_cpyfm2
      moveq.l   #1,d1
vrt_cpyfm2:
      move.w    d0,r_fgcol(a6)
      move.w    d1,r_bgcol(a6)
      movem.l   s_addr(a1),a4-a5
      movem.w   (a3),d0-d7
vrt_sx:
      cmp.w     d0,d2
      bge.s     vrt_sy
      exg       d0,d2
vrt_sy:
      cmp.w     d1,d3
      bge.s     vrt_dx
      exg       d1,d3
vrt_dx:
      cmp.w     d4,d6
      bge.s     vrt_dy
      exg       d4,d6
vrt_dy:
      cmp.w     d5,d7
      bge.s     vrt_src
      exg       d5,d7
vrt_src:
      move.l    fd_addr(a4),r_saddr(a6)
      bne.s     vrt_src_1
      move.l    (v_bas_ad).w,r_saddr(a6)
      move.w    (BYTES_LIN).w,r_swidth(a6)
      move.w    r_planes(a6),d7
      clr.w     d7
      tst.w     bitmap_width(a6)
      beq.s     vrt_src_2
      move.l    bitmap_addr(a6),r_daddr(a6)
      move.w    bitmap_width(a6),r_dwidth(a6)
      sub.w     bitmap_off_x(a6),d0
      sub.w     bitmap_off_y(a6),d1
      sub.w     bitmap_off_x(a6),d2
      sub.w     bitmap_off_y(a6),d3
      bra.s     vrt_src_2
vrt_src_1:
      move.w    fd_wdwidth(a4),d7
      add.w     d7,d7
      move.w    d7,r_swidth(a6)
      mulu.w    fd_h(a4),d7
      move.l    d7,r_snxtwork(a6)
      move.w    fd_nplanes(a4),d7
      subq.w    #1,d7
vrt_src_2:
      move.w    d7,r_splanes(a6)
      bne       vrt_cpyfm3
      move.l    fd_addr(a5),r_daddr(a6)
      beq.s     vrt_des_2
      move.w    fd_nplanes(a5),d7
      subq.w    #1,d7
      cmp.w     #7,d7
      bne.s     vrt_des_1
      cmp.w     r_planes(a6),d7
      bge.s     vrt_des_1
      move.w    r_planes(a6),d7
vrt_des_1:
      move.w    d7,r_dplanes(a6)
      addq.w    #1,d7
      mulu.w    fd_wdwidth(a5),d7
      add.w     d7,d7
      move.w    d7,r_dwidth(a6)
      mulu.w    fd_h(a5),d7
      move.l    d7,r_dnxtwork(a6)
      move.l    (v_bas_ad).w,d7
      cmp.l     r_daddr(a6),d7
      bne.s     vrt_width
      move.w    fd_w(a5),d7
      cmp.w     (V_REZ_HZ).w,d7
      bne.s     vrt_width
      move.w    (BYTES_LIN).w,r_dwidth(a6)
      bra.s     vrt_width
vrt_des_2:
      move.w    d2,d6
      move.w    d3,d7
      sub.w     d0,d6
      sub.w     d1,d7
      add.w     d4,d6
      add.w     d5,d7
      lea.l     clip_xmin(a6),a1
      cmp.w     (a1)+,d4
      bge.s     vrt_clip1
      sub.w     -(a1),d4
      sub.w     d4,d0
      move.w    (a1)+,d4
vrt_clip1:
      cmp.w     (a1)+,d5
      bge.s     vrt_clip2
      sub.w     -(a1),d5
      sub.w     d5,d1
      move.w    (a1)+,d5
vrt_clip2:
      sub.w     (a1)+,d6
      ble.s     vrt_clip3
      sub.w     d6,d2
vrt_clip3:
      sub.w     (a1),d7
      ble.s     vrt_desa
      sub.w     d7,d3
vrt_desa:
      move.l    (v_bas_ad).w,r_daddr(a6)
      move.w    (BYTES_LIN).w,r_dwidth(a6)
      move.w    r_planes(a6),r_dplanes(a6)
      move.l    bitmap_len(a6),r_dnxtwork(a6)
      move.w    bitmap_width(a6),d7
      beq.s     vrt_width
      move.l    bitmap_addr(a6),r_daddr(a6)
      move.w    d7,r_dwidth(a6)
      sub.w     bitmap_off_x(a6),d4
      sub.w     bitmap_off_y(a6),d5
vrt_width:
      exg       d2,d4
      exg       d3,d5
      sub.w     d0,d4
      bmi.s     vrt_cpyfm3
      sub.w     d1,d5
      bmi.s     vrt_cpyfm3
      move.w    r_dplanes(a6),d6
      cmp.w     r_planes(a6),d6
      bne.s     vrt_cpyfm4
      movea.l   p_expblt(a6),a0
      jsr       (a0)
vrt_cpyfm3:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vrt_cpyfm4:
      tst.w     d6
      bne.s     vrt_cpyfm3
      move.l    (mono_expblt).w,d6
      beq.s     vrt_cpyfm3
      movea.l   d6,a0
      jsr       (a0)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vr_trnfm:
      movem.l   d1-d7/a2-a5,-(sp)
      movea.l   (a0),a1
      movem.l   s_addr(a1),a0-a1
      movea.l   p_transform(a6),a2
      jsr       (a2)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_get_pixel:
      movem.l   d1-d2/a2,-(sp)
      movea.l   pb_intout(a0),a2
      movea.l   pb_ptsin(a0),a0
      move.w    (a0)+,d0
      move.w    (a0)+,d1
      movea.l   p_get_pixel(a6),a0
      jsr       (a0)
      cmpi.w    #15,r_planes(a6)
      bgt.s     v_get_pixel1
      move.w    d0,(a2)+
      movea.l   p_color_to_vdi(a6),a0
      jsr       (a0)
      move.w    d0,(a2)+
      movem.l   (sp)+,d1-d2/a2
                  rts
v_get_pixel1:
      swap      d0
      move.l    d0,(a2)+
      movem.l   (sp)+,d1-d2/a2
                  rts
vswr_mode:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
vswr_mode1:
      move.w    d0,(a0)
      subq.w    #1,d0
      move.w    d0,wr_mode(a6)
      subq.w    #3,d0
      bhi.s     vswr_mode2
                  rts
vswr_mode2:
      moveq.l   #1,d0
      bra.s     vswr_mode1
vs_color:
      movem.l   d1-d4,-(sp)
      movem.l   pb_intin(a0),a0
      move.w    (a0)+,d3
      cmp.w     colors(a6),d3
      bhi.s     vs_color8
      move.w    #1000,d4
vs_color1:
      move.w    (a0)+,d0
      bpl.s     vs_color2
      moveq.l   #0,d0
vs_color2:
      cmp.w     d4,d0
      ble.s     vs_color3
      move.w    d4,d0
vs_color3:
      move.w    (a0)+,d1
      bpl.s     vs_color4
      moveq.l   #0,d1
vs_color4:
      cmp.w     d4,d1
      ble.s     vs_color5
      move.w    d4,d1
vs_color5:
      move.w    (a0)+,d2
      bpl.s     vs_color6
      moveq.l   #0,d2
vs_color6:
      cmp.w     d4,d2
      ble.s     vs_color7
      move.w    d4,d2
vs_color7:
      movea.l   p_set_color(a6),a0
      jsr       (a0)
vs_color8:
      movem.l   (sp)+,d1-d4
                  rts
vsl_type:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
vsl_type1:
      move.w    d0,(a0)
      subq.w    #1,d0
      move.w    d0,l_style(a6)
      subq.w    #6,d0
      bhi.s     vsl_type2
                  rts
vsl_type2:
      moveq.l   #1,d0
      bra.s     vsl_type1
vsl_udstyle:
      movea.l   pb_intin(a0),a1
      move.w    (a1),l_udstyle(a6)
                  rts
vsl_width:
      movea.l   pb_ptsin(a0),a1
      movea.l   pb_ptsout(a0),a0
      move.w    (a1),d0
      subq.w    #1,d0
      cmpi.w    #98,d0
      bhi.s     vsl_width2
      or.w      #1,d0
vsl_width1:
      move.w    d0,(a0)
      move.w    d0,l_width(a6)
                  rts
vsl_width2:
      tst.w     d0
      bpl.s     vsl_width3
      moveq.l   #1,d0
      bra.s     vsl_width1
vsl_width3:
      moveq.l   #99,d0
      bra.s     vsl_width1
vsl_color:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
      cmp.w     colors(a6),d0
      bhi.s     vsl_color2
vsl_color1:
      move.w    d0,(a0)
      move.w    d0,l_color(a6)
                  rts
vsl_color2:
      moveq.l   #1,d0
      bra.s     vsl_color1
vsl_ends:
      movea.l   pb_intin(a0),a1
      move.w    (a1)+,d0
      cmp.w     #2,d0
      bls.s     vsl_ends1
      moveq.l   #0,d0
vsl_ends1:
      move.w    d0,l_start(a6)
      move.w    (a1),d0
      cmp.w     #2,d0
      bls.s     vsl_ends2
      moveq.l   #0,d0
vsl_ends2:
      move.w    d0,l_end(a6)
                  rts
vsm_type:
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      movea.l   pb_intout(a0),a1
      move.w    d0,(a1)
      subq.w    #1,d0
      cmpi.w    #5,d0
      bls.s     vsm_type1
      move.w    #3,(a1)
      moveq.l   #2,d0
vsm_type1:
      move.w    m_height(a6),d1
      move.w    d0,m_type(a6)
      add.w     d0,d0
      add.w     d0,d0
      bne.s     vsm_type2
      moveq.l   #1,d1
vsm_type2:
      movea.l   marker_a(pc,d0.w),a1
      move.l    a1,m_data(a6)
      move.w    2(a1),d0
      mulu.w    d1,d0
      swap      d0
      add.w     d1,d0
      move.w    d0,m_width(a6)
      move.l    a0,d1
                  rts
marker_a:
      dc.l      m_dot
      dc.l      m_plus
      dc.l      m_asterisk
      dc.l      m_square
      dc.l      m_cross
      dc.l      m_diamond
vsm_height:
      movea.l   pb_ptsin(a0),a1
      move.l    (a1),d1
      subq.w    #1,d1
      or.w      #1,d1
      bgt.s     vsm_height1
      moveq.l   #1,d1
vsm_height1:
      cmp.w     #999,d1
      ble.s     vsm_height2
      move.w    #999,d1
vsm_height2:
      move.w    d1,m_height(a6)
      move.w    m_type(a6),d0
      add.w     d0,d0
      add.w     d0,d0
      bne.s     vsm_height3
      moveq.l   #1,d1
vsm_height3:
      movea.l   marker_a(pc,d0.w),a1
      move.w    2(a1),d0
      mulu.w    d1,d0
      swap      d0
      add.w     d1,d0
      move.w    d0,m_width(a6)
      movea.l   pb_ptsout(a0),a1
      move.w    d0,(a1)+
      move.w    m_height(a6),(a1)
      move.l    a0,d1
                  rts
vsm_color:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
      cmp.w     colors(a6),d0
      bls.s     vsm_color1
      moveq.l   #1,d0
vsm_color1:
      move.w    d0,(a0)
      move.w    d0,m_color(a6)
                  rts
vdi_fktr:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vst_height3:
      movea.l   pb_ptsout(a0),a1
      move.l    #$00070006,d0
      movea.l   #$00080008,a0
      move.l    d0,(a1)+
      move.l    a0,(a1)+
      lea.l     t_width(a6),a1
      move.l    d0,(a1)+
      move.l    a0,(a1)+
      lea.l     t_base(a6),a1
      move.l    #$00060002,(a1)+ ; t_base=6,t_half=2
      moveq.l   #7,d0
      move.l    d0,(a1)+ ; t_descent=0,t_bottom=7
      swap      d0
      move.l    d0,(a1)+ ; t_ascent=7,t_top=0
      addq.l    #4,a1
      move.l    #$00010008,(a1)+ ; t_left_off=1,t_whole_off=8
      moveq.l   #0,d0
      move.l    d0,(a1)+ ; t_thicken=0, t_uline=0
      move.w    d0,t_prop(a6)
      lea.l     (font_hdr2).w,a0
      lea.l     t_fonthdr(a6),a1
      move.l    a0,(a1)+
      move.l    a0,(CUR_FONT).w
      lea.l     off_table(a0),a0
      move.l    (a0)+,(a1)+ ; off_table->t_offtab
      move.l    (a0)+,(a1)+ ; dat_table->t_image
      move.l    (a0)+,(a1)+ ; form_width/form_height -> t_iwidth/t_iheight
                  rts
vst_height0:
      movea.l   pb_ptsout(a0),a1
      move.l    #$0007000D,d0
      movea.l   #$00080010,a0
      move.l    d0,(a1)+
      move.l    a0,(a1)+
      lea.l     t_width(a6),a1
      move.l    d0,(a1)+
      move.l    a0,(a1)+
      lea.l     t_base(a6),a1
      move.l    #$000D0005,(a1)+
      move.l    #$0002000F,(a1)+
      move.l    #$000F0000,(a1)+
      addq.l    #4,a1
      moveq.l   #0,d0
      move.l    #$00010008,(a1)+
      move.l    d0,(a1)+
      move.w    d0,t_prop(a6)
      lea.l     (font_hdr3).w,a0
      lea.l     t_fonthdr(a6),a1
      move.l    a0,(a1)+
      move.l    a0,(CUR_FONT).w
      lea.l     off_table(a0),a0
      move.l    (a0)+,(a1)+ ; off_table->t_offtab
      move.l    (a0)+,(a1)+ ; dat_table->t_image
      move.l    (a0)+,(a1)+ ; form_width/form_height -> t_iwidth/t_iheight
                  rts
vst_height:
      movea.l   pb_ptsin(a0),a1
      move.l    (a1),d0
      clr.w     t_point_last(a6)
      cmp.w     t_height(a6),d0
      beq       vst_h_er
vst_h_sa:
      movem.l   d1-d7/a2,-(sp)
      movea.l   16(a0),a2
      move.w    d0,d1
      move.w    t_number(a6),d0
      move.w    d1,d7
      bgt.s     vst_h_st
      moveq.l   #1,d7
vst_h_st:
      movea.l   t_pointer(a6),a0
vst_height2:
      movea.l   a0,a1
      sub.w     top(a1),d1
      beq.s     vst_h_ca
      bpl.s     vst_h_lo
      neg.w     d1
vst_h_lo:
      move.l    next_font(a1),d2
      beq.s     vst_h_ca
      movea.l   d2,a1
      cmp.w     (a1),d0
      bne.s     vst_h_ca
      move.w    d7,d3
      sub.w     top(a1),d3
      bpl.s     vst_h_po
      neg.w     d3
vst_h_po:
      cmp.w     d1,d3
      bgt.s     vst_h_lo
      movea.l   a1,a0
      move.w    d3,d1
      bne.s     vst_h_lo
vst_h_ca:
      move.l    a0,t_fonthdr(a6)
      move.l    a0,(CUR_FONT).w
      movem.l   off_table(a0),d0-d2
      movem.l   d0-d2,t_offtab(a6)
      movem.w   first_ade(a0),d2-d3/d6 ; d2=first_ade, d3=last_ade, d6=top
      btst      #3,flags+1(a0)
      seq       d0
      move.b    d0,t_prop(a6)
      moveq.l   #0,d0
      move.w    d6,d1
      sub.w     d7,d1
      beq.s     vst_h_no
      moveq.l   #1,d0
      tst.w     d1
      bpl.s     vst_h_no
      moveq.l   #-1,d0
vst_h_no:
      move.b    d0,t_grow(a6)
      sub.w     d2,d3
      movem.w   d2-d3,t_first_ade(a6)
      moveq.l   #63,d0
      sub.w     d2,d0
      cmp.w     d3,d0
      bls.s     vst_h_un
      moveq.l   #0,d0
vst_h_un:
      move.w    d0,t_unknown_index(a6)
      moveq.l   #32,d0
      sub.w     d2,d0
      cmp.w     d3,d0
      bls.s     vst_h_sp
      moveq.l   #0,d0
vst_h_sp:
      move.w    d0,t_space_index(a6)
      move.w    left_offset(a0),d0
      move.w    form_height(a0),d5
      mulu.w    d7,d5
      divu.w    d6,d5
      move.w    d5,d4
      move.w    d5,d1
      lsr.w     #1,d1
      movem.w   thicken(a0),d2-d3
      cmp.w     d6,d7
      beq.s     vst_h_th1
      mulu.w    d7,d0
      mulu.w    d7,d2
      mulu.w    d7,d3
      divu.w    d6,d0
      divu.w    d6,d2
      divu.w    d6,d3
vst_h_th1:
      tst.b     t_prop(a6)
      bne.s     vst_h_th2
      moveq.l   #0,d2
vst_h_th2:
      cmp.w     #15,d2
      ble.s     vst_h_ul
      moveq.l   #15,d2
vst_h_ul:
      subq.w    #1,d3
      bpl.s     vst_h_of
      moveq.l   #0,d3
vst_h_of:
      movem.w   d0-d3,t_left_off(a6) ; t_whole_off/thicken/t_uline
      movem.w   max_char_width(a0),d1/d3
      move.w    d7,d2
      cmp.w     d6,d7
      beq.s     vst_h_pt
      mulu.w    d7,d1
      mulu.w    d7,d3
      divu.w    d6,d1
      divu.w    d6,d3
vst_h_pt:
      movem.w   d1-d4,(a2)
      movem.w   d1-d4,t_width(a6)
      move.w    d7,d0
      move.w    d6,d1
      sub.w     half(a0),d1
      move.w    d6,d2
      sub.w     ascent(a0),d2
      move.w    d4,d3
      subq.w    #1,d3
      move.w    d6,d4
      add.w     descent(a0),d4
      moveq.l   #0,d5
      cmp.w     d6,d7
      beq.s     vst_h_exit
      mulu.w    d7,d1
      mulu.w    d7,d2
      mulu.w    d7,d4
      divu.w    d6,d1
      divu.w    d6,d2
      divu.w    d6,d4
vst_h_exit:
      movem.w   d0-d5,t_base(a6)
      movem.l   (sp)+,d1-d7/a2
                  rts
vst_h_er:
      movea.l   pb_ptsout(a0),a1
      move.l    t_width(a6),(a1)+
      move.l    t_cwidth(a6),(a1)+
                  rts
vst_point0:
      tst.w     d0
      ble.s     vst_point2
      movem.l   pb_intout(a0),a0-a1
      move.w    d0,(a0)
      move.l    t_width(a6),(a1)+
      move.l    t_cwidth(a6),(a1)+
                  rts
vst_point:
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      cmp.w     t_point_last(a6),d0
      beq.s     vst_point0
vst_point2:
      movem.l   d1-d7/a2,-(sp)
      movea.l   d1,a2
      move.w    t_number(a6),d0
      moveq.l   #0,d1
      move.w    (a1),d1
      bgt.s     vst_point3
      moveq.l   #1,d1
      move.w    d1,t_point_last(a6)
vst_point3:
      movea.l   t_pointer(a6),a1
      moveq.l   #-1,d3
vst_p_lo:
      move.l    d1,d5
      move.w    2(a1),d2
      sub.w     d2,d5
      bmi.s     vst_p_ne
      cmp.w     d2,d5
      blt.s     vst_p_cm
      sub.w     d2,d5
      bset      #16,d5
vst_p_cm:
      cmp.w     d3,d5
      bhi.s     vst_p_ne
      bne.s     vst_p_sa
      btst      #16,d5
      bne.s     vst_p_ne
vst_p_sa:
      movea.l   a1,a0
      move.l    d5,d3
      beq.s     vst_p_po
vst_p_ne:
      move.l    84(a1),d2
      beq.s     vst_p_ca
      movea.l   d2,a1
      cmp.w     (a1),d0
      beq.s     vst_p_lo
vst_p_ca:
      addq.l    #1,d3
      bne.s     vst_p_po
      movea.l   t_pointer(a6),a0
      movea.l   a0,a1
      move.w    2(a0),d5
vst_p_sm:
      move.l    84(a1),d2
      beq.s     vst_p_po
      movea.l   d2,a1
      cmp.w     (a1),d0
      bne.s     vst_p_po
      cmp.w     2(a1),d5
      ble.s     vst_p_sm
      move.w    (a1),d5
      movea.l   a1,a0
      bra.s     vst_p_sm
vst_p_po:
      move.w    2(a0),d0
      move.w    40(a0),d7
      btst      #16,d3
      beq.s     vst_set_point
      add.w     d0,d0
      add.w     d7,d7
vst_set_point:
      movem.l   pb_intout(a2),a1-a2
      move.w    d0,(a1)
      move.w    d0,t_point_last(a6)
      bra       vst_h_ca
vst_rotation:
      movea.l   pb_intout(a0),a1
      movea.l   pb_intin(a0),a0
      move.w    (a0),d0
      ext.l     d0
      divs.w    #3600,d0
      swap      d0
      ext.l     d0
      bpl.s     vst_rot_
      addi.l    #3600,d0
vst_rot_:
      addi.w    #450,d0
      divu.w    #900,d0
      move.w    d0,t_rotation(a6)
      mulu.w    #$0384,d0
      move.w    d0,(a1)
                  rts
vst_font:
      movea.l   pb_intin(a0),a1
      move.w    (a1),d0
      movea.l   pb_intout(a0),a1
      move.w    d0,(a1)
      cmp.w     t_number(a6),d0
      beq.s     vst_font4
      movem.l   d1-d7/a2,-(sp)
      lea.l     (font_hdr1).w,a0
      cmp.w     #1,d0
      beq.s     vst_font2
      move.l    t_bitmap_fonts(a6),d1
      beq.s     vst_font1
      movea.l   d1,a0
vst_font1:
      cmp.w     (a0),d0
      beq.s     vst_font2
      movea.l   84(a0),a0
      move.l    a0,d1
      bne.s     vst_font1
      moveq.l   #1,d0
      lea.l     (font_hdr1).w,a0
      move.w    d0,(a1)
vst_font2:
      move.l    a0,t_pointer(a6)
      move.l    a0,(CUR_FONT).w
      lea.l     (ptsout).w,a2
      move.w    d0,t_number(a6)
      clr.b     t_font_type(a6)
      moveq.l   #0,d1
      move.w    t_point_last(a6),d1
      bne.s     vst_font3
      move.w    t_height(a6),d1
      move.w    d1,d7
      bra       vst_height2
vst_font3:
      lea.l     (vdipb).w,a2
      move.l    #intout,pb_intout(a2)
      move.l    #ptsout,pb_ptsout(a2)
      bra       vst_point3
vst_font4:
                  rts
vst_color:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
      cmp.w     colors(a6),d0
      bhi.s     vst_color2
vst_color1:
      move.w    d0,(a0)
      move.w    d0,t_color(a6)
                  rts
vst_color2:
      moveq.l   #1,d0
      bra.s     vst_color1
vst_effects:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      moveq.l   #31,d0
      and.w     (a1),d0
      move.w    d0,(a0)
vst_effects1:
      move.w    d0,t_effects(a6)
                  rts
vst_alignment:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1)+,d0
      cmpi.w    #2,d0
      bls.s     vst_v_al
      moveq.l   #0,d0
vst_v_al:
      swap      d0
      move.w    (a1),d0
      cmp.w     #5,d0
      bls.s     vst_set_hor
      clr.w     d0
vst_set_hor:
      move.l    d0,t_hor(a6)
      move.l    d0,(a0)
                  rts
vsf_int_1:
      moveq.l   #0,d0
      move.w    d0,(a0)
      move.w    d0,f_interior(a6)
      lea.l     f_planes(a6),a0
      clr.w     (a0)
      bra.s     vsf_int_3
vsf_interior:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
vsf_int_2:
      move.w    d0,(a0)
      move.w    d0,f_interior(a6)
      subq.w    #4,d0
      bhi.s     vsf_int_1
      lea.l     f_planes(a6),a0
      clr.w     (a0)
      move.b    vsf_int_tab+4(pc,d0.w),d0
      jmp       vsf_int_7(pc,d0.w)
vsf_int_tab:
      dc.b vsf_int_3-vsf_int_7
      dc.b vsf_int_4-vsf_int_7
      dc.b vsf_int_5-vsf_int_7
      dc.b vsf_int_6-vsf_int_7
      dc.b vsf_int_7-vsf_int_7
      dc.b 0
vsf_int_3:
      move.l    f_fill0(a6),-(a0)
                  rts
vsf_int_4:
      move.l    f_fill1(a6),-(a0)
                  rts
vsf_int_5:
      movea.l   f_fill2(a6),a1
      move.w    f_style(a6),d0
      subq.w    #1,d0
      lsl.w     #5,d0
      adda.w    d0,a1
      move.l    a1,-(a0)
                  rts
vsf_int_6:
      movea.l   f_fill3(a6),a1
      move.w    f_style(a6),d0
      subq.w    #1,d0
      lsl.w     #5,d0
      adda.w    d0,a1
      move.l    a1,-(a0)
                  rts
vsf_int_7:
      move.w    f_splanes(a6),(a0)
      move.l    f_spointer(a6),-(a0)
                  rts
vsf_style:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    f_interior(a6),d0
      move.b    vsf_style_tab(pc,d0.w),d0
      jmp       vsf_style_tab(pc,d0.w)
vsf_style_tab:
      dc.b vsf_sty_0-vsf_style_tab
      dc.b vsf_sty_1-vsf_style_tab
      dc.b vsf_sty_2-vsf_style_tab
      dc.b vsf_sty_3-vsf_style_tab
      dc.b vsf_sty_4-vsf_style_tab
      dc.b 0
vsf_sty_0:
vsf_sty_1:
vsf_sty_4:
      move.w    (a1),d0
      move.w    d0,(a0)
      move.w    d0,f_style(a6)
                  rts
vsf_sty_2:
      move.w    (a1),d0
vsf_sty_2_1:
      move.w    d0,(a0)
      move.w    d0,f_style(a6)
      subq.w    #1,d0
      cmpi.w    #23,d0
      bhi.s     vsf_sty_2_2
      movea.l   f_fill2(a6),a0
      lsl.w     #5,d0
      adda.w    d0,a0
      move.l    a0,f_pointer(a6)
                  rts
vsf_sty_2_2:
      moveq.l   #1,d0
      bra.s     vsf_sty_2_1
vsf_sty_3:
      move.w    (a1),d0
vsf_sty_3_1:
      move.w    d0,(a0)
      move.w    d0,f_style(a6)
      subq.w    #1,d0
      cmpi.w    #21,d0
      bhi.s     vsf_sty_3_2
      movea.l   f_fill3(a6),a0
      lsl.w     #5,d0
      adda.w    d0,a0
      move.l    a0,f_pointer(a6)
                  rts
vsf_sty_3_2:
      moveq.l   #1,d0
      bra.s     vsf_sty_3_1
vsf_color:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
      cmp.w     colors(a6),d0
      bhi.s     vsf_color2
vsf_color1:
      move.w    d0,(a0)
      move.w    d0,f_color(a6)
                  rts
vsf_color2:
      moveq.l   #1,d0
      bra.s     vsf_color1
vsf_perimeter:
      movea.l   pb_intin(a0),a1
      movea.l   pb_intout(a0),a0
      move.w    (a1),d0
      move.w    d0,f_perimeter(a6)
      move.w    d0,(a0)
                  rts
vsf_udpat:
      move.l    a2,-(sp)
      movea.l   (a0),a1
      move.w    n_intin(a1),d0
      movea.l   pb_intin(a0),a0
      movea.l   f_spointer(a6),a1
      movea.l   p_set_pattern(a6),a2
      jsr       (a2)
      move.w    d0,f_splanes(a6)
      cmpi.w    #4,f_interior(a6)
      bne.s     vsf_udpat1
      move.w    d0,f_planes(a6)
vsf_udpat1:
      movea.l   (sp)+,a2
                  rts
vs_grayo:
      movea.l   pb_intin(a0),a0
      moveq.l   #0,d0
      move.w    (a0),d0
      bpl.s     vs_gor_m
      moveq.l   #0,d0
vs_gor_m:
      cmp.w     #1000,d0
      ble.s     vs_gor_s
      move.w    #1000,d0
vs_gor_s:
      add.w     #62,d0
      divu.w    #125,d0
      bne.s     vs_gor_a
      move.l    f_fill0(a6),f_pointer(a6)
      clr.w     f_planes(a6)
      clr.w     f_interior(a6)
                  rts
      beq.s     vs_gor_a
      addq.w    #4,d0
vs_gor_a:
      move.w    #2,f_interior(a6)
      move.w    d0,f_style(a6)
      movea.l   f_fill2(a6),a0
      subq.w    #1,d0
      lsl.w     #5,d0
      adda.w    d0,a0
      move.l    a0,f_pointer(a6)
      clr.w     f_planes(a6)
                  rts
v_setrgb:
                  rts
v140:
                  rts
v_pline_1:
      movem.l   d1-d5/a2-a5,-(sp)
      lea.l     -24(sp),a7
      movea.l   a7,a3
      movea.l   a0,a2
      move.l    pb_ptsin(a2),(a3)
      movea.l   (a2),a0
      move.w    2(a0),12(a3)
      moveq.l   #0,d3
      tst.w     l_start(a6)
      beq.s     no_start
      move.w    2(a0),d0
      movea.l   8(a2),a0
      movea.l   a3,a1
      bsr       dr_start
      moveq.l   #1,d3
      movea.l   8(a2),a5
      movea.l   (a3),a4
      cmpa.l    a4,a5
      beq.s     first_pt
      subq.l    #4,a4
      move.l    a4,(a3)
first_pt:
      move.l    (a4),d4
      move.l    4(a3),(a4)
no_start:
      tst.w     l_end(a6)
      beq.s     no_endfm
      movea.l   (a2),a0
      move.w    2(a0),d0
      movea.l   8(a2),a0
      movea.l   a3,a1
      bsr       dr_endfm
      addq.w    #2,d3
      movea.l   (a2),a0
      move.w    2(a0),d0
      subq.w    #1,d0
      ext.l     d0
      asl.l     #2,d0
      movea.l   8(a2),a5
      adda.l    d0,a5
      move.l    (a5),d5
      move.l    8(a3),(a5)
no_endfm:
      move.w    12(a3),d0
      movea.l   (a3),a0
      bsr.s     fat_line
      tst.w     d3
      beq.s     exit_vpl
      btst      #0,d3
      beq.s     _rest_xy
      move.l    d4,(a4)
_rest_xy:
      btst      #1,d3
      beq.s     exit_vpl
      move.l    d5,(a5)
exit_vpl:
      lea.l     24(sp),a7
      movem.l   (sp)+,d1-d5/a2-a5
                  rts
small_line:
      movem.l   d1-d7/a2-a3,-(sp)
      movea.l   a0,a3
      move.w    d0,d4
      subq.w    #2,d4
      bpl       v_plines1
      movem.l   (sp)+,d1-d7/a2-a3
                  rts
fat_line:
      cmpi.w    #1,l_width(a6)
      beq.s     small_line
      movem.l   d3-d6/a2-a4,-(sp)
      subq.w    #2,d0
      bmi.s     exit_fat
      lea.l     -16(sp),a7
      movea.l   a7,a4
      movea.l   a0,a2
      move.w    d0,d3
      tst.w     res_ratio(a6)
      beq.s     fat_qpix
      lea.l     -8(sp),a7
      movea.l   a7,a3
      move.w    l_width(a6),d6
      move.w    d6,d4
      cmpi.w    #1,res_ratio(a6)
      bne.s     _fat_STM
      move.w    d4,d5
      asr.w     #1,d4
      add.w     d6,d6
      bra.s     fat_TT_L
_fat_STM:
      asr.w     #1,d4
      move.w    d4,d5
      asr.w     #1,d5
fat_TT_L:
      movea.l   a2,a0
      movea.l   a3,a1
      bsr       conv_pix
      movea.l   a3,a0
      movea.l   a4,a1
      move.w    d6,d0
      bsr       calc_lin
      movea.l   a4,a0
      movea.l   a0,a1
      bsr       conv_q2p
      moveq.l   #4,d0
      movea.l   a4,a0
      bsr       v_fillline
      addq.l    #4,a2
      cmpi.w    #3,l_width(a6)
      ble.s     _fat_whi
      tst.w     d3
      ble.s     _fat_whi
      move.w    d3,-(sp)
      movem.w   (a2),d0-d1
      move.w    d4,d2
      move.w    d5,d3
      bsr       v_fillpie
      move.w    (sp)+,d3
_fat_whi:
      dbf       d3,fat_TT_L
      lea.l     24(sp),a7
exit_fat:
      movem.l   (sp)+,d3-d6/a2-a4
                  rts
fat_qpix:
      move.w    l_width(a6),d4
_fat_qpi:
      movea.l   a2,a0
      movea.l   a4,a1
      move.w    d4,d0
      bsr       calc_lin
      moveq.l   #4,d0
      movea.l   a4,a0
      bsr       v_fillline
      addq.l    #4,a2
      cmp.w     #3,d4
      ble.s     _fat_qwh
      tst.w     d3
      ble.s     _fat_qwh
      move.w    d3,-(sp)
      movem.w   (a2),d0-d1
      move.w    d4,d3
      asr.w     #1,d3
      move.w    d3,d2
      bsr       v_fillpie
      move.w    (sp)+,d3
_fat_qwh:
      dbf       d3,_fat_qpi
      lea.l     16(sp),a7
      movem.l   (sp)+,d3-d6/a2-a4
                  rts
conv_pix:
      move.w    res_ratio(a6),d0
      cmpi.w    #$FFFF,d0
      bne.s     _pix2q_T
      move.l    (a0)+,d0
      add.w     d0,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      add.w     d0,d0
      move.l    d0,(a1)
                  rts
_pix2q_T:
      cmp.w     #1,d0
      bne.s     exit_pix
      move.w    (a0)+,d0
      add.w     d0,d0
      move.w    d0,(a1)+
      move.l    (a0)+,d0
      add.w     d0,d0
      move.l    d0,(a1)+
      move.w    (a0),(a1)
exit_pix:
                  rts
conv_q2p:
      move.w    res_ratio(a6),d0
      cmpi.w    #$FFFF,d0
      bne.s     _q2pix_T
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)
                  rts
_q2pix_T:
      cmp.w     #1,d0
      bne.s     exit_q2p
      move.w    (a0)+,d0
      asr.w     #1,d0
      move.w    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.l    (a0)+,d0
      asr.w     #1,d0
      move.l    d0,(a1)+
      move.w    (a0),(a1)
exit_q2p:
                  rts
calc_lin:
      movem.l   d3-d7/a2-a3,-(sp)
      move.w    d0,d3
      movea.l   a0,a2
      movea.l   a1,a3
      move.w    (a0)+,d1
      ext.l     d1
      move.w    (a0)+,d2
      ext.l     d2
      move.w    (a0)+,d0
      ext.l     d0
      sub.l     d1,d0
      move.w    (a0)+,d1
      ext.l     d1
      sub.l     d2,d1
      move.l    d0,d6
      move.l    d1,d7
      tst.l     d0
      bpl.s     calc_dx_1
      neg.l     d0
calc_dx_1:
      tst.l     d1
      bpl.s     calc_dy_1
      neg.l     d1
calc_dy_1:
      move.l    d0,d4
      move.l    d1,d5
      cmp.w     #$ff,d4
      bgt.s     gross_hy
      cmp.w     #$ff,d5
      bgt.s     gross_hy
      lsl.w     #7,d5
      lsl.w     #7,d4
      move.w    d4,d0
      move.w    d5,d1
gross_hy:
      bsr.s     hypot
      mulu.w    d3,d5
      mulu.w    d3,d4
      divu.w    d0,d5
      lsr.w     #1,d5
      ext.l     d5
      tst.l     d7
      bpl.s     calc_dx_2
      neg.l     d5
calc_dx_2:
      divu.w    d0,d4
      lsr.w     #1,d4
      ext.l     d4
      tst.l     d6
      bpl.s     calc_dy_2
      neg.l     d4
calc_dy_2:
      movea.l   a2,a0
      move.w    (a0)+,d0
      sub.w     d5,d0
      move.w    (a0)+,d1
      add.w     d4,d1
      move.w    (a2)+,d2
      add.w     d5,d2
      move.w    (a2)+,d3
      sub.w     d4,d3
      movem.w   d0-d3,(a3)
      addq.l    #8,a3
      move.w    (a0)+,d0
      add.w     d5,d0
      move.w    (a0),d1
      sub.w     d4,d1
      move.w    (a2)+,d2
      sub.w     d5,d2
      move.w    (a2),d3
      add.w     d4,d3
      movem.w   d0-d3,(a3)
      movem.l   (sp)+,d3-d7/a2-a3
                  rts
hypot:
      move.l    d3,-(sp)
      mulu.w    d0,d0
      mulu.w    d1,d1
      add.l     d0,d1
      bne.s     sqrt
      moveq.l   #1,d0 ; WTF? sqrt(0) = 1?
      addq.l    #4,a7
                  rts
sqrt:
      moveq.l   #0,d0
      move.l    #$10000000,d2
lblA:
      move.l    d0,d3
      add.l     d2,d3
      lsr.l     #1,d0
      cmp.l     d3,d1
      bcs.s     lbl18
      sub.l     d3,d1
      add.l     d2,d0
lbl18:
      lsr.l     #2,d2
      bne.s     lblA
      cmp.l     d0,d1
      bls.s     exit_hypot
      addq.l    #1,d0
exit_hypot:
      move.l    (sp)+,d3
                  rts
dr_start:
      movem.l   d3-d7/a2-a3,-(sp)
      movea.l   a0,a2
      movea.l   a1,a3
      move.w    d0,d3
      move.w    l_start(a6),d0
      cmp.w     #2,d0
      bne.s     _strtfm_1
      move.l    (a2),4(a3)
      move.w    l_width(a6),d2
      cmp.w     #3,d2
      ble.s     exit_str
      asr.w     #1,d2
      move.w    d2,d3
      tst.w     res_ratio(a6)
      beq.s     _strt_el
      bpl.s     _st_ell_
      asr.w     #1,d3
      bra.s     _strt_el
_st_ell_:
      asl.w     #1,d3
_strt_el:
      movem.w   (a2),d0-d1
      bsr       v_fillpie
exit_str:
      movem.l   (sp)+,d3-d7/a2-a3
                  rts
_strtfm_1:
      cmp.w     #1,d0
      bne.s     exit_str
      move.w    d3,d0
      bsr       tstlin_f
      move.w    14(a3),d0
      move.w    16(a3),d1
      bsr       hypot
      move.w    l_width(a6),d2
      cmp.w     #1,d2
      bgt.s     _strtfm_2
      moveq.l   #9,d2
      bra.s     _strtfm_3
_strtfm_2:
      tst.w     res_ratio(a6)
      ble.s     _strtfm
      add.w     d2,d2
_strtfm:
      move.w    d2,d3
      add.w     d2,d2
      add.w     d3,d2
_strtfm_3:
      move.w    d2,d3
      mulu.w    14(a3),d2
      mulu.w    16(a3),d3
      divu.w    d0,d2
      divu.w    d0,d3
      tst.w     18(a3)
      beq.s     strt_dx_
      neg.w     d2
strt_dx_:
      tst.w     20(a3)
      beq.s     strt_dy_
      neg.w     d3
strt_dy_:
      lea.l     -16(sp),a7
      movea.l   a7,a0
      move.w    (a2)+,d0
      move.w    (a2),d1
      tst.w     res_ratio(a6)
      beq.s     _strt_qp
      bmi.s     _strt_ST
      add.w     d0,d0
      bra.s     _strt_qp
_strt_ST:
      add.w     d1,d1
_strt_qp:
      move.w    d0,(a0)+
      move.w    d1,(a0)+
      add.w     d2,d0
      add.w     d3,d1
      move.w    d0,d6
      move.w    d1,d7
      move.w    d0,d4
      move.w    d1,d5
      asr.w     #1,d2
      asr.w     #1,d3
      add.w     d3,d0
      sub.w     d2,d1
      sub.w     d3,d4
      add.w     d2,d5
      movem.w   d0-d1/d4-d7,(a0)
      movea.l   a7,a0
      movea.l   a0,a1
      bsr       conv_q2p
      moveq.l   #3,d0
      movea.l   a7,a0
      move.l    12(a0),4(a3)
      bsr       v_fillline
      lea.l     16(sp),a7
      movem.l   (sp)+,d3-d7/a2-a3
                  rts
dr_endfm:
      movem.l   d3-d7/a2-a3,-(sp)
      move.w    d0,d3
      subq.w    #1,d0
      ext.l     d0
      asl.l     #2,d0
      adda.l    d0,a0
      movea.l   a0,a2
      movea.l   a1,a3
      move.w    l_end(a6),d0
      cmp.w     #2,d0
      bne.s     _endfm_A
      move.l    (a0),8(a3)
      move.w    l_width(a6),d2
      cmp.w     #3,d2
      ble.s     exit_end
      asr.w     #1,d2
      move.w    d2,d3
      tst.w     res_ratio(a6)
      beq.s     _end_ell2
      bpl.s     _end_ell1
      asr.w     #1,d3
      bra.s     _end_ell2
_end_ell1:
      asl.w     #1,d3
_end_ell2:
      move.w    (a0)+,d0
      move.w    (a0)+,d1
      bsr       v_fillpie
exit_end:
      movem.l   (sp)+,d3-d7/a2-a3
                  rts
_endfm_A:
      cmp.w     #1,d0
      bne.s     exit_end
      move.w    12(a1),d0
      bsr       tstlin_b
      move.w    14(a3),d0
      move.w    16(a3),d1
      bsr       hypot
      move.w    l_width(a6),d2
      cmp.w     #1,d2
      bgt.s     _endfm_T
      moveq.l   #9,d2
      bra.s     _endfm_c
_endfm_T:
      tst.w     res_ratio(a6)
      ble.s     _endfm
      add.w     d2,d2
_endfm:
      move.w    d2,d3
      add.w     d2,d2
      add.w     d3,d2
_endfm_c:
      move.w    d2,d3
      mulu.w    14(a3),d2
      mulu.w    16(a3),d3
      divu.w    d0,d2
      divu.w    d0,d3
      tst.w     18(a3)
      beq.s     end_dx_p
      neg.w     d2
end_dx_p:
      tst.w     20(a3)
      beq.s     end_dy_p
      neg.w     d3
end_dy_p:
      lea.l     -16(sp),a7
      movea.l   a7,a0
      move.w    (a2)+,d0
      move.w    (a2),d1
      tst.w     res_ratio(a6)
      beq.s     _end_qpi
      bmi.s     _end_STM
      add.w     d0,d0
      bra.s     _end_qpi
_end_STM:
      add.w     d1,d1
_end_qpi:
      move.w    d0,(a0)+
      move.w    d1,(a0)+
      add.w     d2,d0
      add.w     d3,d1
      move.w    d0,d6
      move.w    d1,d7
      move.w    d0,d4
      move.w    d1,d5
      asr.w     #1,d2
      asr.w     #1,d3
      add.w     d3,d0
      sub.w     d2,d1
      sub.w     d3,d4
      add.w     d2,d5
      movem.w   d0-d1/d4-d7,(a0)
      movea.l   a7,a0
      movea.l   a0,a1
      bsr       conv_q2p
      moveq.l   #3,d0
      movea.l   a7,a0
      move.l    12(a0),8(a3)
      bsr       v_fillline
      lea.l     16(sp),a7
      movem.l   (sp)+,d3-d7/a2-a3
                  rts
tstlin_f:
      movem.l   d3-d7,-(sp)
      move.w    d0,d5
      move.l    a0,(a1)
      move.w    d0,12(a1)
      move.w    l_width(a6),d4
      add.w     d4,d4
      add.w     l_width(a6),d4
      ext.l     d4
      movem.w   (a0)+,d0-d1
      subq.w    #2,d5
_fwd_loop:
      moveq.l   #0,d6
      moveq.l   #0,d7
      movem.w   (a0)+,d2-d3
      sub.l     d0,d2
      bpl.s     _fwd_pos1
      neg.l     d2
      moveq.l   #-1,d6
_fwd_pos1:
      sub.l     d1,d3
      bpl.s     _fwd_pos2
      neg.l     d3
      moveq.l   #-1,d7
_fwd_pos2:
      cmp.l     d4,d2
      bge.s     _fwd_fou
      cmp.l     d4,d3
      bge.s     _fwd_fou
_fwd_cnt:
      dbf       d5,_fwd_loop
      addq.w    #1,d5
_fwd_fou:
      subq.l    #4,a0
      move.l    a0,(a1)
      move.w    res_ratio(a6),d0
      bpl.s     _fwd_TTL
      add.w     d3,d3
      bra.s     exit_fwd
_fwd_TTL:
      ble.s     exit_fwd
      add.w     d2,d2
exit_fwd:
      movem.w   d2-d3/d6-d7,14(a1)
      addq.w    #2,d5
      move.w    d5,12(a1)
      movem.l   (sp)+,d3-d7
                  rts
tstlin_b:
      movem.l   d3-d7,-(sp)
      move.w    d0,d5
      move.w    l_width(a6),d4
      add.w     d4,d4
      add.w     l_width(a6),d4
      ext.l     d4
      movem.w   (a0),d0-d1
      subq.w    #2,d5
_bk_loop:
      moveq.l   #0,d6
      moveq.l   #0,d7
      subq.l    #4,a0
      movem.w   (a0),d2-d3
      sub.l     d0,d2
      bpl.s     _bk_posd1
      neg.l     d2
      moveq.l   #-1,d6
_bk_posd1:
      sub.l     d1,d3
      bpl.s     _bk_posd2
      neg.l     d3
      moveq.l   #-1,d7
_bk_posd2:
      cmp.l     d4,d2
      bge.s     _bk_found
      cmp.l     d4,d3
      bge.s     _bk_found
_bk_cntr:
      dbf       d5,_bk_loop
      addq.w    #1,d5
_bk_found:
      move.w    res_ratio(a6),d0
      bpl.s     _bk_TTLO
      add.w     d3,d3
      bra.s     exit_bk
_bk_TTLO:
      ble.s     exit_bk
      add.w     d2,d2
exit_bk:
      movem.w   d2-d3/d6-d7,14(a1)
      addq.w    #2,d5
      move.w    d5,12(a1)
      movem.l   (sp)+,d3-d7
                  rts
v_pline_2:
      tst.w     n_intin(a1)
      beq       v_pline_1
      cmpi.w    #13,opcode2(a1)
      beq       v_bez
      tst.w     bez_on(a6)
      bne       v_bez
      bra       v_pline_1
v_pline:
      movea.l   (a0),a1
      movep.w   l_start+1(a6),d0
      add.w     l_width(a6),d0
      add.w     n_intin(a1),d0
      subq.w    #1,d0
      bne.s     v_pline_2
v_pline_3:
      move.w    2(a1),d0
      subq.w    #2,d0
      bne.s     v_plines
v_pline1:
      movem.l   d2-d7,-(sp)
      pea.l     v_pline_4(pc)
      move.w    l_style(a6),d0
      add.w     d0,d0
      move.w    l_styles(a6,d0.w),d6
      movea.l   pb_ptsin(a0),a1
      movem.w   (a1),d0-d3
      cmp.w     d1,d3
      beq       hline
      cmp.w     d0,d2
      beq       vline
      bra       line
v_pline_4:
      movem.l   (sp)+,d2-d7
      move.l    a0,d1
                  rts
v_plines:
      bmi.s     v_pline_7
      movem.l   d1-d7/a2-a3,-(sp)
      movea.l   8(a0),a3
      move.w    d0,d4
v_plines1:
      move.w    l_style(a6),d0
      add.w     d0,d0
      movea.w   l_styles(a6,d0.w),a2
      cmpi.w    #2,wr_mode(a6)
      bne.s     v_pline_5
      not.w     l_lastpix(a6)
v_pline_5:
      movea.w   d4,a0
      movem.w   (a3),d0-d3
      addq.l    #4,a3
      move.w    a2,d6
      pea.l     v_pline_6(pc)
      cmp.w     d1,d3
      beq       hline
      cmp.w     d0,d2
      beq       vline
      bra       line
v_pline_6:
      move.w    a0,d4
      dbf       d4,v_pline_5
      movem.l   (sp)+,d1-d7/a2-a3
v_pline_7:
      clr.w     l_lastpix(a6)
                  rts
search_min_max:
      movem.l   d0/d2-d7/a0,-(sp)
      subq.w    #1,d0
      movem.w   (a3),d4-d7
min_max_:
      move.w    (a0)+,d2
      move.w    (a0)+,d3
      cmp.w     d2,d4
      ble.s     search_m1
      move.w    d2,d4
search_m1:
      cmp.w     d3,d5
      ble.s     search_m2
      move.w    d3,d5
search_m2:
      cmp.w     d2,d6
      bge.s     search_m3
      move.w    d2,d6
search_m3:
      cmp.w     d3,d7
      bge.s     search_m4
      move.w    d3,d7
search_m4:
      dbf       d0,min_max_
      movem.w   d4-d7,(a3)
      movem.l   (sp)+,d0/d2-d7/a0
                  rts
v_bez:
      movem.l   d1-d7/a2-a5,-(sp)
      move.l    a0,-(sp)
      move.l    l_start(a6),-(sp)
      moveq.l   #0,d5
      moveq.l   #0,d6
      movea.l   (a0),a1
      move.w    n_ptsin(a1),d7
      ble       v_bez_ex
      moveq.l   #-1,d2
      subq.w    #1,d7
      movea.l   pb_ptsout(a0),a3
      move.l    res_x(a6),(a3)
      clr.l     4(a3)
      movea.l   pb_ptsin(a0),a4
      movea.l   pb_intin(a0),a5
      move.w    #2,l_end(a6)
v_bez_lo:
      addq.w    #1,d2
      move.w    a5,d3
      moveq.l   #1,d0
      and.w     #1,d3
      beq.s     v_bezarr
      moveq.l   #-1,d0
v_bezarr:
      moveq.l   #3,d3
      tst.w     d7
      bne.s     v_bez_ar
      move.w    2(sp),l_end(a6)
      and.b     0(a5,d0.w),d3
      bra.s     v_bez_dr
v_bez_ar:
      and.b     0(a5,d0.w),d3
      beq       v_bez_ne
v_bez_dr:
      addq.w    #1,d2
      move.w    d2,d0
      movea.l   a4,a0
      add.w     d2,d2
      add.w     d2,d2
      adda.w    d2,a4
      moveq.l   #-1,d2
      btst      #1,d3
      beq.s     v_bez_li
      subq.w    #1,d0
      addq.w    #1,d6
      cmp.w     #3,d3
      beq.s     v_bez_li
      moveq.l   #0,d2
      subq.l    #4,a4
v_bez_li:
      cmp.w     #2,d0
      blt.s     v_bez_be
      add.w     d0,d5
      bsr       search_min_max
      bsr.s     bez_line
      move.w    #2,l_start(a6)
v_bez_be:
      and.w     #1,d3
      beq.s     v_bez_ne
      subq.w    #3,d7
      blt.s     v_bez_ex
      bne.s     v_bez_sa
      move.w    2(sp),l_end(a6)
v_bez_sa:
      movem.w   d5-d7,-(sp)
      movem.w   -4(a4),d0-d7
      movea.w   bez_qual(a6),a0
      movea.l   buffer_addr(a6),a2
      lea.l     1024(a2),a1
      bsr       calc_bez
      movem.w   (sp)+,d5-d7
      add.w     d0,d5
      movea.l   buffer_addr(a6),a0
      lea.l     1024(a0),a0
      bsr       search_min_max
      bsr.s     bez_line
      move.w    #2,l_start(a6)
      moveq.l   #-1,d2
      addq.w    #1,d7
      addq.l    #2,a5
      lea.l     8(a4),a4
v_bez_ne:
      addq.l    #1,a5
      dbf       d7,v_bez_lo
v_bez_ex:
      move.l    (sp)+,l_start(a6)
      movea.l   (sp)+,a0
      movea.l   pb_intout(a0),a1
      move.w    d5,(a1)+
      move.w    d6,(a1)+
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
bez_line:
      cmpi.b    #3,driver_type(a6) ; DRIVER_NVDI
      bne.s     gdos_line
nvdi_line:
      lea.l     -52(sp),a7
      lea.l     20(sp),a1
      move.l    a0,8(sp)
      move.l    a1,(sp)
      move.l    a7,d1
      movea.l   d1,a0
      move.w    d0,2(a1)
      pea.l     nvdi_line1(pc)
      movep.w   l_start+1(a6),d0
      add.w     l_width(a6),d0
      subq.w    #1,d0
      bne       v_pline_1
      bra       v_pline_3
nvdi_line1:
      lea.l     52(sp),a7
                  rts
gdos_line:
      movem.l   d2/a2,-(sp)
      lea.l     -116(sp),a7
      lea.l     20(sp),a1
      move.l    a7,d1
      move.l    a0,-(sp)
      move.w    d0,-(sp)
      movea.l   d1,a0
      move.l    a1,(a0)+
      lea.l     l_start(a6),a2
      move.l    a2,(a0)+
      lea.l     32(a1),a2
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.w    #108,(a1)+ ; vsl_ends
      clr.l     (a1)+
      move.w    #2,(a1)+
      clr.l     (a1)+
      move.w    wk_handle(a6),(a1)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    (sp)+,d0
      movea.l   (sp)+,a2
      move.l    a7,d1
      movea.l   d1,a0
      move.l    a2,pb_ptsin(a0)
      lea.l     20(a0),a1
      move.w    #6,(a1)+ ; v_pline
      move.w    d0,(a1)+
      clr.l     (a1)+
      clr.l     (a1)+
      move.w    wk_handle(a6),(a1)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      lea.l     116(sp),a7
      movem.l   (sp)+,d2/a2
                  rts
bez_max_tab:
      dc.w 4,7,13,25,49,97
calc_bez:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      move.l    a2,-(sp)
      lea.l     1024(a2),a2
      movem.w   d0-d7,(a1)
      moveq.l   #0,d0
      moveq.l   #5,d3
calc_bez1:
      move.w    (a1)+,d1
      ext.l     d1
      move.w    2(a1),d2
      ext.l     d2
      sub.l     d1,d2
      bpl.s     calc_bez2
      neg.l     d2
calc_bez2:
      add.l     d2,d0
      dbf       d3,calc_bez1
      cmp.l     #97,d0
      bge.s     calc_bez4
      move.w    a0,d2
      move.w    d2,d1
      add.w     d1,d1
      lea.l     bez_max_tab+2(pc,d1.w),a0
calc_bq_:
      cmp.w     -(a0),d0
      bge.s     calc_bez3
      dbf       d2,calc_bq_ ; ??? shouldn't that be d3?
      moveq.l   #0,d2
calc_bez3:
      movea.w   d2,a0
calc_bez4:
      subq.l    #8,a1
      movem.w   -4(a1),d0-d3
      swap      d0
      swap      d1
      swap      d2
      swap      d3
      swap      d4
      swap      d5
      swap      d6
      swap      d7
      move.w    #$8000,d0
      move.w    d0,d1
      move.w    d0,d2
      move.w    d0,d3
      move.w    d0,d4
      move.w    d0,d5
      move.w    d0,d6
      move.w    d0,d7
      asr.l     #1,d0
      asr.l     #1,d1
      asr.l     #1,d2
      asr.l     #1,d3
      asr.l     #1,d4
      asr.l     #1,d5
      asr.l     #1,d6
      asr.l     #1,d7
      bsr.s     generate
      movea.l   (sp)+,a2
      move.l    a1,d0
      sub.l     (sp)+,d0
      lsr.w     #2,d0
      cmp.w     #1,d0
      bgt.s     call_bez
      move.l    -4(a1),(a1)+
      addq.w    #1,d0
call_bez:
      movea.l   (sp)+,a0
                  rts
generate:
      cmpa.w    #0,a0
      beq.s     bez_out
      subq.w    #1,a0
      movem.l   d6-d7,-(a2)
      add.l     d4,d6
      asr.l     #1,d6
      add.l     d5,d7
      asr.l     #1,d7
      add.l     d2,d4
      asr.l     #1,d4
      add.l     d3,d5
      asr.l     #1,d5
      add.l     d0,d2
      asr.l     #1,d2
      add.l     d1,d3
      asr.l     #1,d3
      movem.l   d6-d7,-(a2)
      add.l     d4,d6
      asr.l     #1,d6
      add.l     d5,d7
      asr.l     #1,d7
      add.l     d2,d4
      asr.l     #1,d4
      add.l     d3,d5
      asr.l     #1,d5
      movem.l   d6-d7,-(a2)
      add.l     d4,d6
      asr.l     #1,d6
      add.l     d5,d7
      asr.l     #1,d7
      movem.l   d6-d7,-(a2)
      bsr.s     generate
      movem.l   (a2)+,d0-d7
      bsr.s     generate
      addq.w    #1,a0
                  rts
bez_out:
      swap      d2
      rol.l     #1,d2
      move.w    d2,(a1)+
      swap      d3
      rol.l     #1,d3
      move.w    d3,(a1)+
      swap      d2
      move.w    d3,d2
      cmp.l     -8(a1),d2
      bne.s     bez_out_1
      subq.l    #4,a1
bez_out_1:
      swap      d4
      rol.l     #1,d4
      move.w    d4,(a1)+
      swap      d5
      rol.l     #1,d5
      move.w    d5,(a1)+
      swap      d4
      move.w    d5,d4
      cmp.l     -8(a1),d4
      bne.s     bez_out_2
      subq.l    #4,a1
bez_out_2:
      swap      d6
      rol.l     #1,d6
      move.w    d6,(a1)+
      swap      d7
      rol.l     #1,d7
      move.w    d7,(a1)+
      swap      d6
      move.w    d7,d6
      cmp.l     -8(a1),d6
      bne.s     bez_out_3
      subq.l    #4,a1
bez_out_3:
                  rts
v_pmarker:
      movem.l   d1-d7/a2,-(sp)
      move.w    l_color(a6),-(sp)
      move.w    m_color(a6),l_color(a6)
      movem.l   (a0),a0-a2
      move.w    2(a0),d5
      subq.w    #1,d5
      bmi.s     v_pm_exit
      tst.w     m_type(a6)
      beq.s     v_pmarker3
      movea.l   m_data(a6),a0
      lea.l     -64(sp),a7
      movea.l   a7,a1
      bsr.w     v_pmbuild
v_pmarker1:
      move.w    (a2)+,d0
      move.w    (a2)+,d1
      move.w    d0,d2
      move.w    d1,d3
      movea.l   a7,a0
      move.w    (a0)+,d4
      move.w    d5,-(sp)
v_pmarker2:
      movem.w   d0-d4,-(sp)
      add.w     (a0)+,d0
      add.w     (a0)+,d1
      add.w     (a0)+,d2
      add.w     (a0)+,d3
      moveq.l   #-1,d6
      bsr       line
      movem.w   (sp)+,d0-d4
      dbf       d4,v_pmarker2
      move.w    (sp)+,d5
      dbf       d5,v_pmarker1
      lea.l     64(sp),a7
v_pm_exit:
      move.w    (sp)+,l_color(a6)
      movem.l   (sp)+,d1-d7/a2
                  rts
v_pmarker3:
      move.w    d5,-(sp)
      move.w    (a2)+,d0
      move.w    (a2)+,d1
      move.w    d1,d3
      moveq.l   #-1,d6
      bsr       vline
      move.w    (sp)+,d5
      dbf       d5,v_pmarker3
      move.w    (sp)+,l_color(a6)
      movem.l   (sp)+,d1-d7/a2
                  rts
v_pmbuild:
      move.w    (a0)+,d0
      subq.w    #1,d0
      move.w    d0,(a1)+
      add.w     d0,d0
      addq.w    #1,d0
      addq.l    #2,a0
      move.w    m_width(a6),d1
      move.w    (a0)+,d2
      mulu.w    d1,d2
      swap      d2
      move.w    (a0)+,d3
      mulu.w    d1,d3
      swap      d3
v_pmbuild1:
      move.w    (a0)+,d4
      mulu.w    d1,d4
      swap      d4
      sub.w     d2,d4
      move.w    d4,(a1)+
      move.w    (a0)+,d4
      mulu.w    d1,d4
      swap      d4
      sub.w     d3,d4
      move.w    d4,(a1)+
      dbf       d0,v_pmbuild1
                  rts
v_gtext:
      movem.l   d1-d7/a2-a5,-(sp)
v_gtext_1:
      movem.l   (a0),a1-a3
v_gtext_2:
      movea.l   p_gtext(a6),a4
      jsr       (a4)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_fillpie:
      movem.l   d3-d7/a2-a5,-(sp)
      move.l    f_color(a6),-(sp)
      move.w    f_planes(a6),-(sp)
      move.l    f_pointer(a6),-(sp)
      move.w    l_color(a6),f_color(a6)
      move.w    #1,f_interior(a6)
      clr.w     f_planes(a6)
      move.l    f_fill1(a6),f_pointer(a6)
      bsr       fellipse
      move.l    (sp)+,f_pointer(a6)
      move.w    (sp)+,f_planes(a6)
      move.l    (sp)+,f_color(a6)
      movem.l   (sp)+,d3-d7/a2-a5
                  rts
v_fillline:
      move.l    f_color(a6),-(sp)
      move.w    f_perimeter(a6),-(sp)
      move.w    f_planes(a6),-(sp)
      move.l    f_pointer(a6),-(sp)
      movem.l   d1-d7/a2-a5,-(sp)
      move.w    l_color(a6),f_color(a6)
      moveq.l   #1,d1
      move.w    d1,f_interior(a6)
      move.w    d1,f_perimeter(a6)
      clr.w     f_planes(a6)
      move.l    f_fill1(a6),f_pointer(a6)
      movea.l   a0,a3
      move.w    d0,d4
      subq.w    #1,d4
      bsr.s     v_fillarray3
      movem.l   (sp)+,d1-d7/a2-a5
      move.l    (sp)+,f_pointer(a6)
      move.w    (sp)+,f_planes(a6)
      move.w    (sp)+,f_perimeter(a6)
      move.l    (sp)+,f_color(a6)
                  rts
v_fillarray:
      movea.l   (a0),a1
      tst.w     n_intin(a1)
      beq.s     v_fillarray1
      cmpi.w    #13,opcode2(a1)
      beq       v_bez_fi
      tst.w     bez_on(a6)
      bne       v_bez_fi
v_fillarray1:
      movem.l   d1-d7/a2-a5,-(sp)
      pea.l     vdi_fktr(pc)
      movem.l   (a0),a1-a3
      move.w    2(a1),d0
      subq.w    #1,d0
      ble       fpoly_ex
      cmpi.w    #1,d0
      beq       v_fae_li
      cmpi.w    #3,d0
      beq       v_fae_bo1
      cmpi.w    #4,d0
      beq       v_fae_bo
v_fillarray2:
      move.w    2(a1),d4
      subq.w    #1,d4
v_fillarray3:
      cmpi.w    #$03FF,d4
      bhi       fpoly_ex
      subq.w    #1,d4
      move.w    d4,d6
      movea.l   buffer_addr(a6),a5
      move.w    #$7FFF,d5
      moveq.l   #0,d7
      movea.l   (a3),a4
vfa_minmax:
      move.l    (a3)+,d0
      cmp.w     d0,d5
      ble.s     vfa_max
      move.w    d0,d5
vfa_max:
      cmp.w     d0,d7
      bge.s     vfa_x2_y
      move.w    d0,d7
vfa_x2_y:
      move.l    (a3),d2
      cmp.w     d0,d2
      bge.s     vfa_x1_y
      exg       d0,d2
vfa_x1_y:
      move.l    d0,(a5)+
      move.w    d2,d3
      sub.w     d0,d3
      swap      d0
      swap      d2
      sub.w     d0,d2
      add.w     d2,d2
      move.w    d2,(a5)+
      move.w    d3,(a5)+
      dbf       d6,vfa_minmax
      move.l    (a3)+,d0
      cmp.w     d0,d5
      ble.s     vfa_max2
      move.w    d0,d5
vfa_max2:
      cmp.w     d0,d7
      bge.s     vfa_last
      move.w    d0,d7
vfa_last:
      cmpa.l    d0,a4
      beq.s     vfa_call
      move.l    a4,d2
      cmp.w     d0,d2
      bpl.s     vfill_ss
      exg       d0,d2
vfill_ss:
      move.l    d0,(a5)+
      move.w    d2,d3
      sub.w     d0,d3
      swap      d0
      swap      d2
      sub.w     d0,d2
      add.w     d2,d2
      move.w    d2,(a5)+
      move.w    d3,(a5)+
      addq.w    #1,d4
vfa_call:
      movea.l   buffer_addr(a6),a4
fpoly:
      move.w    clip_ymin(a6),d1
      move.w    clip_ymax(a6),d3
      cmp.w     d3,d5
      bgt.s     fpoly_ex
      cmp.w     d1,d7
      blt.s     fpoly_ex
      cmp.w     d1,d5
      bge.s     fpoly_cl
      move.w    d1,d5
fpoly_cl:
      cmp.w     d3,d7
      ble.s     fpoly_co
      move.w    d3,d7
fpoly_co:
      sub.w     d5,d7
fpoly_lo:
      movea.l   a4,a0
      movea.l   a5,a1
      movem.w   d4-d5/d7,-(sp)
      bsr.s     fpoly_hl
      movem.w   (sp)+,d4-d5/d7
      addq.w    #1,d5
      dbf       d7,fpoly_lo
      tst.w     f_perimeter(a6)
      beq.s     fpoly_ex
      move.w    l_color(a6),-(sp)
      move.w    f_color(a6),l_color(a6)
      cmpi.w    #2,wr_mode(a6)
      bne.s     fpoly_bo
      not.w     l_lastpix(a6)
fpoly_bo:
      movea.w   d4,a0
      movem.w   (a4)+,d0-d3
      asr.w     #1,d2
      add.w     d0,d2
      add.w     d1,d3
      moveq.l   #-1,d6
      pea.l     fpoly_br(pc)
      cmp.w     d1,d3
      beq       hline
      cmp.w     d0,d2
      beq       vline
      bra       line
fpoly_br:
      move.w    a0,d4
      dbf       d4,fpoly_bo
      clr.w     l_lastpix(a6)
      move.w    (sp)+,l_color(a6)
fpoly_ex:
                  rts
fpoly_hl:
      movea.l   a1,a3
fpoly_ca:
      move.w    d5,d1
      move.w    (a0)+,d0
      sub.w     (a0)+,d1
      move.w    (a0)+,d2
      move.w    (a0)+,d3
      beq.s     fpoly_ne
      cmp.w     d1,d3
      bls.s     fpoly_ne
      muls.w    d1,d2
      divs.w    d3,d2
      bmi.s     fpoly_sa
      addq.w    #1,d2
fpoly_sa:
      asr.w     #1,d2
      add.w     d0,d2
      move.w    d2,(a1)+
fpoly_ne:
      dbf       d4,fpoly_ca
      move.l    a1,d6
      sub.l     a3,d6
      subq.w    #4,d6
      bne.s     fpoly_po
      move.w    (a3)+,d0
      move.w    (a3)+,d2
      move.w    d5,d1
      bra       fline
fpoly_po:
      tst.w     d6
      bmi.s     fpoly_hl2
      addq.w    #4,d6
      lsr.w     #1,d6
      move.w    d6,d1
      subq.w    #2,d1
fpoly_bu1:
      move.w    d1,d0
      movea.l   a3,a1
fpoly_bu2:
      move.w    (a1)+,d2
      cmp.w     (a1),d2
      ble.s     fpoly_bu3
      move.w    (a1),-2(a1)
      move.w    d2,(a1)
fpoly_bu3:
      dbf       d0,fpoly_bu2
      dbf       d1,fpoly_bu1
      movea.w   d5,a2
      lsr.w     #1,d6
      subq.w    #1,d6
fpoly_dr:
      movea.w   d6,a0
      move.w    (a3)+,d0
      move.w    (a3)+,d2
      move.w    a2,d1
      bsr       fline
      move.w    a0,d6
      dbf       d6,fpoly_dr
fpoly_hl2:
                  rts
v_fae_bo:
      move.l    (a3),d0
      sub.l     16(a3),d0
      bne       v_fillarray2
v_fae_bo1:
      movem.w   (a3),d0-d7
      cmp.w     d1,d3
      bne.s     v_fa_tes
      cmp.w     d0,d6
      bne       v_fillarray2
      cmp.w     d2,d4
      bne       v_fillarray2
      cmp.w     d5,d7
      bne       v_fillarray2
      move.w    d5,d3
      bra.s     v_fa_per
v_fa_tes:
      cmp.w     d0,d2
      bne       v_fillarray2
      cmp.w     d1,d7
      bne       v_fillarray2
      cmp.w     d4,d6
      bne       v_fillarray2
      cmp.w     d3,d5
      bne       v_fillarray2
      move.w    d4,d2
v_fa_per:
      cmp.w     d1,d3
      bge.s     v_fa_per1
      exg       d1,d3
v_fa_per1:
      tst.w     f_perimeter(a6)
      bne       v_bar2
      cmp.w     d1,d3
      beq       fbox
      addq.w    #1,d1
      subq.w    #1,d3
      bra       fbox
v_fae_li:
      movem.w   (a3),d0-d3
      movea.l   f_pointer(a6),a0
      move.w    (a0),d6
      move.w    l_color(a6),-(sp)
      move.w    f_color(a6),l_color(a6)
      bsr       line
      move.w    (sp)+,l_color(a6)
v_cellarray:
                  rts
bez_pnt_tab:
      dc.w 4,7,13,25,49,97

v_bez_fi:
      movem.l   d1-d7/a2-a5,-(sp)
      movea.l   (a0),a1
      moveq.l   #0,d7
      move.w    2(a1),d7
      cmp.w     #3,d7
      blt       v_bezf_e
      move.l    bez_buf_len(a6),d0
      bne.s     v_bezf_m
      movea.l   buffer_addr(a6),a1
      move.l    buffer_len(a6),d0
v_bezf_m:
      move.l    d7,d1
      lsl.l     #3,d1
      add.l     d7,d1
      add.l     #MAX_PTS,d1
      cmp.l     d0,d1
      ble.s     v_bezf_s1
      move.l    d0,d7
      sub.l     #MAX_PTS,d7
      divu.w    #9,d7
v_bezf_s1:
      move.w    bez_qual(a6),-(sp)
      movea.l   8(a0),a4
      movea.l   pb_intin(a0),a0
      movea.l   a1,a2
      adda.l    d0,a2
      lea.l     -1024(a2),a2
      movea.l   a2,a5
      move.w    d7,d0
      addq.w    #1,d0
      and.w     #$FFFE,d0
      suba.w    d0,a5
      subq.w    #1,d7
      move.w    d7,d0
      lsr.w     #1,d0
      movea.l   a5,a3
v_bezf_s2:
      move.w    (a0)+,d1
      and.w     #$0303,d1
      rol.w     #8,d1
      move.w    d1,(a3)+
      dbf       d0,v_bezf_s2
      movea.l   a5,a0
      move.w    d7,d0
      moveq.l   #0,d2
      move.w    d7,d2
      addq.w    #1,d2
      moveq.l   #0,d3
v_bezf_p1:
      moveq.l   #1,d1
      and.b     (a0)+,d1
      beq.s     v_bezf_p2
      subq.w    #2,d0
      bmi.s     v_bezfq_
      subq.w    #3,d2
      addq.w    #1,d3
      addq.l    #2,a0
v_bezf_p2:
      dbf       d0,v_bezf_p1
v_bezfq_:
      move.w    bez_qual(a6),d0
      move.l    a5,d4
      sub.l     a1,d4
      lsl.l     #3,d2
      sub.l     d2,d4
      lea.l     bez_pnt_tab(pc),a0
v_bezf_q:
      move.w    d0,d1
      add.w     d1,d1
      move.w    0(a0,d1.w),d1
      mulu.w    d3,d1
      lsl.l     #3,d1
      cmp.l     d4,d1
      ble.s     v_bezf_s3
      subq.w    #1,d0
      bpl.s     v_bezf_q
      moveq.l   #0,d0
v_bezf_s3:
      move.w    d0,bez_qual(a6)
      moveq.l   #0,d6
      movea.l   a4,a3
      andi.b    #$01,(a5)
v_bezf_l1:
      move.l    (a4)+,d0
      move.l    (a4),d2
      tst.w     d7
      bne.s     v_bezf_c
      move.l    (a3),d2
      move.l    a4,d4
      subq.l    #8,d4
      cmp.l     a3,d4
      beq.s     v_bezf_c
      cmp.l     d0,d2
      beq       v_bezf_n
v_bezf_c:
      cmp.w     d0,d2
      bge.s     v_bezf_d1
      exg       d0,d2
v_bezf_d1:
      move.l    d0,(a1)+
      sub.w     d0,d2
      swap      d0
      swap      d2
      sub.w     d0,d2
      add.w     d2,d2
      swap      d2
      move.l    d2,(a1)+
      move.b    (a5)+,d4
      beq       v_bezf_n
      bclr      #1,d4
      beq.s     v_bezf_l2
      addq.w    #1,d6
      move.w    (a3)+,d2
      move.w    (a3)+,d3
      movea.l   a4,a3
      subq.l    #4,a3
      movem.w   -8(a4),d0-d1
      cmp.w     d1,d3
      bge.s     v_bezf_d2
      exg       d0,d2
      exg       d1,d3
v_bezf_d2:
      sub.w     d0,d2
      add.w     d2,d2
      sub.w     d1,d3
      movem.w   d0-d3,-16(a1)
      tst.w     d7
      bne.s     v_bezf_l2
      subq.l    #8,a1
v_bezf_l2:
      subq.b    #1,d4
      bne.s     v_bezf_n
      subq.w    #3,d7
      blt.s     v_bezf_f
      movem.w   d6-d7,-(sp)
      move.l    a2,-(sp)
      subq.l    #8,a1
      move.l    a1,-(sp)
      move.w    bez_qual(a6),d0
      lea.l     bez_pnt_tab(pc),a0
      add.w     d0,d0
      move.w    0(a0,d0.w),d0
      add.w     d0,d0
      add.w     d0,d0
      adda.w    d0,a1
      move.l    a1,-(sp)
      movem.w   -4(a4),d0-d7
      movea.w   bez_qual(a6),a0
      bsr       calc_bez
      movea.l   (sp)+,a0
      movea.l   (sp)+,a1
      movea.l   (sp)+,a2
      movem.w   (sp)+,d6-d7
      subq.w    #2,d0
v_bezf_b1:
      move.l    (a0)+,d2
      move.l    (a0),d3
      cmp.w     d2,d3
      bge.s     v_bezf_d3
      exg       d2,d3
v_bezf_d3:
      move.l    d2,(a1)+
      sub.w     d2,d3
      swap      d2
      swap      d3
      sub.w     d2,d3
      add.w     d3,d3
      swap      d3
      move.l    d3,(a1)+
      dbf       d0,v_bezf_b1
      addq.l    #8,a4
      addq.l    #2,a5
      andi.b    #$01,(a5)
      bra       v_bezf_l1
v_bezf_f:
      move.w    d7,d0
      beq.s     v_bezf_n
      subq.w    #2,d0
      bne.s     v_bezf_b2
      clr.b     1(a5)
v_bezf_b2:
      clr.b     (a5)
v_bezf_n:
      dbf       d7,v_bezf_l1
      move.w    (sp)+,bez_qual(a6)
      movea.l   (sp),a0
      movea.l   bez_buffer(a6),a4
      movea.l   buffer_addr(a6),a5
      move.l    a4,d0
      bne.s     v_bezf_p3
      movea.l   buffer_addr(a6),a4
      movea.l   a1,a5
v_bezf_p3:
      move.l    a1,d4
      sub.l     a4,d4
      lsr.l     #3,d4
      cmp.w     #2,d4
      blt.s     v_bezf_e
      movea.l   16(a0),a1
      movea.l   a4,a0
      move.w    d4,d0
      bsr.s     fsearch_
      move.l    (a1)+,d5
      move.l    (a1),d7
      subq.w    #1,d4
      pea.l     v_bezf_e(pc)
      cmpi.b    #3,driver_type(a6) ; DRIVER_NVDI
      beq       fpoly
      bra.s     gpoly
v_bezf_e:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
fsearch_:
      movem.l   d0-d7/a0,-(sp)
      subq.w    #1,d0
      movem.w   res_x(a6),d4-d5
      moveq.l   #0,d6
      moveq.l   #0,d7
fmin_max:
      move.w    (a0)+,d2
      move.w    (a0)+,d3
      cmp.w     d2,d4
      ble.s     fsearch_1
      move.w    d2,d4
fsearch_1:
      cmp.w     d3,d5
      ble.s     fsearch_2
      move.w    d3,d5
fsearch_2:
      cmp.w     d2,d6
      bge.s     fsearch_3
      move.w    d2,d6
fsearch_3:
      cmp.w     d3,d7
      bge.s     fsearch_4
      move.w    d3,d7
fsearch_4:
      move.w    (a0)+,d1
      asr.w     #1,d1
      add.w     d1,d2
      add.w     (a0)+,d3
      cmp.w     d2,d4
      ble.s     fsearch_5
      move.w    d2,d4
fsearch_5:
      cmp.w     d3,d5
      ble.s     fsearch_6
      move.w    d3,d5
fsearch_6:
      cmp.w     d2,d6
      bge.s     fsearch_7
      move.w    d2,d6
fsearch_7:
      cmp.w     d3,d7
      bge.s     fsearch_8
      move.w    d3,d7
fsearch_8:
      dbf       d0,fmin_max
      movem.w   d4-d7,(a1)
      movem.l   (sp)+,d0-d7/a0
                  rts
gpoly:
      move.w    clip_ymin(a6),d1
      move.w    clip_ymax(a6),d3
      cmp.w     d3,d5
      bgt       gpoly_ex
      cmp.w     d1,d7
      blt       gpoly_ex
      cmp.w     d1,d5
      bge.s     gpoly_cl
      move.w    d1,d5
gpoly_cl:
      cmp.w     d3,d7
      ble.s     gpoly_co
      move.w    d3,d7
gpoly_co:
      sub.w     d5,d7
      moveq.l   #0,d0
      bsr       gperimeter
gpoly_lo:
      movea.l   a4,a0
      movea.l   a5,a1
      movem.w   d4-d5/d7,-(sp)
      bsr.s     gpoly_hl
      movem.w   (sp)+,d4-d5/d7
      addq.w    #1,d5
      dbf       d7,gpoly_lo
      move.w    f_perimeter(a6),d0
      beq.s     gpoly_ex
      bsr       gperimeter
      bsr       gdos_get
      bsr       gdos_line0
      lea.l     -116(sp),a7
      lea.l     52(sp),a2
      lea.l     20(sp),a1
      movea.l   a7,a0
      move.l    a1,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
gpoly_bo:
      lea.l     20(sp),a1
      move.w    #6,(a1)+
      move.w    #2,(a1)+
      clr.l     (a1)+
      clr.l     (a1)+
      move.w    wk_handle(a6),(a1)
      move.l    a1,(sp)
      move.l    a4,8(sp)
      movem.w   (a4)+,d0-d3
      asr.w     #1,d2
      add.w     d0,d2
      add.w     d1,d3
      movem.w   d2-d3,-4(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      dbf       d4,gpoly_bo
      lea.l     116(sp),a7
      bsr       gdos_set
gpoly_ex:
                  rts
gpoly_hl:
      movea.l   a1,a3
gpoly_ca:
      move.w    d5,d1
      move.w    (a0)+,d0
      sub.w     (a0)+,d1
      move.w    (a0)+,d2
      move.w    (a0)+,d3
      beq.s     gpoly_ne
      cmp.w     d1,d3
      bls.s     gpoly_ne
      muls.w    d1,d2
      divs.w    d3,d2
      bmi.s     gpoly_sa
      addq.w    #1,d2
gpoly_sa:
      asr.w     #1,d2
      add.w     d0,d2
      move.w    d2,(a1)+
gpoly_ne:
      dbf       d4,gpoly_ca
      move.l    a1,d6
      sub.l     a3,d6
      subq.w    #4,d6
      bne.s     gpoly_po
      move.w    (a3)+,d0
      move.w    (a3)+,d2
      move.w    d5,d1
      bra.s     gdos_fli
gpoly_po:
      tst.w     d6
      bmi.s     gpoly_hl2
      addq.w    #4,d6
      lsr.w     #1,d6
      move.w    d6,d1
      subq.w    #2,d1
gpoly_bu1:
      move.w    d1,d0
      movea.l   a3,a1
gpoly_bu2:
      move.w    (a1)+,d2
      cmp.w     (a1),d2
      ble.s     gpoly_bu3
      move.w    (a1),-2(a1)
      move.w    d2,(a1)
gpoly_bu3:
      dbf       d0,gpoly_bu2
      dbf       d1,gpoly_bu1
      lsr.w     #1,d6
      subq.w    #1,d6
gpoly_dr:
      move.w    d6,-(sp)
      move.w    (a3)+,d0
      move.w    (a3)+,d2
      move.w    d5,d1
      bsr.s     gdos_fli
      move.w    (sp)+,d6
      dbf       d6,gpoly_dr
gpoly_hl2:
                  rts
gdos_fli:
      lea.l     -116(sp),a7
      lea.l     52(sp),a2
      lea.l     20(sp),a1
      movea.l   a7,a0
      move.l    a1,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.w    #114,(a1) ; vr_recfl
      move.w    #2,n_ptsin(a1)
      clr.w     n_intin(a1)
      move.w    wk_handle(a6),handle(a1)
      move.w    d0,(a2)+
      move.w    d1,(a2)+
      move.w    d2,(a2)+
      move.w    d1,(a2)+
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      cmpi.w    #9,driver_id(a6)
      bls.s     gdos_fli2
      move.w    #11,(a1) ; v_bar
      move.w    #1,opcode2(a1)
      addq.w    #1,-(a2)
      subq.w    #1,-4(a2)
gdos_fli2:
      jsr       (a0)
      lea.l     116(sp),a7
                  rts
gperimeter:
      movem.l   d0-d2/a0-a2,-(sp)
      lea.l     2(sp),a2
      lea.l     -116(sp),a7
      lea.l     20(sp),a1
      move.l    a7,d1
      movea.l   d1,a0
      move.l    a1,(a0)+
      move.l    a2,(a0)+
      lea.l     32(a1),a2
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.w    #104,(a1)+ ; vsf_perimeter
      clr.l     (a1)+
      move.w    #1,(a1)
      move.w    wk_handle(a6),6(a1)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      lea.l     116(sp),a7
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
gdos_get:
      movem.l   d0-d2/a0-a2,-(sp)
      lea.l     -116(sp),a7
      lea.l     20(sp),a1
      move.l    a7,d1
      movea.l   d1,a0
      move.l    a1,(a0)+
      lea.l     32(a1),a2
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      move.l    a2,(a0)+
      lea.l     32(a2),a2
      move.l    a2,(a0)
      move.w    #35,(a1) ; vql_attributes
      clr.w     n_ptsin(a1)
      clr.w     n_intin(a1)
      move.w    wk_handle(a6),handle(a1)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      lea.l     52(sp),a1
      move.w    (a1)+,l_style(a6)
      move.w    (a1)+,l_color(a6)
      lea.l     28(a1),a1
      move.w    (a1),l_width(a6)
      lea.l     116(sp),a7
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
gdos_line0:
      movem.l   d0-d2/a0-a4,-(sp)
      lea.l     -116(sp),a7
      lea.l     20(sp),a3
      move.l    a7,d1
      movea.l   d1,a0
      move.l    a3,(a0)+
      lea.l     32(a3),a4
      move.l    a4,(a0)+
      move.l    a4,(a0)+
      lea.l     32(a4),a2
      move.l    a2,(a0)+
      move.l    a2,(a0)
      move.w    wk_handle(a6),handle(a3)
      move.w    #37,(a3) ; vqf_attributes
      clr.w     n_ptsin(a3)
      clr.w     n_intin(a3)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    86(sp),d0
      move.w    d0,f_color(a6)
      move.w    #17,(a3) ; vsl_color
      move.w    #1,n_intin(a3)
      move.w    d0,(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #15,(a3) ; vsl_type
      move.w    #1,(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #108,(a3) ; vsl_ends
      move.w    #2,n_intin(a3)
      clr.l     (a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #16,(a3) ; vsl_width
      move.w    #1,n_ptsin(a3)
      clr.w     n_intin(a3)
      move.w    #1,(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      lea.l     116(sp),a7
      movem.l   (sp)+,d0-d2/a0-a4
                  rts
gdos_set:
      movem.l   d0-d2/a0-a4,-(sp)
      lea.l     -116(sp),a7
      lea.l     20(sp),a3
      move.l    a7,d1
      movea.l   d1,a0
      move.l    a3,(a0)+
      lea.l     32(a3),a4
      move.l    a4,(a0)+
      move.l    a4,(a0)+
      lea.l     32(a4),a2
      move.l    a2,(a0)+
      move.l    a2,(a0)
      move.w    wk_handle(a6),handle(a3)
      move.w    #16,(a3) ; vsl_width
      move.w    #1,n_ptsin(a3)
      clr.w     n_intin(a3)
      move.w    l_width(a6),(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #108,(a3) ; vsl_ends
      clr.w     n_ptsin(a3)
      move.w    #2,n_intin(a3)
      move.l    l_start(a6),(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #17,(a3) ; vsl_color
      move.w    #1,n_intin(a3)
      move.w    l_color(a6),(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      move.w    #15,(a3) ; vsl_type
      move.w    l_style(a6),(a4)
      move.l    a7,d1
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      lea.l     116(sp),a7
      movem.l   (sp)+,d0-d2/a0-a4
                  rts
v_contour_fill:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a3
      bsr       v_contour
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
vr_recfl:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   pb_ptsin(a0),a0
      movem.w   (a0),d0-d3
      bsr       fbox_nor
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_gdp:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a3
      move.w    opcode2(a1),d0
      subq.w    #1,d0
      cmpi.w    #12,d0
      bhi.s     v_gdp_error
      add.w     d0,d0
      move.w    v_gdp_tab(pc,d0.w),d0
      jsr       v_gdp_tab(pc,d0.w)
v_gdp_error:
      movem.l   (sp)+,d1-d7/a2-a5
v_gdp_exit:
                  rts
v_gdp_tab:
      dc.w  v_bar-v_gdp_tab
      dc.w  v_arc-v_gdp_tab
      dc.w  v_pieslice-v_gdp_tab
      dc.w  v_circle-v_gdp_tab
      dc.w  v_ellipse-v_gdp_tab
      dc.w  v_ellarc-v_gdp_tab
      dc.w  v_ellpie-v_gdp_tab
      dc.w  v_rbox-v_gdp_tab
      dc.w  v_rfbox-v_gdp_tab
      dc.w  v_justified-v_gdp_tab
      dc.w  v_gdp_exit-v_gdp_tab
      dc.w  v_gdp_exit-v_gdp_tab
      dc.w  v_bez_on-v_gdp_tab
v_bar:
      movem.w  (a3),d0-d3
v_bar2:
      bsr   fbox
      tst.w f_perimeter(a6)
      beq.s v_bar_exit2
      cmp.w d1,d3
      bge.s v_bar_out
      exg   d1,d3
v_bar_out:
      move.w    l_color(a6),-(sp)
      move.w    f_color(a6),l_color(a6)
      bsr.s     hline_fill
      cmp.w     d1,d3
      beq.s     v_bar_exit
      exg       d1,d3
      bsr.s     hline_fill
      subq.w    #1,d1
      addq.w    #1,d3
      bsr.s     vline_fill
      exg       d0,d2
      cmp.w     d0,d2
      beq.s     v_bar_exit
      bsr.s     vline_fill
v_bar_exit:
      move.w    (sp)+,l_color(a6)
v_bar_exit2:
                  rts
hline_fill:
      movem.w   d0-d3,-(sp)
      moveq.l   #-1,d6
      bsr       hline
      movem.w   (sp)+,d0-d3
                  rts
vline_fill:
      movem.w   d0-d3,-(sp)
      moveq.l   #-1,d6
      bsr       vline
      movem.w   (sp)+,d0-d3
                  rts
v_pieslice:
      move.w    (a3)+,d0
      move.w    (a3)+,d1
      move.w    (a2)+,d4
      move.w    (a2)+,d5
      move.w    8(a3),d2
      move.w    d2,d3
      move.w    res_ratio(a6),d6
      beq       fellipse1
      add.w     d3,d3
      tst.w     d6
      bgt       fellipse1
      asr.w     #2,d3
      bra       fellipse1
v_circle:
      move.w    (a3)+,d0
      move.w    (a3)+,d1
      move.w    4(a3),d2
      move.w    d2,d3
      move.w    res_ratio(a6),d6
      beq.s     v_ellipse2
      add.w     d3,d3
      tst.w     d6
      bgt.s     v_ellipse2
      asr.w     #2,d3
      bra.s     v_ellipse2
v_ellipse:
      movem.w   (a3),d0-d3
v_ellipse2:
      bra       fellipse5
v_arc:
      move.w    (a3)+,d0
      move.w    (a3)+,d1
      move.w    8(a3),d2
      move.w    d2,d3
      move.w    res_ratio(a6),d6
      beq.s     v_ellarc2
      add.w     d3,d3
      tst.w     d6
      bgt.s     v_ellarc2
      asr.w     #2,d3
      bra.s     v_ellarc2
v_ellarc:
      movem.w   (a3),d0-d3
v_ellarc2:
      move.w    (a2)+,d4
      move.w    (a2)+,d5
      move.l    buffer_len(a6),-(sp)
      move.l    buffer_addr(a6),-(sp)
      bsr       ellipse_1
      move.l    a1,d1
      movea.l   (sp),a0
      sub.l     a0,d1
      move.l    d1,buffer_len(a6)
      move.l    a1,buffer_addr(a6)
      bsr       nvdi_line
      move.l    (sp)+,buffer_addr(a6)
      move.l    (sp)+,buffer_len(a6)
                  rts
v_ellpie:
      movem.w   (a3),d0-d3
      move.w    (a2)+,d4
      move.w    (a2)+,d5
      bra       fellipse1
v_rbox:
      movem.w   (a3),d0-d3
      move.l    buffer_len(a6),-(sp)
      move.l    buffer_addr(a6),-(sp)
      bsr       rbox_cal
      move.l    a3,d0
      sub.l     (sp),d0
      move.l    d0,buffer_len(a6)
      move.l    a3,buffer_addr(a6)
      movea.l   (sp),a0
      move.l    l_start(a6),-(sp)
      clr.l     l_start(a6)
      move.w    d4,d0
      bsr       nvdi_line
      move.l    (sp)+,l_start(a6)
      move.l    (sp)+,buffer_addr(a6)
      move.l    (sp)+,buffer_len(a6)
                  rts
v_rfbox:
      movem.w   (a3),d0-d3
      tst.w     f_perimeter(a6)
      beq       frbox
      bsr       frbox
      bsr       rbox_cal
      movea.l   buffer_addr(a6),a3
v_pline_8:
      subq.w    #2,d4
      bmi.s     vpfl_ex
      move.w    l_color(a6),-(sp)
      move.w    f_color(a6),l_color(a6)
      cmpi.w    #2,wr_mode(a6)
      bne.s     v_plfill1
      not.w     l_lastpix(a6)
v_plfill1:
      movea.w   d4,a0
      movem.w   (a3),d0-d3
      addq.l    #4,a3
      moveq.l   #-1,d6
      pea.l     v_plfill2(pc)
      cmp.w     d1,d3
      beq       hline
      cmp.w     d0,d2
      beq       vline
      bra       line
v_plfill2:
      move.w    a0,d4
      dbf       d4,v_plfill1
      clr.w     l_lastpix(a6)
      move.w    (sp)+,l_color(a6)
vpfl_ex:
                  rts
v_justified:
      tst.l     (a2)+
      bne.s     v_justified2
      subq.w    #2,n_intin(a1)
      move.l    a1,-(sp)
      movea.l   p_gtext(a6),a4
      jsr       (a4)
      movea.l   (sp)+,a1
      addq.w    #2,n_intin(a1)
                  rts
v_justified2:
      bra       text_jus
v_bez_on:
      movea.l   pb_intout(a0),a0
      tst.w     2(a1)
      bne.s     v_bez_on2
      clr.w     bez_on(a6)
      clr.w     (a0)
v_bez_oo:
                  rts
v_bez_on2:
      move.w    #5,bez_qual(a6)
      move.w    #7,(a0)
      move.w    #1,bez_on(a6)
                  rts
set_xbios:
      cmp.w     #4,d3
      bne.s     set_xbios1
      cmpi.w    #3,(nvdi_cookie_VDO).w
      beq.s     set_falc
set_xbios1:
      movem.l   d0-d1,-(sp)
      move.w    (resolution).w,d0
      tst.w     d3
      beq.s     set_res_2
      moveq.l   #3,d1
      cmpi.w    #2,(nvdi_cookie_VDO).w
      bne.s     set_res_1
      moveq.l   #7,d1
set_res_1:
      cmp.w     d1,d0
      beq.s     set_res_2
      cmp.w     d1,d3
      beq.s     set_res_2
      move.w    d3,d0
      subq.w    #1,d0
      cmp.w     #7,d0
      bgt.s     set_act_
      btst      d0,#$28
      beq       set_xbios3
set_act_:
      move.w    (resolution).w,d0
      subq.w    #1,d0
set_xbios3:
      bsr       set_resolution
set_res_2:
      movem.l   (sp)+,d0-d1
                  rts
set_falc:
      movem.l   d0-d2/a0-a2,-(sp)
      move.l    d1,-(sp)
      move.w    #$FFFF,-(sp)
      move.w    #$58,-(sp) ; VsetMode
      trap      #14
      addq.l    #4,a7
      movea.l   (sp)+,a0
      movea.l   pb_ptsout(a0),a0
      move.w    d0,(modecode).w
      cmp.w     (a0),d0
      beq.s     set_flc_
      move.w    (a0),(modecode).w
      move.w    (a0),-(sp)
      move.w    #3,-(sp)
      moveq.l   #-1,d0
      move.l    d0,-(sp)
      move.l    d0,-(sp)
      move.w    #5,-(sp)
      trap      #14
      lea.l     14(sp),a7
set_flc_:
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
opnwk_lo:
      bsr       set_xbios
      move.l    (screen_driver+driver_addr).w,d0
      movea.l   d0,a0
      tst.l     d0
      bne.s     opnwk_dr
                  rts
opnwk_dr:
      movem.l   d0-d2/a0-a2,-(sp)
      move.w    DRVR_planes(a0),d0
      cmp.w     (PLANES).w,d0
      beq.s     opnwk_dp
      bsr       unload_scr_drvr
      bsr       load_scr_drvr
opnwk_dp:
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
open_nvdi:
      move.w    d3,(first_device).w
      movea.l   (aes_wk_ptr).w,a6
      move.l    a6,(wk_tab).w
      moveq.l   #1,d4
      move.w    d3,driver_id(a6)
      move.w    d4,wk_handle(a6)
      move.w    d4,handle(a1)
      addq.w    #1,driver_use(a3)
      move.w    d4,driver_open_hdl(a3)
      bsr       init_font_nvdi
      bsr       init_res
      bsr       init_int
      movem.l   d1/a0-a1,-(sp)
      movea.l   a3,a0
      movea.l   driver_offscreen(a3),a1
      bsr       wk_defaults
      movem.l   (sp)+,d1/a0-a1
      movem.l   d1/a0-a1/a6,-(sp)
      movea.l   a3,a0
      movea.l   driver_offscreen(a3),a1
      movea.l   (linea_wk_ptr).w,a6
      bsr       wk_defaults
      movem.l   (sp)+,d1/a0-a1/a6
      bra       opnwk_io
set_disp:
      move.l    #handle_f,disp_addr1(a6)
      move.b    driver_status(a3),driver_type(a6)
                  rts
v_opnwk:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a5
      bsr       get_resolution
      move.w    (a2),d3
      subq.w    #1,d3
      cmpi.w    #9,d3
      bhi       opnwk_err1
      lea.l     (screen_driver).w,a3
      tst.w     driver_use(a3)
      bne.s     opnwk_op
      bsr       opnwk_lo
      tst.l     d0
      beq.s     opnwk_err1
      bsr       open_nvdi
      tst.l     (vdi_setup_ptr).w
      beq.s     v_opnwk_1
      lea.l     (CONTRL).w,a0
      move.l    a0,d1
      lea.l     (contrl).w,a1
      move.l    a1,(a0)+
      lea.l     (intin).w,a2
      move.l    a2,(a0)+
      move.l    #ptsin,(a0)+
      move.l    #intout,(a0)+
      move.l    #ptsout,(a0)+
      move.w    #21,(a1) ; vst_font
      move.w    #1,n_intin(a1)
      clr.w     n_ptsin(a1)
      move.w    #1,handle(a1)
      move.w    #1,(a2)
      moveq.l   #115,d0
      trap      #2
v_opnwk_1:
      move.l    #$45644449,d0
      move.l    #eddi_dispatch,d1
      bsr       init_cookie
opn_handle:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
opnwk_op:
      move.l    a6,d0
      bsr       Mfree
      lsl.w     #2,d4
      lea.l     (wk_tab-4).w,a6
      move.l    #closed,disp_addr1(a6,d4.w)
      move.w    d3,d0
      addq.w    #1,d0
opnwk_err1:
      movem.l   (sp)+,d1-d7/a2-a5
      movea.l   d1,a0
      movea.l   (a0),a1
      clr.w     handle(a1)
                  rts
alloc_wk:
      moveq.l   #0,d4
      moveq.l   #MAX_HANDLES-2,d2
      lea.l     (wk_tab+4).w,a6
opnwk_lo2:
      cmpi.l    #closed,(a6)+
      dbeq      d2,opnwk_lo2
      eori.w    #MAX_HANDLES-1,d2
      bpl.s     opnwk_alloc
      moveq.l   #-1,d0
      bra.s     alloc_wk1
opnwk_alloc:
      move.l    #WK_LENGTH,d0
      cmpi.b    #$03,9(a3)
      bne.s     opnwk_ge
      move.l    16(a3),d0
opnwk_ge:
      move.w    d0,-(sp)
      bsr       MallocA
      tst.l     d0
      bne.s     opnwk_sa
      addq.l    #2,a7
      moveq.l   #-3,d0
      bra.s     alloc_wk1
opnwk_sa:
      move.w    d2,d4
      addq.w    #1,d4
      move.l    d0,-(a6)
      movea.l   d0,a6
      move.w    (sp)+,d2
      lsr.w     #1,d2
      subq.w    #1,d2
opnwk_cl:
      clr.w     (a6)+
      dbf       d2,opnwk_cl
      movea.l   d0,a6
      move.w    d3,driver_id(a6)
      move.w    d4,wk_handle(a6)
alloc_wk1:
      move.w    d4,handle(a1)
                  rts
free_wk:
      lsl.w     #2,d0
      lea.l     (wk_tab-4).w,a0
      move.l    #closed,disp_addr1(a0,d0.w)
      move.l    a6,d0
      bra       Mfree
get_resolution:
      movem.l   d0-d2/a0-a2,-(sp)
      moveq.l   #0,d0
      move.b    (sshiftmd).w,d0
      addq.w    #1,d0
      move.w    d0,(resolution).w
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
set_resolution:
      movem.l   d0-d2/a0-a2,-(sp)
      move.w    d0,-(sp)
      moveq.l   #-1,d0
      move.l    d0,-(sp)
      move.l    d0,-(sp)
      move.w    #5,-(sp)
      trap      #14
      lea.l     12(sp),a7
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
opnwk_io:
      bsr       init_arr
      bsr.s     v_opnwk_setattr
      bsr.s     v_opnwk_2
opnwk_io2:
                  rts
v_opnwk_2:
      movem.l   d0-d2/a0-a5,-(sp)
      move.l    device_drvr(a6),d0
      beq.s     v_opnwk_3
      movea.l   d0,a2
      movea.l   driver_addr(a2),a2
      bra.s     v_opnwk_4
v_opnwk_3:
      movea.l   bitmap_drvr(a6),a2
      movea.l   DRIVER_code(a2),a2
v_opnwk_4:
      movea.l   DRVR_opnwkinfo(a2),a2
      movea.l   a4,a0
      movea.l   a5,a1
      jsr       (a2)
v_opnwk_5:
      movem.l   (sp)+,d0-d2/a0-a5
                  rts
call_nvd:
      lsl.w     #3,d0
      lea.l     vdi_tab(pc),a0
      move.l    4(a0,d0.w),-(sp)
      movea.l   d1,a0
                  rts
v_opnwk_setattr:
      movem.l   d0-d1/a0-a1/a3,-(sp)
      movea.l   d1,a0
      lea.l     pb_intin(a0),a3
      addq.l    #2,(a3)
      moveq.l   #15,d0 ; vsl_type
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #17,d0 ; vsl_color
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #18,d0 ; vsm_type
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #20,d0 ; vsm_color
      bsr.s     call_nvd
      movea.l   d1,a0
      pea.l     opnwk_tc(pc)
      cmpi.w    #320-1,res_y(a6)
      blt       vst_height3
      bra       vst_height0
opnwk_tc:
      addq.l    #4,(a3)
      moveq.l   #22,d0 ; vst_color
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #23,d0 ; vsf_interior
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #24,d0 ; vsf_style
      bsr.s     call_nvd
      addq.l    #2,(a3)
      moveq.l   #25,d0 ; vsf_color
      bsr.s     call_nvd
      subi.l    #18,(a3)
      movem.l   (sp)+,d0-d1/a0-a1/a3
                  rts
init_font_nvdi:
      movem.l   d0-d1/a0-a2,-(sp)
      lea.l     (font_hdr1).w,a1
      lea.l     (font_hdr2).w,a2
      lea.l     (FONT_RING).w,a0
      move.l    a1,(a0)+
      move.l    a2,(a0)+
      clr.l     (a0)+
      clr.l     (a0)+
      move.w    #1,(FONT_COUNT).w
      move.l    a2,(DEF_FONT).w
      move.l    76(a2),(V_FNT_AD).w
      moveq.l   #8,d0
      moveq.l   #0,d1
      move.w    (V_REZ_VT).w,d1
      cmpi.w    #400,d1
      blt.s     init_nvdi
      moveq.l   #16,d0
      lea.l     (font_hdr3).w,a2
init_nvdi:
      move.l    a2,(DEF_FONT).w
      move.l    76(a2),(V_FNT_AD).w
      move.w    d0,(V_CEL_HT).w
      divu.w    d0,d1
      subq.w    #1,d1
      move.w    d1,(V_CEL_MY).w
      movem.l   (sp)+,d0-d1/a0-a2
                  rts
init_res:
      movem.l   d0-d2/a0-a2,-(sp)
      movea.l   12(a3),a2
      movea.l   32(a2),a2
      lea.l     (DEV_TAB).w,a0
      lea.l     (SIZ_TAB).w,a1
      jsr       (a2)
      movea.l   12(a3),a2
      movea.l   36(a2),a2
      lea.l     (INQ_TAB).w,a0
      lea.l     -64(sp),a7
      movea.l   a7,a1
      jsr       (a2)
      lea.l     64(sp),a7
init_res1:
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
init_int:
      movem.l   d0-d7/a0-a6,-(sp)
      move.w    sr,-(sp)
      ori.w     #$0700,sr
      move.w    #256,d0
      lea.l     sys_time(pc),a0
      lea.l     (old_etv_timer).w,a1
      bsr       change_vec
      move.l    #dummy_rts,(USER_TIM).w
      move.l    (old_etv_timer).w,(NEXT_TIM).w
      move.l    #dummy_rts,(USER_BUT).w
      move.l    #user_cur,(USER_CUR).w
      move.l    #dummy_rts,(USER_MOT).w
      lea.l     mouse_form(pc),a2
      bsr       transform_mouse1
      clr.w     (MOUSE_BT).w
      clr.b     (CUR_MS_STAT).w
      clr.b     (MOUSE_FLAG).w
      moveq.l   #1,d0
      move.b    d0,(M_HID_CNT).w
      move.b    d0,(CUR_FLAG).w
      move.l    (DEV_TAB).w,d0
      lsr.l     #1,d0
      bclr      #15,d0
      move.l    d0,(GCURX).w
      move.l    d0,(CUR_X).w
      movea.l   (vbl_queue).w,a0
      move.l    #vbl_mouse2,(a0)
      lea.l     mouse_int(pc),a0
      move.l    a0,-(sp)
      pea.l     mouse_pa(pc)
      moveq.l   #1,d0
      move.l    d0,-(sp)
      trap      #14
      lea.l     12(sp),a7
      move.w    (sp)+,sr
      movem.l   (sp)+,d0-d7/a0-a6
                  rts
mouse_pa:
      dc.w  $0000,$0101
mouse_form:
      dc.w  $0001,$0001,$0001,$0000
      dc.w  $0001
      dc.w  $C000,$E000,$F000,$F800
      dc.w  $FC00,$FE00,$FF00,$FF80
      dc.w  $FFC0,$FFE0,$FE00,$EF00
      dc.w  $CF00,$8780,$0780,$0380
      dc.w  $0000,$4000,$6000,$7000
      dc.w  $7800,$7C00,$7E00,$7F00
      dc.w  $7F80,$7C00,$6C00,$4600
      dc.w  $0600,$0300,$0300,$0000

init_arr:
      movem.l  d0/a0/a6,-(sp)
      moveq.l   #-1,d0
      lea.l     (intin).w,a6
      move.l    d0,(a6)
      lea.l     (COLBIT0).w,a0
      move.l    d0,(a0)+
      move.l    d0,(a0)+
      move.l    d0,(a0)+
      move.w    d0,(TEXTFG).w
      clr.w     (TEXTBG).w
      move.l    (font_hdr3+dat_table).w,(FBASE).w
      move.w    (font_hdr3+form_width).w,(FWIDTH).w
      move.l    (buffer_ptr).w,(SCRTCHP).w
      move.w    #$2000,(SCRPT2).w
      move.l    #fill0,(PATPTR).w
      clr.w     (PATMSK).w
      move.w    #1,(V_HID_CNT).w
      clr.w     (MFILL).w
      cmpi.w    #8,(PLANES).w
      blt.s     init_la_
      clr.l     (COLBIT4).w
      clr.l     (COLBIT6).w
init_la_:
      movem.l   (sp)+,d0/a0/a6
                  rts
wk_init:
      move.l    a6,-(sp)
      movea.l   8(sp),a6
      moveq.l   #0,d1
      bsr.s     wk_defaults
      movea.l   (sp)+,a6
                  rts

;
; a0: ptr to screen_drv; can be null
; a1: ptr to offscreen driver; can be null
; a6: ptr to WK
;
wk_defaults:
      movem.l   d0-d2/a0-a1,-(sp)
      move.l    #handle_f,disp_addr1(a6)
      clr.l     disp_addr2(a6)
      move.l    (DEV_TAB).w,res_x(a6)
      move.l    (DEV_TAB+6).w,pixel_width(a6)
      move.w    (PLANES).w,d0
      subq.w    #1,d0
      move.w    d0,r_planes(a6)
      move.w    (DEV_TAB+26).w,d0
      subq.w    #1,d0
      move.w    d0,colors(a6)
      move.b    #3,driver_type(a6) ; DRIVER_NVDI
      clr.w     t_bitmap_gdos(a6)
      clr.w     res_ratio(a6)
      cmpa.l    (aes_wk_ptr).w,a6
      beq.s     wk_array
      movea.l   (aes_wk_ptr).w,a0
      move.w    res_ratio(a0),res_ratio(a6)
wk_array:
      move.b    #$0F,input_mode(a6)
      move.w    #5,bez_qual(a6)
      clr.l     bez_buffer(a6)
      clr.l     bez_buf_len(a6)
      clr.l     clip_xmin(a6)
      move.l    res_x(a6),clip_xmax(a6)
      clr.w     wr_mode(a6)
      lea.l     l_width(a6),a0
      move.w    #1,l_width(a6)
      clr.l     l_start(a6)
      clr.l     l_lastpix(a6) ; clrs also l_style
      lea.l     l_styles(a6),a0
      move.l    #$FFFFFFF0,(a0)+
      move.l    #$E0E0FF18,(a0)+
      move.l    #$FF00F198,(a0)+
      move.w    #$FFFF,(a0)+
      clr.l     t_effects(a6) ; clrs also
      clr.l     t_hor(a6)
      move.w    #1,t_number(a6)
      move.l    #font_hdr1,t_pointer(a6)
      move.l    (buffer_ptr).w,buffer_addr(a6)
      move.l    #NVDI_BUF_SIZE,buffer_len(a6)
      clr.l     t_point_height(a6)
      clr.l     t_bitmap_fonts(a6)
      clr.b     t_font_type(a6)
      move.b    #$01,t_mapping(a6)
      move.w    #$FFFF,t_no_kern(a6)
      clr.w     t_no_track(a6)
      clr.w     t_skew(a6)
      clr.w     t_track_index(a6)
      clr.l     t_track_offset(a6)
      move.w    #$ff,t_ades(a6)
      move.w    #1,f_perimeter(a6)
      lea.l     WK_LENGTH(a6),a0
      move.l    a0,f_spointer(a6)
      clr.w     f_splanes(a6)
      move.l    #fill0,f_fill0(a6)
      move.l    #fill1,f_fill1(a6)
      move.l    #fill2_1,f_fill2(a6)
      move.l    #fill3_1,f_fill3(a6)
      lea.l     fill4_1,a1
      moveq.l   #7,d0
init_wk_:
      move.l    (a1)+,(a0)+
      dbf       d0,init_wk_
      move.w    #9,m_height(a6)
      move.l    #text,p_gtext(a6)
      move.l    #v_escape,p_escape(a6)
      movem.l   (sp),d0-d2/a0-a1
      move.l    a0,device_drvr(a6)
      move.l    a1,bitmap_drvr(a6)
      move.l    a0,d0
      beq.s     wkdef_of
      movea.l   driver_addr(a0),a0
      move.l    DRVR_colors(a0),bitmap_colors(a6)
      move.w    DRVR_planes(a0),bitmap_planes(a6)
      move.w    DRVR_format(a0),bitmap_format(a6)
      move.w    DRVR_flags(a0),bitmap_flags(a6)
wkdef_of:
      move.l    a1,d0
      beq.s     wkdef_dr
      movea.l   DRIVER_code(a1),a1
      movea.l   DRVR_wk_init(a1),a1
      jsr       (a1)
wkdef_dr:
      movem.l   (sp),d0-d2/a0-a1
      move.l    a0,d0
      beq.s     wkdef_ex
      movea.l   driver_addr(a0),a0
      movea.l   DRVR_wk_init(a0),a0
      jsr       (a0)
wkdef_ex:
      moveq.l   #0,d0
      move.w    pixel_width(a6),d0
      move.w    pixel_height(a6),d1
      move.w    d0,d2
      lsr.w     #1,d2
      add.w     d2,d0
      divu.w    d1,d0
      subq.w    #1,d0
      move.w    d0,res_ratio(a6)
      movem.l   (sp)+,d0-d2/a0-a1
                  rts

init_mono_NOD:
      movem.l   d3-d7/a2-a6,-(sp)
      move.l    a0,(mono_DRVR).w
      movea.l   (linea_wk_ptr).w,a6
      movea.l   24(a0),a1
      jsr       (a1)
      move.l    p_bitblt(a6),(mono_bitblt).w
      move.l    p_expblt(a6),(mono_expblt).w
      movem.l   (sp)+,d3-d7/a2-a6
                  rts
Bconout: ; not exported!
      movem.l   d0-d2/a0-a2,-(sp)
      move.w    d0,-(sp)
      move.w    #2,-(sp)
      move.w    #3,-(sp)
      trap      #13
      addq.l    #6,a7
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
cldrvr:
      movem.l   d0-d2/a0-a2,-(sp)
      movea.l   disp_addr2(a6),a0
      jsr       (a0)
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
v_opnvwk:
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   (a0),a1-a5
      cmpi.w    #1,opcode2(a1)
      bne.s     v_opnvwk1
      cmpi.w    #20,n_intin(a1)
      beq.s     v_opnbm
v_opnvwk1:
      move.w    driver_id(a6),d3
      movea.l   device_drvr(a6),a3
      move.w    wk_handle(a6),d7
      bsr       alloc_wk
      tst.w     d4
      beq.s     v_opnvwk3
      movem.l   a0-a1,-(sp)
      movea.l   a3,a0
      movea.l   driver_offscreen(a3),a1
      bsr       wk_defaults
      movem.l   (sp)+,a0-a1
      addq.w    #1,driver_use(a3)
v_opnvwk2:
      bsr       opnwk_io
v_opnvwk3:
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_opnvwk4:
      move.w    d4,d0
      bsr       free_wk
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_opnbm:
      move.l    a2,-(sp)
      move.l    s_addr(a1),-(sp)
      movea.l   a6,a1
      movea.l   device_drvr(a6),a0
      jsr       create_bitmap
      addq.l    #8,a7
      move.l    a0,d0
      beq.s     v_opnbm_1
      movea.l   a0,a6
      movea.l   (sp),a0
      move.l    a0,d1 ; fetch VDIPB from saved D1
      movem.l   (a0),a1-a5
      move.w    wk_handle(a6),handle(a1)
      bsr       v_opnwk_setattr
      movea.l   bitmap_drvr(a6),a2
      movea.l   DRIVER_code(a2),a2
      movea.l   DRVR_opnwkinfo(a2),a2
      movea.l   a4,a0
      movea.l   a5,a1
      jsr       (a2)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_opnbm_1:
      movea.l   (sp),a0
      movea.l   (a0),a1
      clr.w     handle(a1)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
clear_bitmap:
      move.l    a6,-(sp)
      movea.l   a0,a6
      bsr       v_clrwk
      movea.l   (sp)+,a6
                  rts
transform_bitmap:
      movem.l   a2/a6,-(sp)
      movea.l   12(sp),a6
      movea.l   p_transform(a6),a2
      jsr       (a2)
      movem.l   (sp)+,a2/a6
                  rts
v_clswk_1:
      movem.l   (sp)+,d1-d2/a2
      bra       v_clsvwk
v_clswk:
      movem.l   d1-d3/a2,-(sp)
      movea.l   (a0),a1
      move.w    handle(a1),d0
      beq.s     v_clswk_5
      movea.l   device_drvr(a6),a2
      move.l    a2,d2
      beq.s     v_clswk_5
      cmp.w     24(a2),d0
      bne.s     v_clswk_1
      move.w    driver_id(a6),d2
      moveq.l   #127,d3
      lea.l     (wk_tab).w,a1
v_clswk_2:
      movea.l   (a1)+,a2
      cmp.w     10(a2),d2
      bne.s     v_clswk_4
      cmpa.l    (aes_wk_ptr).w,a2
      beq.s     v_clswk_3
      cmpa.l    a6,a2
      beq.s     v_clswk_3
      bsr.w     call_cls
      bra.s     v_clswk_4
v_clswk_3:
      move.l    #closed,-4(a1)
v_clswk_4:
      dbf       d3,v_clswk_2
      movem.l   d0/a0-a1/a6,-(sp)
      movea.l   (a0),a1
      move.w    #120,(a1) ; vst_unload_fonts
      bsr       vst_unload_fonts
      movem.l   (sp)+,d0/a0-a1/a6
      movea.l   (a0),a1
      move.w    #2,(a1) ; v_clswk
      movea.l   device_drvr(a6),a2
      clr.w     10(a2)
      movea.l   driver_addr(a2),a1
      movea.l   DRVR_wk_reset(a1),a1
      lea.l     (nvdi_struct).w,a0
      jsr       (a1)
      bsr.w     reset_int
      move.l    #$45644449,d0
      bsr       reset_cookie
v_clswk_5:
      movem.l   (sp)+,d1-d3/a2
                  rts
call_cls:
                  rts
v_clsvwk:
      movem.l   d1-d2/a2,-(sp)
      movea.l   (a0),a1
      move.w    handle(a1),d0
      beq.s     v_clsvwk2
      cmp.w     #1,d0
      beq.s     v_clsvwk3
      tst.l     bitmap_addr(a6)
      bne.s     v_clsbm
      movea.l   device_drvr(a6),a2
v_clsvwk1:
      movea.l   driver_addr(a2),a1
      movea.l   DRVR_wk_reset(a1),a1
      lea.l     (nvdi_struct).w,a0
      jsr       (a1)
      subq.w    #1,10(a2)
      bsr       free_wk
v_clsvwk2:
      movem.l   (sp)+,d1-d2/a2
                  rts
v_clsbm:
      movea.l   bitmap_drvr(a6),a1
      movea.l   4(a1),a1
      movea.l   DRVR_wk_reset(a1),a1
      lea.l     (nvdi_struct).w,a0
      jsr       (a1)
      movea.l   a6,a0
      jsr       delete_bitmap
      movem.l   (sp)+,d1-d2/a2
                  rts
v_clsvwk3:
      movem.l   (sp)+,d1-d2/a2
      cmp.w     #1,d0
      beq.s     v_clsvwk4
      bra       v_clswk
v_clsvwk4:
                  rts
reset_int:
      movem.l   d0-d2/a0-a2,-(sp)
      move.w    sr,-(sp)
      ori.w     #$0700,sr
      move.l    (old_etv_timer).w,(etv_timer).w
      lea.l     (USER_TIM).w,a0
      clr.l     (a0)+
      clr.l     (a0)+
      clr.l     (a0)+
      clr.l     (a0)+
      clr.l     (a0)+
      clr.l     -(sp)
      clr.l     -(sp)
      clr.l     -(sp)
      trap      #14
      lea.l     12(sp),a7
      movea.l   (vbl_queue).w,a0
      clr.l     (a0)
      move.w    (sp)+,sr
      movem.l   (sp)+,d0-d2/a0-a2
                  rts
v_clrwk:
      movem.l   d1-d7/a2-a5,-(sp)
      move.w    wr_mode(a6),-(sp)
      move.w    f_interior(a6),-(sp)
      move.l    f_pointer(a6),-(sp)
      move.w    f_planes(a6),-(sp)
      clr.w     wr_mode(a6)
      move.l    f_fill0(a6),f_pointer(a6)
      clr.w     f_planes(a6)
      clr.w     f_interior(a6)
      moveq.l   #0,d0
      moveq.l   #0,d1
      move.w    res_x(a6),d2
      move.w    res_y(a6),d3
      move.l    a6,-(sp)
      bsr       fbox_nor
      movea.l   (sp)+,a6
      move.w    (sp)+,f_planes(a6)
      move.l    (sp)+,f_pointer(a6)
      move.w    (sp)+,f_interior(a6)
      move.w    (sp)+,wr_mode(a6)
      movem.l   (sp)+,d1-d7/a2-a5
                  rts
v_updwk:
                  rts
vst_load_fonts:
      movem.l   d1-d3/a2-a5,-(sp)
      movea.l   (a0),a1
      movea.l   pb_intout(a0),a4
      tst.l     t_bitmap_fonts(a6)
      bne.s     vst_lfg_
      move.l    20(a1),d0 ; ??? thats contrl[10-11]???
      beq.s     vst_lfg_
      btst      #0,d0
      bne.s     vst_lfg_
      clr.w     t_bitmap_gdos(a6)
vst_lf_n:
      movea.l   d0,a0
      move.l    a0,t_bitmap_fonts(a6)
vst_lf_i:
      moveq.l   #-1,d0
      moveq.l   #0,d1
vst_lf_l:
      cmp.w     (a0),d0
      beq.s     vst_lf_f
      move.w    (a0),d0
      addq.w    #1,d1
vst_lf_f:
      tst.b     67(a0)
      bne.s     vst_lf_m
      movea.l   76(a0),a1
      move.w    80(a0),d2
      mulu.w    82(a0),d2
      lsr.w     #1,d2
      subq.w    #1,d2
vst_lf_s:
      move.w    (a1),d3
      ror.w     #8,d3
      move.w    d3,(a1)+
      dbf       d2,vst_lf_s
vst_lf_m:
      bset      #2,67(a0)
      movea.l   84(a0),a0
      move.l    a0,d2
      bne.s     vst_lf_l
      move.w    d1,(a4)
      move.l    t_bitmap_fonts(a6),(FONT_RING+8).w ; ???
      movem.l   (sp)+,d1-d3/a2-a5
                  rts
vst_lfg_:
      clr.w     (a4)
      movem.l   (sp)+,d1-d3/a2-a5
                  rts
vst_unload_fonts:
      movem.l   d1-d2/a2,-(sp)
      movea.l   (a0),a1
      tst.l     t_bitmap_fonts(a6)
      beq.s     vst_unload1
      clr.l     t_bitmap_fonts(a6)
vst_ulf_:
      movem.l   (sp)+,d1-d2/a2
      movea.l   d1,a0
      movem.l   d1-d7/a2,-(sp)
      moveq.l   #1,d0
      lea.l     (font_hdr1).w,a0
      bra       vst_font2
vst_unload1:
      movem.l   (sp)+,d1-d2/a2
                  rts
vs_clip:
      movem.l   pb_intin(a0),a0-a1
      tst.w     bitmap_width(a6)
      bne.s     vs_clip_13
      movem.l   d1-d5,-(sp)
      movem.w   (DEV_TAB).w,d4-d5
      move.w    (a0),d0
      move.w    d0,(CLIP).w
      beq.s     vs_clip_12
      move.w    (a1)+,d0
      bpl.s     vs_clip_1
      moveq.l   #0,d0
vs_clip_1:
      cmp.w     d4,d0
      ble.s     vs_clip_2
      move.w    d4,d0
vs_clip_2:
      move.w    (a1)+,d1
      bpl.s     vs_clip_3
      moveq.l   #0,d1
vs_clip_3:
      cmp.w     d5,d1
      ble.s     vs_clip_4
      move.w    d5,d1
vs_clip_4:
      move.w    (a1)+,d2
      bpl.s     vs_clip_5
      moveq.l   #0,d2
vs_clip_5:
      cmp.w     d4,d2
      ble.s     vs_clip_6
      move.w    d4,d2
vs_clip_6:
      move.w    (a1)+,d3
      bpl.s     vs_clip_7
      moveq.l   #0,d3
vs_clip_7:
      cmp.w     d5,d3
      ble.s     vs_clip_8
      move.w    d5,d3
vs_clip_8:
      cmp.w     d0,d2
      bge.s     vs_clip_9
      exg       d0,d2
vs_clip_9:
      cmp.w     d1,d3
      bge.s     vs_clip_10
      exg       d1,d3
vs_clip_10:
      movem.w   d0-d3,clip_xmin(a6)
      movem.w   d0-d3,(XMINCL).w
vs_clip_11:
      movem.l   (sp)+,d1-d5
                  rts
vs_clip_12:
      moveq.l   #0,d0
      moveq.l   #0,d1
      move.w    d4,d2
      move.w    d5,d3
      bra.s     vs_clip_10
vs_clip_13:
      movem.l   d1-d7,-(sp)
      movem.w   (a1),d0-d3
      movem.w   bitmap_off_x(a6),d4-d7
      add.w     d4,d6
      add.w     d5,d7
      tst.w     (a0)
      bne.s     vs_clip_14
      move.w    d4,d0
      move.w    d5,d1
      move.w    d6,d2
      move.w    d7,d3
vs_clip_14:
      cmp.w     d4,d0
      bge.s     vs_clip_15
      move.w    d4,d0
vs_clip_15:
      cmp.w     d6,d0
      ble.s     vs_clip_16
      move.w    d6,d0
vs_clip_16:
      cmp.w     d5,d1
      bge.s     vs_clip_17
      move.w    d5,d1
vs_clip_17:
      cmp.w     d7,d1
      ble.s     vs_clip_18
      move.w    d7,d1
vs_clip_18:
      cmp.w     d4,d2
      bge.s     vs_clip_19
      move.w    d4,d2
vs_clip_19:
      cmp.w     d6,d2
      ble.s     vs_clip_20
      move.w    d6,d2
vs_clip_20:
      cmp.w     d5,d3
      bge.s     vs_clip_21
      move.w    d5,d3
vs_clip_21:
      cmp.w     d7,d3
      ble.s     vs_clip_22
      move.w    d7,d3
vs_clip_22:
      cmp.w     d0,d2
      bge.s     vs_clip_23
      exg       d0,d2
vs_clip_23:
      cmp.w     d1,d3
      bge.s     vs_clip_24
      exg       d1,d3
vs_clip_24:
      movem.w   d0-d3,clip_xmin(a6)
      movem.l   (sp)+,d1-d7
                  rts
text_par:
      move.l    t_image(a6),-(sp)
      exg       d0,d2
      exg       d1,d3
      move.w    t_rotation(a6),d7
      beq.s     text_par1
      subq.w    #1,d7
      beq.s     text_par1
      exg       d1,d3
      subq.w    #1,d7
      beq.s     text_par1
      exg       d1,d3
      exg       d0,d2
text_par1:
      move.w    t_act_line(a6),d0
      move.w    t_cheight(a6),d1
      btst      #4,t_effects+1(a6)
      beq.s     text_par2
      moveq.l   #16,d5
      tst.w     d0
      beq.s     text_par3
      subq.w    #1,d0
      sub.w     d0,d1
      cmp.w     d5,d1
      ble.s     text_par3
      moveq.l   #17,d5
      bra.s     text_par3
text_par2:
      moveq.l   #15,d5
      sub.w     d0,d1
      cmp.w     d5,d1
      bgt.s     text_par3
      subq.w    #1,d1
      move.w    d1,d5
text_par3:
      move.w    d3,d4
      add.w     d5,d4
      movea.l   (sp),a1
      movem.w   d2-d3,-(sp)
      move.w    d6,-(sp)
      move.w    a3,-(sp)
      move.l    a5,-(sp)
      mulu.w    t_iheight(a6),d0
      divu.w    t_cheight(a6),d0
      mulu.w    t_iwidth(a6),d0
      adda.l    d0,a1
      move.l    a1,t_image(a6)
text_par4:
      move.w    t_space_(a6),-(sp)
      move.w    t_add_len(a6),-(sp)
      bsr       fill_tex
      move.w    (sp)+,t_add_len(a6)
      move.w    (sp)+,t_space_(a6)
      movea.l   buffer_addr(a6),a0
      movea.w   a3,a2
      move.w    t_effects(a6),d7
      beq.s     text_par9
text_par5:
      btst      #0,d7
      beq.s     text_par6
      bsr       bold
text_par6:
      btst      #3,t_effects+1(a6)
      beq.s     text_par7
      pea.l     text_par7(pc)
      btst      #4,t_effects+1(a6)
      beq       underlin1
      addq.l    #4,a7
      adda.w    a2,a0
      bsr       underlin1
      suba.w    a2,a0
text_par7:
      btst      #4,t_effects+1(a6)
      beq.s     text_par8
      bsr       outline
      subq.w    #2,d5
      move.w    t_act_line(a6),d0
      beq.s     text_par8
      adda.w    a2,a0
      adda.w    a2,a0
      addi.w    #16,d0
      cmp.w     t_cheight(a6),d0
      bge.s     text_par8
      subq.w    #2,d5
text_par8:
      btst      #1,t_effects+1(a6)
      beq.s     text_par9
      bsr       light
text_par9:
      movea.l   (sp)+,a5
      movea.w   (sp)+,a3
      move.w    (sp)+,d6
      movem.w   (sp)+,d2-d3
      move.w    t_rotation(a6),d7
      bne.s     textp_ro1
text_par10:
      btst      #2,t_effects+1(a6)
      bne.s     text_par13
      movem.l   d2-d6/a1/a3/a5,-(sp)
      bsr       textblt_1
      movem.l   (sp)+,d2-d6/a1/a3/a5
text_par11:
      addq.w    #1,d5
      add.w     d5,d3
      moveq.l   #16,d1
      add.w     t_act_line(a6),d1
      move.w    d1,t_act_line(a6)
      move.w    t_cheight(a6),d5
      sub.w     d1,d5
      bgt       text_par1
text_par12:
      move.l    (sp)+,t_image(a6)
                  rts
text_par13:
      movem.w   d3/d5-d6,-(sp)
      tst.w     t_act_line(a6)
      bne.s     text_par14
      sub.w     t_left_off(a6),d2
      add.w     t_whole_off(a6),d2
text_par14:
      move.w    #$5555,d6
      moveq.l   #0,d1
      move.w    d5,d7
textp_it1:
      moveq.l   #0,d5
      movem.l   d1-d7/a0-a5,-(sp)
      moveq.l   #0,d0
      bsr       textblt
      movem.l   (sp)+,d1-d7/a0-a5
      ror.w     #1,d6
      bcc.s     textp_it2
      subq.w    #1,d2
textp_it2:
      addq.w    #1,d3
      addq.w    #1,d1
      dbf       d7,textp_it1
      movem.w   (sp)+,d3/d5-d6
      bra.s     text_par11
textp_ro1:
      subq.w    #1,d7
      bne.s     textp_ro2
      movem.l   d6/a3/a5,-(sp)
      bsr       rotate90
      movem.l   (sp)+,d6/a3/a5
      btst      #2,t_effects+1(a6)
      bne.s     textp_it3
      movem.l   d2-d6/a3/a5,-(sp)
      bsr       textblt_1
      movem.l   (sp)+,d2-d6/a3/a5
text_par15:
      addq.w    #1,d4
      add.w     d4,d2
      moveq.l   #16,d1
      add.w     t_act_line(a6),d1
      move.w    d1,t_act_line(a6)
      move.w    t_cheight(a6),d5
      sub.w     d1,d5
      bgt       text_par1
      move.l    (sp)+,t_image(a6)
                  rts
textp_it3:
      movem.w   d2/d4-d6,-(sp)
      tst.w     t_act_line(a6)
      bne.s     text_par16
      add.w     t_left_off(a6),d3
      sub.w     t_whole_off(a6),d3
text_par16:
      move.w    #$5555,d6
      moveq.l   #0,d0
      move.w    d4,d7
textp_it4:
      moveq.l   #0,d4
      movem.l   d0/d2-d7/a0-a5,-(sp)
      bsr       textblt_2
      movem.l   (sp)+,d0/d2-d7/a0-a5
      ror.w     #1,d6
      bcc.s     textp_it5
      addq.w    #1,d3
textp_it5:
      addq.w    #1,d2
      addq.w    #1,d0
      dbf       d7,textp_it4
      movem.w   (sp)+,d2/d4-d6
      bra.s     text_par15
textp_ro2:
      subq.w    #1,d7
      bne.s     textp_ro3
      movem.l   d6/a3/a5,-(sp)
      bsr       rotate180
      movem.l   (sp)+,d6/a3/a5
      btst      #2,t_effects+1(a6)
      bne.s     textp_it6
      sub.w     d5,d3
      movem.l   d2-d6/a3/a5,-(sp)
      bsr       textblt_1
      movem.l   (sp)+,d2-d6/a3/a5
      subq.w    #1,d3
text_par17:
      moveq.l   #16,d1
      add.w     t_act_line(a6),d1
      move.w    d1,t_act_line(a6)
      move.w    t_cheight(a6),d5
      sub.w     d1,d5
      bgt       text_par1
      move.l    (sp)+,t_image(a6)
                  rts
textp_it6:
      movem.w   d5-d6,-(sp)
      tst.w     t_act_line(a6)
      bne.s     text_par18
      add.w     t_left_off(a6),d2
      sub.w     t_whole_off(a6),d2
text_par18:
      move.w    #$5555,d6
      move.w    d5,d7
      move.w    d5,d1
textp_it7:
      moveq.l   #0,d5
      movem.l   d1-d7/a0-a5,-(sp)
      moveq.l   #0,d0
      bsr       textblt
      movem.l   (sp)+,d1-d7/a0-a5
      ror.w     #1,d6
      bcc.s     textp_it8
      addq.w    #1,d2
textp_it8:
      subq.w    #1,d3
      subq.w    #1,d1
      dbf       d7,textp_it7
      movem.w   (sp)+,d5-d6
      bra.s     text_par17
textp_ro3:
      movem.l   d6/a3/a5,-(sp)
      bsr       rotate270
      movem.l   (sp)+,d6/a3/a5
      btst      #2,t_effects+1(a6)
      bne.s     textp_it9
      sub.w     d4,d2
      movem.l   d2-d6/a3/a5,-(sp)
      bsr       textblt_1
      movem.l   (sp)+,d2-d6/a3/a5
      subq.w    #1,d2
text_par19:
      moveq.l   #16,d1
      add.w     t_act_line(a6),d1
      move.w    d1,t_act_line(a6)
      move.w    t_cheight(a6),d5
      sub.w     d1,d5
      bgt       text_par1
      move.l    (sp)+,t_image(a6)
                  rts
textp_it9:
      movem.w   d5-d6,-(sp)
      tst.w     t_act_line(a6)
      bne.s     text_par20
      sub.w     t_left_off(a6),d3
      add.w     t_whole_off(a6),d3
text_par20:
      move.w    #$5555,d6
      move.w    d4,d0
      move.w    d4,d7
textp_it10:
      moveq.l   #0,d4
      movem.l   d0/d2-d7/a0-a5,-(sp)
      bsr       textblt_2
      movem.l   (sp)+,d0/d2-d7/a0-a5
      ror.w     #1,d6
      bcc.s     textp_it11
      subq.w    #1,d3
textp_it11:
      subq.w    #1,d2
      subq.w    #1,d0
      dbf       d7,textp_it10
      movem.w   (sp)+,d5-d6
      bra.s     text_par19
text:
      move.w    n_intin(a1),d6
      ble.s     text_exi
      subq.w    #1,d6
      clr.l     t_act_line(a6)
      moveq.l   #0,d5
      move.w    t_effects(a6),d0
      btst      #0,d0
      beq.s     text_eff
      move.w    t_thicken(a6),d5
text_eff:
      btst      #4,d0
      beq.s     text_thi
      addq.w    #2,d5
text_thi:
      move.w    d5,t_eff_theight(a6)
      movea.l   t_fonthdr(a6),a0
      move.l    76(a0),t_image(a6)
      movea.l   a2,a5
      movea.l   t_offtab(a6),a4
      tst.b     t_prop(a6)
      beq.s     text_mon
      movem.w   t_first_ade(a6),d0-d1
      moveq.l   #-1,d4
      move.w    d6,d7
text_wid1:
      move.w    (a2)+,d2
      sub.w     d0,d2
      cmp.w     d1,d2
      bls.s     text_wid2
      move.w    t_unknown_index(a6),d2
text_wid2:
      add.w     d2,d2
      move.w    2(a4,d2.w),d3
      sub.w     0(a4,d2.w),d3
      tst.b     t_grow(a6)
      beq.s     text_wid3
      mulu.w    t_cheight(a6),d3
      divu.w    t_iheight(a6),d3
text_wid3:
      add.w     d5,d3
      add.w     d3,d4
      dbf       d7,text_wid1
      tst.w     d4
      bpl.s     text_pos
text_exi:
                  rts
text_mon:
      move.w    t_cwidth(a6),d4
      add.w     d5,d4
      addq.w    #1,d6
      mulu.w    d6,d4
      subq.w    #1,d6
      subq.w    #1,d4
text_pos:
      move.w    (a3)+,d0
      move.w    (a3)+,d1
      move.w    t_ver(a6),d3
      add.w     d3,d3
      move.w    t_base(a6,d3.w),d3
      move.w    t_cheight(a6),d5
      subq.w    #1,d5
      btst      #4,t_effects+1(a6)
      beq.s     text_ali
      addq.w    #1,d3
      addq.w    #2,d5
text_ali:
      moveq.l   #0,d2
      move.w    t_hor(a6),d7
      beq.s     text_left
      subq.w    #1,d7
      bne.s     text_right
      move.w    d4,d2
      addq.w    #1,d2
      asr.w     #1,d2
      bra.s     text_left
text_right:
      move.w    d4,d2
text_left:
      move.w    t_rotation(a6),d7
      beq       text_cli2
      subq.w    #1,d7
      bne       text_cli1
      tst.w     t_add_len(a6)
      beq.s     text_cl90_1
      btst      #2,t_effects+1(a6)
      beq.s     text_cl90_1
      sub.w     t_left_off(a6),d1
text_cl90_1:
      sub.w     d3,d0
      add.w     d2,d1
      move.w    d0,d2
      move.w    d1,d3
      add.w     d5,d2
      sub.w     d4,d1
      cmp.w     clip_xmax(a6),d0
      bgt.s     text_exi
      cmp.w     clip_xmin(a6),d2
      blt.s     text_exi
      cmp.w     clip_ymax(a6),d1
      ble.s     text_cl90_2
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d1,d7
      add.w     t_left_off(a6),d7
      sub.w     t_whole_off(a6),d7
      cmp.w     clip_ymax(a6),d7
      bgt       text_exi
text_cl90_2:
      cmp.w     clip_ymin(a6),d3
      bge.s     text_cl90_3
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d3,d7
      add.w     t_left_off(a6),d7
      cmp.w     clip_ymin(a6),d7
      blt       text_exi
text_cl90_3:
      cmp.w     clip_ymin(a6),d1
      bge       text_cl90_9
      movem.w   d0/d2-d5,-(sp)
      movem.w   t_first_ade(a6),d2-d3
      move.w    t_eff_theight(a6),d5
      move.w    d6,d7
      add.w     d7,d7
      lea.l     2(a5,d7.w),a2
      btst      #2,t_effects+1(a6)
      beq.s     text_cl90_4
      add.w     t_left_off(a6),d1
text_cl90_4:
      move.w    -(a2),d0
      sub.w     d2,d0
      cmp.w     d3,d0
      bls.s     text_cl90_5
      move.w    t_unknown_index(a6),d2
text_cl90_5:
      add.w     d0,d0
      move.w    2(a4,d0.w),d4
      sub.w     0(a4,d0.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      add.w     d4,d1
      cmp.w     clip_ymin(a6),d1
      bgt.s     text_cl90_8
      tst.w     d6
      beq.s     text_cl90_8
      move.w    t_add_len(a6),d7
      beq.s     text_cl90_7
      ext.l     d7
      move.w    t_space_(a6),d0
      bmi.s     text_cl90_6
      cmpi.w    #32,(a2)
      bne.s     text_cl90_7
      divs.w    d0,d7
      add.w     d7,d1
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl90_4
text_cl90_6:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      add.w     d7,d1
text_cl90_7:
      dbf       d6,text_cl90_4
text_cl90_8:
      sub.w     d4,d1
      movem.w   (sp)+,d0/d2-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl90_9
      sub.w     t_left_off(a6),d1
text_cl90_9:
      cmp.w     clip_ymax(a6),d3
      ble       text_cl270_15
      movem.w   d0-d2/d4-d5,-(sp)
      movem.w   t_first_ade(a6),d0-d1
      move.w    t_eff_theight(a6),d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl90_10
      add.w     t_left_off(a6),d3
      sub.w     t_whole_off(a6),d3
text_cl90_10:
      move.w    (a5)+,d2
      sub.w     d0,d2
      cmp.w     d1,d2
      bls.s     text_cl90_11
      move.w    t_unknown_index(a6),d2
text_cl90_11:
      add.w     d2,d2
      move.w    2(a4,d2.w),d4
      sub.w     0(a4,d2.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      sub.w     d4,d3
      cmp.w     clip_ymax(a6),d3
      blt.s     text_cl90_14
      tst.w     d6
      beq.s     text_cl90_14
      move.w    t_add_len(a6),d7
      beq.s     text_cl90_13
      ext.l     d7
      move.w    t_space_(a6),d2
      bmi.s     text_cl90_12
      cmpi.w    #32,-2(a5)
      bne.s     text_cl90_13
      divs.w    d2,d7
      sub.w     d7,d3
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl90_10
text_cl90_12:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      sub.w     d7,d3
text_cl90_13:
      dbf       d6,text_cl90_10
text_cl90_14:
      add.w     d4,d3
      subq.l    #2,a5
      movem.w   (sp)+,d0-d2/d4-d5
      btst      #2,t_effects+1(a6)
      beq       text_cl270_15
      sub.w     t_left_off(a6),d3
      add.w     t_whole_off(a6),d3
      bra       text_cl270_15
text_cli1:
      subq.w    #1,d7
      bne       text270
      tst.w     t_add_len(a6)
      beq.s     text_cl180_1
      btst      #2,t_effects+1(a6)
      beq.s     text_cl180_1
      sub.w     t_left_off(a6),d0
text_cl180_1:
      add.w     d2,d0
      add.w     d3,d1
      move.w    d0,d2
      move.w    d1,d3
      sub.w     d4,d0
      sub.w     d5,d1
      cmp.w     clip_ymax(a6),d1
      bgt       text_exi
      cmp.w     clip_ymin(a6),d3
      blt       text_exi
      cmp.w     clip_xmax(a6),d0
      ble.s     text_cl180_2
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d0,d7
      add.w     t_left_off(a6),d7
      sub.w     t_whole_off(a6),d7
      cmp.w     clip_xmax(a6),d7
      bgt       text_exi
text_cl180_2:
      cmp.w     clip_xmin(a6),d2
      bge.s     text_cl180_3
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d2,d7
      add.w     t_left_off(a6),d7
      cmp.w     clip_xmin(a6),d7
      blt       text_exi
text_cl180_3:
      cmp.w     clip_xmin(a6),d0
      bge       text_cl180_9
      movem.w   d1-d5,-(sp)
      movem.w   t_first_ade(a6),d2-d3
      move.w    t_eff_theight(a6),d5
      move.w    d6,d7
      add.w     d7,d7
      lea.l     2(a5,d7.w),a2
      btst      #2,t_effects+1(a6)
      beq.s     text_cl180_4
      add.w     t_left_off(a6),d0
text_cl180_4:
      move.w    -(a2),d1
      sub.w     d2,d1
      cmp.w     d3,d1
      bls.s     text_cl180_5
      move.w    t_unknown_index(a6),d1
text_cl180_5:
      add.w     d1,d1
      move.w    2(a4,d1.w),d4
      sub.w     0(a4,d1.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      add.w     d4,d0
      cmp.w     clip_xmin(a6),d0
      bgt.s     text_cl180_8
      tst.w     d6
      beq.s     text_cl180_8
      move.w    t_add_len(a6),d7
      beq.s     text_cl180_7
      ext.l     d7
      move.w    t_space_(a6),d1
      bmi.s     text_cl180_6
      cmpi.w    #32,(a2)
      bne.s     text_cl180_7
      divs.w    d1,d7
      add.w     d7,d0
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl180_4
text_cl180_6:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      add.w     d7,d0
text_cl180_7:
      dbf       d6,text_cl180_4
text_cl180_8:
      sub.w     d4,d0
      movem.w   (sp)+,d1-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl180_9
      sub.w     t_left_off(a6),d0
text_cl180_9:
      cmp.w     clip_xmax(a6),d2
      ble       text_cl0_14
      movem.w   d0-d1/d3-d5,-(sp)
      movem.w   t_first_ade(a6),d0-d1
      move.w    t_eff_theight(a6),d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl180_10
      add.w     t_left_off(a6),d2
      sub.w     t_whole_off(a6),d2
text_cl180_10:
      move.w    (a5)+,d3
      sub.w     d0,d3
      cmp.w     d1,d3
      bls.s     text_cl180_11
      move.w    t_unknown_index(a6),d3
text_cl180_11:
      add.w     d3,d3
      move.w    2(a4,d3.w),d4
      sub.w     0(a4,d3.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      sub.w     d4,d2
      cmp.w     clip_xmax(a6),d2
      blt.s     text_cl180_14
      tst.w     d6
      beq.s     text_cl180_14
      move.w    t_add_len(a6),d7
      beq.s     text_cl180_13
      ext.l     d7
      move.w    t_space_(a6),d3
      bmi.s     text_cl180_12
      cmpi.w    #32,-2(a5)
      bne.s     text_cl180_13
      divs.w    d3,d7
      sub.w     d7,d2
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl180_10
text_cl180_12:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      sub.w     d7,d2
text_cl180_13:
      dbf       d6,text_cl180_10
text_cl180_14:
      add.w     d4,d2
      subq.l    #2,a5
      movem.w   (sp)+,d0-d1/d3-d5
      btst      #2,t_effects+1(a6)
      beq       text_cl0_14
      sub.w     t_left_off(a6),d2
      add.w     t_whole_off(a6),d2
      bra       text_cl0_14
text270:
      tst.w     t_add_len(a6)
      beq.s     text_cl270_1
      btst      #2,t_effects+1(a6)
      beq.s     text_cl270_1
      add.w     t_left_off(a6),d1
text_cl270_1:
      add.w     d3,d0
      sub.w     d2,d1
      move.w    d0,d2
      move.w    d1,d3
      sub.w     d5,d0
      add.w     d4,d3
      cmp.w     clip_xmax(a6),d0
      bgt       text_exi
      cmp.w     clip_xmin(a6),d2
      blt       text_exi
      cmp.w     clip_ymax(a6),d1
      ble.s     text_cl270_2
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d1,d7
      sub.w     t_left_off(a6),d7
      cmp.w     clip_ymax(a6),d7
      bgt       text_exi
text_cl270_2:
      cmp.w     clip_ymin(a6),d3
      bge.s     text_cl270_3
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d3,d7
      sub.w     t_left_off(a6),d7
      add.w     t_whole_off(a6),d7
      cmp.w     clip_ymin(a6),d7
      blt       text_exi
text_cl270_3:
      cmp.w     clip_ymin(a6),d1
      bge       text_cl270_9
      movem.w   d0/d2-d5,-(sp)
      movem.w   t_first_ade(a6),d2-d3
      move.w    t_eff_theight(a6),d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl270_4
      sub.w     t_left_off(a6),d1
      add.w     t_whole_off(a6),d1
text_cl270_4:
      move.w    (a5)+,d0
      sub.w     d2,d0
      cmp.w     d3,d0
      bls.s     text_cl270_5
      move.w    t_unknown_index(a6),d0
text_cl270_5:
      add.w     d0,d0
      move.w    2(a4,d0.w),d4
      sub.w     0(a4,d0.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      add.w     d4,d1
      cmp.w     clip_ymin(a6),d1
      bgt.s     text_cl270_8
      tst.w     d6
      beq.s     text_cl270_8
      move.w    t_add_len(a6),d7
      beq.s     text_cl270_7
      ext.l     d7
      move.w    t_space_(a6),d0
      bmi.s     text_cl270_6
      cmpi.w    #32,-2(a5)
      bne.s     text_cl270_7
      divs.w    d0,d7
      add.w     d7,d1
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl270_4
text_cl270_6:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      add.w     d7,d1
text_cl270_7:
      dbf       d6,text_cl270_4
text_cl270_8:
      sub.w     d4,d1
      subq.l    #2,a5
      movem.w   (sp)+,d0/d2-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl270_9
      add.w     t_left_off(a6),d1
      sub.w     t_whole_off(a6),d1
text_cl270_9:
      cmp.w     clip_ymax(a6),d3
      ble       text_cl270_15
      movem.w   d0-d2/d4-d5,-(sp)
      movem.w   t_first_ade(a6),d0-d1
      move.w    t_eff_theight(a6),d5
      move.w    d6,d7
      add.w     d7,d7
      lea.l     2(a5,d7.w),a2
      btst      #2,t_effects+1(a6)
      beq.s     text_cl270_10
      sub.w     t_left_off(a6),d3
text_cl270_10:
      move.w    -(a2),d2
      sub.w     d0,d2
      cmp.w     d1,d2
      bls.s     text_cl270_11
      move.w    t_unknown_index(a6),d2
text_cl270_11:
      add.w     d2,d2
      move.w    2(a4,d2.w),d4
      sub.w     0(a4,d2.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      sub.w     d4,d3
      cmp.w     clip_ymax(a6),d3
      blt.s     text_cl270_14
      tst.w     d6
      beq.s     text_cl270_14
      move.w    t_add_len(a6),d7
      beq.s     text_cl270_13
      ext.l     d7
      move.w    t_space_(a6),d2
      bmi.s     text_cl270_12
      cmpi.w    #32,(a2)
      bne.s     text_cl270_13
      divs.w    d2,d7
      sub.w     d7,d3
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl270_10
text_cl270_12:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      sub.w     d7,d3
text_cl270_13:
      dbf       d6,text_cl270_10
text_cl270_14:
      add.w     d4,d3
      movem.w   (sp)+,d0-d2/d4-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl270_15
      add.w     t_left_off(a6),d3
text_cl270_15:
      move.w    d3,d4
      sub.w     d1,d4
      bra       text_buf1
text_cli2:
      tst.w     t_add_len(a6)
      beq.s     text_cl0_1
      btst      #2,t_effects+1(a6)
      beq.s     text_cl0_1
      add.w     t_left_off(a6),d0
text_cl0_1:
      sub.w     d2,d0
      sub.w     d3,d1
      move.w    d0,d2
      move.w    d1,d3
      add.w     d4,d2
      add.w     d5,d3
      cmp.w     clip_ymax(a6),d1
      bgt       text_exi
      cmp.w     clip_ymin(a6),d3
      blt       text_exi
      cmp.w     clip_xmax(a6),d0
      ble.s     text_cli3
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d0,d7
      sub.w     t_left_off(a6),d7
      cmp.w     clip_xmax(a6),d7
      bgt       text_exi
text_cli3:
      cmp.w     clip_xmin(a6),d2
      bge.s     text_cl0_2
      btst      #2,t_effects+1(a6)
      beq       text_exi
      move.w    d2,d7
      sub.w     t_left_off(a6),d7
      add.w     t_whole_off(a6),d7
      cmp.w     clip_xmin(a6),d7
      blt       text_exi
text_cl0_2:
      cmp.w     clip_xmin(a6),d0
      bge       text_cl0_8
      movem.w   d1-d5,-(sp)
      movem.w   t_first_ade(a6),d2-d3
      move.w    t_eff_theight(a6),d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl0_3
      sub.w     t_left_off(a6),d0
      add.w     t_whole_off(a6),d0
text_cl0_3:
      move.w    (a5)+,d1
      sub.w     d2,d1
      cmp.w     d3,d1
      bls.s     text_cl0_4
      move.w    t_unknown_index(a6),d1
text_cl0_4:
      add.w     d1,d1
      move.w    2(a4,d1.w),d4
      sub.w     0(a4,d1.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      add.w     d4,d0
      cmp.w     clip_xmin(a6),d0
      bgt.s     text_cl0_7
      tst.w     d6
      beq.s     text_cl0_7
      move.w    t_add_len(a6),d7
      beq.s     text_cl0_6
      ext.l     d7
      move.w    t_space_(a6),d1
      bmi.s     text_cl0_5
      cmpi.w    #32,-2(a5)
      bne.s     text_cl0_6
      divs.w    d1,d7
      add.w     d7,d0
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl0_3
text_cl0_5:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      add.w     d7,d0
text_cl0_6:
      dbf       d6,text_cl0_3
text_cl0_7:
      sub.w     d4,d0
      subq.l    #2,a5
      movem.w   (sp)+,d1-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl0_8
      add.w     t_left_off(a6),d0
      sub.w     t_whole_off(a6),d0
text_cl0_8:
      cmp.w     clip_xmax(a6),d2
      ble       text_cl0_14
      movem.w   d0-d1/d3-d5,-(sp)
      move.w    d6,d7
      add.w     d7,d7
      lea.l     2(a5,d7.w),a2
      movem.w   t_first_ade(a6),d0-d1
      move.w    t_eff_theight(a6),d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl0_9
      sub.w     t_left_off(a6),d2
text_cl0_9:
      move.w    -(a2),d3
      sub.w     d0,d3
      cmp.w     d1,d3
      bls.s     text_cl0_10
      move.w    t_unknown_index(a6),d3
text_cl0_10:
      add.w     d3,d3
      move.w    2(a4,d3.w),d4
      sub.w     0(a4,d3.w),d4
      mulu.w    t_cheight(a6),d4
      divu.w    t_iheight(a6),d4
      add.w     d5,d4
      sub.w     d4,d2
      cmp.w     clip_xmax(a6),d2
      blt.s     text_cl0_13
      tst.w     d6
      beq.s     text_cl0_13
      move.w    t_add_len(a6),d7
      beq.s     text_cl0_12
      ext.l     d7
      move.w    t_space_(a6),d3
      bmi.s     text_cl0_11
      cmpi.w    #32,(a2)
      bne.s     text_cl0_12
      divs.w    d3,d7
      sub.w     d7,d2
      sub.w     d7,t_add_len(a6)
      subq.w    #1,t_space_(a6)
      dbf       d6,text_cl0_9
text_cl0_11:
      divs.w    d6,d7
      sub.w     d7,t_add_len(a6)
      sub.w     d7,d2
text_cl0_12:
      dbf       d6,text_cl0_9
text_cl0_13:
      add.w     d4,d2
      movem.w   (sp)+,d0-d1/d3-d5
      btst      #2,t_effects+1(a6)
      beq.s     text_cl0_14
      add.w     t_left_off(a6),d2
text_cl0_14:
      move.w    d2,d4
      sub.w     d0,d4
text_buf1:
      addi.w    #16,d4
      lsr.w     #4,d4
      add.w     d4,d4
      movea.w   d4,a3
      move.w    d5,d7
      addq.w    #1,d7
      tst.w     t_rotation(a6)
      beq.s     text_buf2
      addi.w    #15,d7
      andi.w    #$FFF0,d7
text_buf2:
      mulu.w    d4,d7
      move.l    buffer_len(a6),d4
      btst      #4,t_effects+1(a6)
      bne.s     text_buf3
      tst.w     t_rotation(a6)
      beq.s     text_buf4
text_buf3:
      lsr.l     #1,d4
text_buf4:
      cmp.l     d4,d7
      bgt       text_par
      movem.w   d0-d1,-(sp)
      move.w    t_cheight(a6),d5
      subq.w    #1,d5
      bsr       fill_tex
      movea.l   buffer_addr(a6),a0
      movea.w   a3,a2
      move.w    t_effects(a6),d7
      beq.s     text_out2
text_bol:
      btst      #0,d7
      beq.s     text_und
      bsr       bold
text_und:
      btst      #3,t_effects+1(a6)
      beq.s     text_out1
      bsr       underlin1
text_out1:
      btst      #4,t_effects+1(a6)
      beq.s     text_lig
      bsr       outline
text_lig:
      btst      #1,t_effects+1(a6)
      beq.s     text_out2
      bsr       light
text_out2:
      movem.w   (sp)+,d2-d3
      move.w    t_rotation(a6),d7
      bne.s     text_rot2
text_rot1:
      btst      #2,t_effects+1(a6)
      beq       textblt_1
text_ita1:
      sub.w     t_left_off(a6),d2
      add.w     t_whole_off(a6),d2
text_ita2:
      move.w    #$5555,d6
      moveq.l   #0,d1
      move.w    d5,d7
text_ita3:
      movem.w   d1-d4/d6-d7/a2-a3,-(sp)
      move.l    a0,-(sp)
      moveq.l   #0,d0
      moveq.l   #0,d5
      bsr       textblt
      movea.l   (sp)+,a0
      movem.w   (sp)+,d1-d4/d6-d7/a2-a3
      ror.w     #1,d6
      bcc.s     text_ita4
      subq.w    #1,d2
text_ita4:
      addq.w    #1,d1
      addq.w    #1,d3
      dbf       d7,text_ita3
                  rts
text_rot2:
      subq.w    #1,d7
      bne.s     text_rot3
      bsr       rotate90
      btst      #2,t_effects+1(a6)
      beq       textblt_1
text_ita5:
      add.w     t_left_off(a6),d3
      sub.w     t_whole_off(a6),d3
text_ita6:
      move.w    #$5555,d6
      move.w    d4,d7
text_ita7:
      movem.w   d0/d2-d3/d5-d7/a2-a3,-(sp)
      move.l    a0,-(sp)
      moveq.l   #0,d1
      moveq.l   #0,d4
      bsr       textblt
      movea.l   (sp)+,a0
      movem.w   (sp)+,d0/d2-d3/d5-d7/a2-a3
      ror.w     #1,d6
      bcc.s     text_ita8
      addq.w    #1,d3
text_ita8:
      addq.w    #1,d0
      addq.w    #1,d2
      dbf       d7,text_ita7
                  rts
text_rot3:
      subq.w    #1,d7
      bne.s     text_rot4
      bsr       rotate180
      btst      #2,t_effects+1(a6)
      beq       textblt_1
      add.w     t_left_off(a6),d2
      bra       text_ita2
text_rot4:
      bsr       rotate270
      btst      #2,t_effects+1(a6)
      beq       textblt_1
      sub.w     t_left_off(a6),d3
      bra.s     text_ita6
underlin1:
      move.w    t_act_line(a6),d0
      move.w    d0,d1
      add.w     d5,d1
      move.w    t_uline(a6),d2
      move.w    t_base(a6),d3
      addq.w    #2,d3
      move.w    t_cheight(a6),d7
      subq.w    #1,d7
      cmp.w     d7,d3
      ble.s     underlin2
      move.w    d7,d3
underlin2:
      add.w     d3,d2
      cmp.w     d7,d2
      ble.s     underlin3
      move.w    d7,d2
underlin3:
      cmp.w     d1,d3
      bgt.s     underlin8
      cmp.w     d0,d2
      blt.s     underlin8
      cmp.w     d1,d2
      ble.s     underlin4
      move.w    d1,d2
underlin4:
      cmp.w     d0,d3
      bge.s     underlin5
      move.w    d0,d3
underlin5:
      sub.w     d3,d2
      bmi.s     underlin8
      sub.w     d0,d3
      move.w    a2,d0
      mulu.w    d3,d0
      movea.l   a0,a1
      adda.w    d0,a1
      move.w    d4,d0
      lsr.w     #4,d0
      moveq.l   #-1,d1
      moveq.l   #15,d3
      and.w     d4,d3
      add.w     d3,d3
      move.w    underlin_tab(pc,d3.w),d3
      movea.w   a2,a3
      suba.w    d0,a3
      suba.w    d0,a3
      subq.w    #2,a3
underlin6:
      move.w    d0,d6
underlin7:
      move.w    d1,(a1)+
      dbf       d6,underlin7
      and.w     d3,-2(a1)
      adda.w    a3,a1
      dbf       d2,underlin6
underlin8:
                  rts
underlin_tab:
      dc.w  $8000,$C000,$E000,$F000
      dc.w  $F800,$FC00,$FE00,$FF00
      dc.w  $FF80,$FFC0,$FFE0,$FFF0
      dc.w  $FFF8,$FFFC,$FFFE,$FFFF

bold:
      move.w   d5,-(sp)
      movea.l  a0,a4
      move.w   a2,d6
      lsr.w     #1,d6
      subq.w    #1,d6
      move.w    t_thicken(a6),d2
      beq.s     bold_loo
      add.w     d2,d4
      subq.w    #1,d2
bold_loo:
      move.w    d6,d7
      move.w    (a4)+,d0
bold_fet:
      swap      d0
      clr.w     d0
      move.l    d0,d1
      move.w    d2,d3
bold_thi:
      ror.l     #1,d0
      or.l      d0,d1
      dbf       d3,bold_thi
      move.w    (a4)+,d0
      or.l      d1,-4(a4)
      dbf       d7,bold_fet
      move.w    d0,-(a4)
      dbf       d5,bold_loo
      move.w    (sp)+,d5
                  rts
outline:
      movea.l   a0,a1
      move.l    buffer_len(a6),d0
      lsr.l     #1,d0
      adda.l    d0,a1
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      move.w    a2,d2
      lsr.w     #1,d2
      subq.w    #1,d2
      moveq.l   #16,d0
      addq.w    #2,d4
      add.w     d4,d0
      lsr.w     #4,d0
      add.w     d0,d0
      movea.w   d0,a2
      movea.w   d0,a3
      adda.w    d0,a3
      move.w    d5,d1
      addq.w    #3,d1
      mulu.w    d1,d0
      lsr.w     #2,d0
      moveq.l   #0,d1
      movea.l   a1,a4
outlined1:
      move.l    d1,(a4)+
      dbf       d0,outlined1
      move.w    d5,d6
outlined2:
      move.w    d2,d3
      movea.l   a1,a4
outlined3:
      moveq.l   #0,d0
      move.w    (a0)+,d0
      swap      d0
      move.l    d0,d1
      ror.l     #1,d1
      or.l      d1,d0
      ror.l     #1,d1
      or.l      d1,d0
      or.l      d0,(a4)
      or.l      d0,0(a4,a2.w)
      or.l      d0,0(a4,a3.w)
      addq.l    #2,a4
      dbf       d3,outlined3
      adda.w    a2,a1
      dbf       d6,outlined2
      movea.l   (sp),a1
      movea.l   4(sp),a0
      move.w    d5,d6
      adda.w    a2,a1
outlined4:
      move.w    d2,d3
      movea.l   a1,a4
outlined5:
      moveq.l   #0,d0
      move.w    (a0)+,d0
      swap      d0
      ror.l     #1,d0
      eor.l     d0,(a4)
      addq.l    #2,a4
      dbf       d3,outlined5
      adda.w    a2,a1
      dbf       d6,outlined4
      movea.l   (sp)+,a0
      movea.l   (sp)+,a1
      addq.w    #2,d5
                  rts
light:
      move.w    #$5555,d0
      moveq.l   #15,d6
      and.w     t_act_line(a6),d6
      ror.w     d6,d0
      movea.l   a0,a3
      move.w    a2,d1
      lsr.w     #1,d1
      subq.w    #1,d1
      move.w    d5,d7
      btst      #2,t_effects+1(a6)
      bne.s     light_it
light_lo1:
      move.w    d1,d6
light_lo2:
      and.w     d0,(a3)+
      dbf       d6,light_lo2
      ror.w     #1,d0
      dbf       d7,light_lo1
                  rts
light_it:
      move.w    #$5555,d2
      ror.w     d6,d2
light_i_1:
      move.w    d1,d6
light_i_2:
      and.w     d0,(a3)+
      dbf       d6,light_i_2
      ror.w     #1,d0
      ror.w     #1,d2
      bcc.s     light_i_3
      ror.w     #1,d0
light_i_3:
      dbf       d7,light_i_1
                  rts
rotate90:
      movea.l   a0,a1
      move.l    buffer_len(a6),d0
      lsr.l     #1,d0
      adda.l    d0,a1
      cmpa.l    buffer_addr(a6),a0
      beq.s     rotate90_1
      movea.l   buffer_addr(a6),a1
rotate90_1:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      movem.w   d2-d3/d5,-(sp)
      moveq.l   #16,d6
      move.w    d5,d0
      add.w     d6,d0
      andi.w    #$FFF0,d0
      move.w    d0,d7
      add.w     d7,d7
      lsr.w     #3,d0
      movea.w   d0,a3
      movea.l   a1,a4
      mulu.w    d4,d0
      adda.w    d0,a1
      add.w     a3,d0
      lsr.w     #4,d0
      moveq.l   #0,d1
rotate90_2:
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      dbf       d0,rotate90_2
      move.w    #$8000,d2
rotate90_3:
      move.w    d4,d3
      movea.l   a0,a4
      movea.l   a1,a5
      adda.w    a2,a0
      bra.s     rotate90_5
rotate90_4:
      dbf       d1,rotate90_6
rotate90_5:
      moveq.l   #15,d1
      move.w    (a4)+,d0
      bne.s     rotate90_6
      sub.w     d6,d3
      bmi.s     rotate90_8
      move.w    (a4)+,d0
      suba.w    d7,a5
rotate90_6:
      add.w     d0,d0
      bcc.s     rotate90_7
      or.w      d2,(a5)
rotate90_7:
      suba.w    a3,a5
      dbf       d3,rotate90_4
rotate90_8:
      ror.w     #1,d2
      bcc.s     rotate90_9
      addq.l    #2,a1
rotate90_9:
      dbf       d5,rotate90_3
      movem.w   (sp)+,d2-d3/d5
      movea.l   (sp)+,a0
      movea.l   (sp)+,a1
      exg       d4,d5
      movea.w   a3,a2
                  rts
rotate180:
      movea.l   a0,a1
      move.l    buffer_len(a6),d0
      lsr.l     #1,d0
      adda.l    d0,a1
      cmpa.l    buffer_addr(a6),a0
      beq.s     rotate180_1
      movea.l   buffer_addr(a6),a1
rotate180_1:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      movem.w   d2-d3/d5,-(sp)
      moveq.l   #16,d6
      movea.l   a1,a4
      move.w    a2,d0
      mulu.w    d5,d0
      add.w     a2,d0
      adda.w    d0,a1
      lsr.w     #4,d0
      moveq.l   #0,d1
rotate180_2:
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      dbf       d0,rotate180_2
      moveq.l   #15,d0
      and.w     d4,d0
      move.w    #$8000,d2
      lsr.w     d0,d2
      movea.w   d2,a4
rotate180_3:
      move.w    a4,d2
      move.w    d4,d3
      moveq.l   #0,d7
      bra.s     rotate180_5
rotate180_4:
      dbf       d1,rotate180_6
rotate180_5:
      moveq.l   #15,d1
      move.w    (a0)+,d0
      bne.s     rotate180_6
      move.w    d7,-(a1)
      sub.w     d6,d3
      bmi.s     rotate180_9
      move.w    (a0)+,d0
      moveq.l   #0,d7
rotate180_6:
      add.w     d0,d0
      bcc.s     rotate180_7
      or.w      d2,d7
rotate180_7:
      add.w     d2,d2
      bcc.s     rotate180_8
      moveq.l   #1,d2
      move.w    d7,-(a1)
      moveq.l   #0,d7
rotate180_8:
      dbf       d3,rotate180_4
rotate180_9:
      dbf       d5,rotate180_3
      movem.w   (sp)+,d2-d3/d5
      movea.l   (sp)+,a0
      movea.l   (sp)+,a1
                  rts
rotate270:
      movea.l   a0,a1
      move.l    buffer_len(a6),d0
      lsr.l     #1,d0
      adda.l    d0,a1
      cmpa.l    buffer_addr(a6),a0
      beq.s     rotate270_1
      movea.l   buffer_addr(a6),a1
rotate270_1:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      movem.w   d2-d3/d5,-(sp)
      moveq.l   #16,d6
      move.w    d5,d0
      add.w     d6,d0
      andi.w    #$FFF0,d0
      move.w    d0,d7
      add.w     d7,d7
      lsr.w     #3,d0
      movea.w   d0,a3
      movea.l   a1,a4
      mulu.w    d4,d0
      add.w     a3,d0
      lsr.w     #4,d0
      moveq.l   #0,d1
rotate270_2:
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      move.l    d1,(a4)+
      dbf       d0,rotate270_2
      move.w    #$8000,d2
      move.w    a2,d0
      mulu.w    d5,d0
      adda.w    d0,a0
rotate270_3:
      move.w    d4,d3
      movea.l   a0,a4
      movea.l   a1,a5
      bra.s     rotate270_5
rotate270_4:
      dbf       d1,rotate270_6
rotate270_5:
      moveq.l   #15,d1
      move.w    (a4)+,d0
      bne.s     rotate270_6
      sub.w     d6,d3
      bmi.s     rotate270_8
      move.w    (a4)+,d0
      adda.w    d7,a5
rotate270_6:
      add.w     d0,d0
      bcc.s     rotate270_7
      or.w      d2,(a5)
rotate270_7:
      adda.w    a3,a5
      dbf       d3,rotate270_4
rotate270_8:
      suba.w    a2,a0
      ror.w     #1,d2
      bcc.s     rotate270_9
      addq.l    #2,a1
rotate270_9:
      dbf       d5,rotate270_3
      movem.w   (sp)+,d2-d3/d5
      movea.l   (sp)+,a0
      movea.l   (sp)+,a1
      exg       d4,d5
      movea.w   a3,a2
                  rts
textblt_1:
      moveq.l   #0,d0
textblt_2:
      moveq.l   #0,d1
textblt:
      move.w    d5,d7
      add.w     d2,d4
      add.w     d3,d5
      lea.l     clip_xmin(a6),a1
      cmp.w     (a1)+,d2
      bge.s     textblt_3
      sub.w     d2,d0
      move.w    -2(a1),d2
      add.w     d2,d0
textblt_3:
      cmp.w     (a1)+,d3
      bge.s     textblt_4
      sub.w     d3,d1
      move.w    -2(a1),d3
      add.w     d3,d1
textblt_4:
      cmp.w     (a1)+,d4
      ble.s     textblt_5
      move.w    -2(a1),d4
textblt_5:
      cmp.w     (a1),d5
      ble.s     textblt_6
      move.w    (a1),d5
textblt_6:
      sub.w     d2,d4
      bmi.s     textblt_7
      sub.w     d3,d5
      bmi.s     textblt_7
      movea.l   p_textblit(a6),a4
      jmp       (a4)
textblt_7:
                  rts
fill_tex:
      movea.w   t_iwidth(a6),a2
      movea.l   t_offtab(a6),a4
ftb_eff:
      move.w    a3,d0
      mulu.w    d5,d0
      add.w     a3,d0
      lsr.w     #4,d0
      moveq.l   #0,d1
      movea.l   buffer_addr(a6),a1
ftb_clea:
      move.l    d1,(a1)+
      move.l    d1,(a1)+
      move.l    d1,(a1)+
      move.l    d1,(a1)+
      dbf       d0,ftb_clea
      movea.l   buffer_addr(a6),a1
      moveq.l   #0,d2
      moveq.l   #15,d7
      move.w    t_eff_theight(a6),d3
      addq.w    #1,d3
      tst.b     t_grow(a6)
      bne       ftb_grow1
ftb_loop:
      move.w    (a5)+,d0
      sub.w     t_first_ade(a6),d0
      cmp.w     t_ades(a6),d0
      bls.s     ftb_posi
      move.w    t_unknown_index(a6),d0
ftb_posi:
      add.w     d0,d0
      movem.w   0(a4,d0.w),d0/d4
      sub.w     d0,d4
      subq.w    #1,d4
      bmi.s     ftb_next
      movea.l   t_image(a6),a0
      move.w    d0,d1
      lsr.w     #4,d1
      add.w     d1,d1
      adda.w    d1,a0
      and.w     d7,d0
      movem.w   d3/d5-d6/a2-a3,-(sp)
      add.w     d2,d3
      add.w     d4,d3
      move.w    d3,-(sp)
      move.l    a1,-(sp)
      bsr.s     copy_to_
      movea.l   (sp)+,a1
      movem.w   (sp)+,d2-d3/d5-d6/a2-a3
      tst.w     t_add_len(a6)
      beq.s     ftb_no_o
      bsr.s     text_off
ftb_no_o:
      cmp.w     d7,d2
      ble.s     ftb_next
      move.w    d2,d4
      lsr.w     #4,d4
      add.w     d4,d4
      adda.w    d4,a1
      and.w     d7,d2
ftb_next:
      dbf       d6,ftb_loop
      move.l    a1,d4
      sub.l     buffer_addr(a6),d4
      lsl.w     #3,d4
      add.w     d2,d4
      sub.w     d3,d4
                  rts
text_off:
      move.w    d6,d0
      beq.s     text_off2
      move.w    t_space_(a6),d4
      bmi.s     text_off1
      cmpi.w    #32,-2(a5)
      bne.s     text_off2
      subq.w    #1,t_space_(a6)
      move.w    d4,d0
text_off1:
      move.w    t_add_len(a6),d4
      ext.l     d4
      divs.w    d0,d4
      sub.w     d4,t_add_len(a6)
      add.w     d4,d2
      bpl.s     text_off2
      move.w    d2,d4
      neg.w     d4
      lsr.w     #4,d4
      addq.w    #1,d4
      add.w     d4,d4
      suba.w    d4,a1
      and.w     d7,d2
      cmpa.l    buffer_addr(a6),a1
      bpl.s     text_off2
      movea.l   buffer_addr(a6),a1
      moveq.l   #0,d2
text_off2:
                  rts
copy_to_:
      cmp.w     #7,d4
      bne.s     cptb_no_
      tst.w     d0
      beq       cptb_byt2
      cmp.w     #8,d0
      beq       cptb_byt1
cptb_no_:
      sub.w     d2,d0
      move.w    d2,d1
      add.w     d4,d1
      lsr.w     #4,d1
      add.w     d2,d4
      not.w     d4
      and.w     d7,d4
      moveq.l   #-1,d3
      lsr.w     d2,d3
      moveq.l   #-1,d2
      lsl.w     d4,d2
      subq.w    #1,d1
      bmi       cptb_1wo
      beq       cptb_1lo
      move.w    d1,d4
      addq.w    #1,d4
      add.w     d4,d4
      suba.w    d4,a2
      suba.w    d4,a3
      subq.w    #1,d1
      tst.w     d0
      beq.s     cptb_mul1
      blt.s     cptbm_r
      cmpi.w    #8,d0
      ble.s     cptb_mul3
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_mul2
cptbm_r:
      neg.w     d0
      subq.l    #2,a0
      cmpi.w    #8,d0
      ble.s     cptb_mul2
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_mul3
cptb_mul1:
      move.w    d1,d4
      move.w    (a0)+,d6
      and.w     d3,d6
      or.w      d6,(a1)+
cptbm_lo1:
      move.w    (a0)+,(a1)+
      dbf       d4,cptbm_lo1
      move.w    (a0),d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_mul1
                  rts
cptb_mul2:
      move.w    d1,d4
      move.l    (a0),d6
      addq.l    #2,a0
      ror.l     d0,d6
      and.w     d3,d6
      or.w      d6,(a1)+
cptbm_lo2:
      move.l    (a0),d6
      addq.l    #2,a0
      ror.l     d0,d6
      move.w    d6,(a1)+
      dbf       d4,cptbm_lo2
      move.l    (a0),d6
      ror.l     d0,d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_mul2
                  rts
cptb_mul3:
      move.w    d1,d4
      move.l    (a0),d6
      addq.l    #2,a0
      swap      d6
      rol.l     d0,d6
      and.w     d3,d6
      or.w      d6,(a1)+
cptbm_lo3:
      move.l    (a0),d6
      addq.l    #2,a0
      swap      d6
      rol.l     d0,d6
      move.w    d6,(a1)+
      dbf       d4,cptbm_lo3
      move.l    (a0),d6
      swap      d6
      rol.l     d0,d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_mul3
                  rts
cptb_1wo:
      and.w     d3,d2
      move.w    d2,d3
      not.w     d3
      tst.w     d0
      beq.s     cptb_wor1
      blt.s     cptb_wr
      cmpi.w    #8,d0
      ble.s     cptb_wor3
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_wor2
cptb_wr:
      neg.w     d0
      subq.l    #2,a0
      cmpi.w    #8,d0
      ble.s     cptb_wor2
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_wor3
cptb_wor1:
      move.w    (a0),d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_wor1
                  rts
cptb_wor2:
      move.l    (a0),d6
      ror.l     d0,d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_wor2
                  rts
cptb_wor3:
      move.l    (a0),d6
      swap      d6
      rol.l     d0,d6
      and.w     d2,d6
      or.w      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_wor3
                  rts
cptb_1lo:
      swap      d3
      move.w    d2,d3
      move.l    d3,d2
      not.l     d3
      tst.w     d0
      beq.s     cptb_lon1
      blt.s     cptb_lr
      cmpi.w    #8,d0
      ble.s     cptb_lon3
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_lon2
cptb_lr:
      neg.w     d0
      subq.l    #2,a0
      cmpi.w    #8,d0
      ble.s     cptb_lon2
      subq.w    #1,d0
      eor.w     d7,d0
      bra.s     cptb_lon3
cptb_lon1:
      move.l    (a0),d6
      and.l     d2,d6
      or.l      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_lon1
                  rts
cptb_lon2:
      move.l    (a0),d6
      ror.l     d0,d6
      swap      d6
      move.l    2(a0),d4
      ror.l     d0,d4
      move.w    d4,d6
      and.l     d2,d6
      or.l      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_lon2
                  rts
cptb_lon3:
      move.l    (a0),d6
      rol.l     d0,d6
      move.l    2(a0),d4
      swap      d4
      rol.l     d0,d4
      move.w    d4,d6
      and.l     d2,d6
      or.l      d6,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_lon3
                  rts
cptb_byt1:
      addq.l    #1,a0
cptb_byt2:
      not.w     d2
      and.w     d7,d2
      addq.w    #1,d2
cptb_byt3:
      moveq.l   #0,d0
      movep.w   0(a0),d0
      clr.b     d0
      lsl.l     d2,d0
      or.l      d0,(a1)
      adda.w    a2,a0
      adda.w    a3,a1
      dbf       d5,cptb_byt3
                  rts
ftb_grow1:
      move.w    (a5)+,d0
      sub.w     t_first_ade(a6),d0
      cmp.w     t_ades(a6),d0
      bls.s     ftb_grow2
      move.w    t_unknown_index(a6),d0
ftb_grow2:
      add.w     d0,d0
      movem.w   0(a4,d0.w),d0/d4
      sub.w     d0,d4
      subq.w    #1,d4
      bmi.s     ftb_grow3
      movea.l   t_image(a6),a0
      move.w    d0,d1
      lsr.w     #4,d1
      add.w     d1,d1
      adda.w    d1,a0
      and.w     d7,d0
      movem.w   d2-d3/d5-d6/a2-a3,-(sp)
      movem.l   a1/a4-a6,-(sp)
      pea.l     ftb_retu(pc)
      tst.b     t_grow(a6)
      bmi       grow_cha3
      bra       shrink_c1
ftb_retu:
      movem.l   (sp)+,a1/a4-a6
      movem.w   (sp)+,d2-d3/d5-d6/a2-a3
      add.w     d3,d2
      add.w     d4,d2
      tst.w     t_add_len(a6)
      beq.s     ftbg_no_
      bsr       text_off
ftbg_no_:
      cmp.w     d7,d2
      ble.s     ftb_grow3
      move.w    d2,d4
      lsr.w     #4,d4
      add.w     d4,d4
      adda.w    d4,a1
      and.w     d7,d2
ftb_grow3:
      dbf       d6,ftb_grow1
      move.l    a1,d4
      sub.l     buffer_addr(a6),d4
      lsl.w     #3,d4
      add.w     d2,d4
      sub.w     d3,d4
                  rts
grow_byt1:
      addq.l    #1,a0
grow_byt2:
      moveq.l   #15,d4
grow_byt3:
      moveq.l   #0,d1
      move.b    (a0),d0
      adda.w    a2,a0
      beq.s     grow_byt6
      moveq.l   #7,d3
grow_byt4:
      add.w     d1,d1
      add.w     d1,d1
      add.b     d0,d0
      bcc.s     grow_byt5
      addq.w    #3,d1
grow_byt5:
      dbf       d3,grow_byt4
      move.w    d1,(a1)
      adda.w    a3,a1
      move.w    d1,(a1)
      adda.w    a3,a1
      dbf       d5,grow_byt3
                  rts
grow_byt6:
      adda.w    a3,a1
      adda.w    a3,a1
      dbf       d5,grow_byt3
                  rts
grow_cha1:
      lsr.w     #1,d5
      cmp.w     #7,d4
      bne.s     grow_cha2
      tst.w     d2
      bne.s     grow_cha2
      tst.w     d0
      beq.s     grow_byt2
      cmp.w     #8,d0
      beq.s     grow_byt1
grow_cha2:
      move.w    d2,d3
      move.w    d0,d2
      eor.w     d7,d2
      subq.w    #7,d2
      bgt.s     grow_db_1
      addq.l    #1,a0
      addq.w    #8,d2
grow_db_1:
      movea.l   a0,a4
      movea.l   a1,a5
      move.w    d4,d7
grow_db_2:
      moveq.l   #7,d6
      cmp.w     d6,d7
      bge.s     grow_db_3
      move.w    d7,d6
grow_db_3:
      subq.w    #8,d7
      moveq.l   #0,d1
      movep.w   0(a4),d0
      addq.l    #1,a4
      move.b    (a4),d0
      lsr.w     d2,d0
grow_db_4:
      add.w     d1,d1
      add.w     d1,d1
      add.b     d0,d0
      bcc.s     grow_db_5
      addq.w    #3,d1
grow_db_5:
      dbf       d6,grow_db_4
      tst.w     d7
      bpl.s     grow_db_6
      move.w    d7,d6
      addq.w    #1,d6
      neg.w     d6
      add.w     d6,d6
      lsl.w     d6,d1
grow_db_6:
      ror.l     d3,d1
      swap      d1
      or.l      d1,(a5)
      or.l      d1,0(a5,a3.w)
      addq.l    #2,a5
      tst.w     d7
      bpl.s     grow_db_2
      adda.w    a2,a0
      adda.w    a3,a1
      adda.w    a3,a1
      dbf       d5,grow_db_1
      add.w     d4,d4
      addq.w    #1,d4
      moveq.l   #15,d7
                  rts
grow_cha3:
      move.w    t_iheight(a6),d1
      add.w     d1,d1
      move.w    t_cheight(a6),d6
      cmp.w     d6,d1
      beq       grow_cha1
      move.w    d5,-(sp)
      swap      d2
      move.w    d0,d2
      move.w    t_iheight(a6),d5
      addq.w    #1,d4
      mulu.w    d6,d4
      divu.w    d5,d4
      subq.w    #1,d4
      moveq.l   #16,d1
      add.w     d4,d1
      swap      d2
      add.w     d2,d1
      swap      d2
      lsr.w     #4,d1
      subq.w    #1,d1
      swap      d1
      moveq.l   #-1,d7
      swap      d2
      lsr.w     d2,d7
      swap      d2
      move.w    d7,d1
      movea.w   d5,a4
      sub.w     d6,d5
      movea.w   d5,a5
      move.w    d5,d3
      swap      d3
      move.w    d5,d3
      move.w    (sp)+,d5
pte_grow1:
      bsr.s     grow_lin
      adda.w    a2,a0
      swap      d3
      tst.w     d3
      bmi.s     grow_hei
pte_grow2:
      add.w     a5,d3
      swap      d3
      adda.w    a3,a1
      dbf       d5,pte_grow1
      bra.s     pte_grow3
grow_loo1:
      tst.w     d3
      bpl.s     pte_grow2
grow_hei:
      move.l    d1,d7
      swap      d7
      movea.l   a1,a6
      adda.w    a3,a6
      move.l    a6,-(sp)
      move.w    (a1)+,d6
      and.w     d1,d6
      or.w      d6,(a6)+
      bra.s     grow_nex1
grow_loo2:
      move.w    (a1)+,(a6)+
grow_nex1:
      dbf       d7,grow_loo2
      movea.l   (sp)+,a1
      add.w     a4,d3
      dbf       d5,grow_loo1
pte_grow3:
      moveq.l   #15,d7
                  rts
grow_lin:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      move.l    d1,-(sp)
      move.w    d3,-(sp)
      move.w    d4,-(sp)
      move.w    #$8000,d6
      moveq.l   #0,d7
      bra.s     grow_rea
grow_nex2:
      add.w     a5,d3
      ror.w     #1,d6
      dbcs      d4,grow_loo3
      swap      d2
      ror.l     d2,d7
      swap      d2
      swap      d7
      or.l      d7,(a1)
      addq.l    #2,a1
      moveq.l   #0,d7
      subq.w    #1,d4
      bmi.s     grow_exi
grow_loo3:
      dbf       d0,grow_tes
grow_rea:
      moveq.l   #15,d0
      move.l    (a0),d1
      addq.l    #2,a0
      lsl.l     d2,d1
      swap      d1
grow_tes:
      btst      d0,d1
      beq.s     grow_whi
      or.w      d6,d7
grow_whi:
      tst.w     d3
      bpl.s     grow_nex2
      add.w     a4,d3
      ror.w     #1,d6
      dbcs      d4,grow_tes
      swap      d2
      ror.l     d2,d7
      swap      d2
      swap      d7
      or.l      d7,(a1)
      addq.l    #2,a1
      moveq.l   #0,d7
      subq.w    #1,d4
      bpl.s     grow_tes
grow_exi:
      move.w    (sp)+,d4
      move.w    (sp)+,d3
      move.l    (sp)+,d1
      movea.l   (sp)+,a1
      movea.l   (sp)+,a0
                  rts
shrink_c1:
      addq.w    #1,d5
      move.w    t_cheight(a6),d7
      mulu.w    t_iheight(a6),d5
      divu.w    d7,d5
      subq.w    #1,d5
      move.w    d5,-(sp)
      swap      d2
      move.w    d0,d2
      move.w    t_iheight(a6),d5
      addq.w    #1,d4
      mulu.w    d7,d4
      divu.w    d5,d4
      subq.w    #1,d4
      bpl.s     shrink_p
      move.w    (sp)+,d5
      bra.s     shrink_c3
shrink_p:
      movea.w   d7,a4
      sub.w     d5,d7
      movea.w   d7,a5
      move.w    d7,d3
      swap      d3
      move.w    d7,d3
      move.w    (sp)+,d5
shrink_c2:
      bsr.s     shrink_l
      adda.w    a2,a0
      adda.w    a3,a1
      swap      d3
      tst.w     d3
      bpl.s     shrink_h
      add.w     a4,d3
      suba.w    a3,a1
      swap      d3
      dbf       d5,shrink_c2
      bra.s     shrink_c3
shrink_h:
      add.w     a5,d3
      swap      d3
      dbf       d5,shrink_c2
shrink_c3:
      moveq.l   #15,d7
                  rts
shrink_l:
      move.l    a0,-(sp)
      move.l    a1,-(sp)
      move.w    d1,-(sp)
      move.w    d3,-(sp)
      move.w    d4,-(sp)
      move.w    #$8000,d6
      moveq.l   #0,d7
      bra.s     shrink_r
shrink_n:
      add.w     a5,d3
      ror.w     #1,d6
      dbcs      d4,shrink_l1
      swap      d2
      ror.l     d2,d7
      swap      d2
      swap      d7
      or.l      d7,(a1)
      addq.l    #2,a1
      moveq.l   #0,d7
      subq.w    #1,d4
      bmi.s     shrink_e
shrink_l1:
      dbf       d0,shrink_t
shrink_r:
      moveq.l   #15,d0
      move.l    (a0),d1
      addq.l    #2,a0
      lsl.l     d2,d1
      swap      d1
shrink_t:
      btst      d0,d1
      beq.s     shrink_w
      or.w      d6,d7
shrink_w:
      tst.w     d3
      bpl.s     shrink_n
      add.w     a4,d3
      bra.s     shrink_l1
shrink_e:
      move.w    (sp)+,d4
      move.w    (sp)+,d3
      move.w    (sp)+,d1
      movea.l   (sp)+,a1
      movea.l   (sp)+,a0
                  rts
text_jus:
      move.w    n_intin(a1),d6
      subq.w    #3,d6
      cmp.w     #$7FFC,d6
      bhi       text_exi
      clr.w     t_act_line(a6)
      move.w    -2(a2),d3
      sne       d3
      ext.w     d3
      move.w    d3,t_space_(a6)
      moveq.l   #0,d5
      move.w    t_effects(a6),d0
      btst      #0,d0
      beq.s     textj_ou
      move.w    t_thicken(a6),d5
textj_ou:
      btst      #4,d0
      beq.s     textj_th
      addq.w    #2,d5
textj_th:
      move.w    d5,t_eff_theight(a6)
      movem.w   t_first_ade(a6),d0-d1
      moveq.l   #-1,d4
      move.w    d6,d7
      movea.l   t_fonthdr(a6),a0
      move.l    dat_table(a0),t_image(a6)
      movea.l   a2,a5
      movea.l   t_offtab(a6),a4
textj_wi1:
      move.w    (a2)+,d2
      tst.w     d3
      bmi.s     textj_ch
      cmp.w     #32,d2
      bne.s     textj_ch
      addq.w    #1,t_space_(a6)
textj_ch:
      sub.w     d0,d2
      cmp.w     d1,d2
      bls.s     textj_wi2
      move.w    t_unknown_index(a6),d2
textj_wi2:
      add.w     d2,d2
      lea.l     2(a4,d2.w),a0
      move.w    (a0),d2
      sub.w     -(a0),d2
      tst.b     t_grow(a6)
      beq.s     textj_ad
      mulu.w    t_cheight(a6),d2
      divu.w    t_iheight(a6),d2
textj_ad:
      add.w     d5,d2
      add.w     d2,d4
      dbf       d7,textj_wi1
      tst.w     d4
      bmi       text_exi
textj_le:
      move.w    4(a3),d3
      btst      #2,t_effects+1(a6)
      beq.s     textj_sp
      sub.w     t_whole_off(a6),d3
textj_sp:
      tst.w     t_space_(a6)
      bpl.s     textj_di
      cmp.w     t_cwidth(a6),d3
      bge.s     textj_di
      move.w    t_cwidth(a6),d3
textj_di:
      subq.w    #1,d3
      neg.w     d4
      add.w     d3,d4
      move.w    d4,t_add_len(a6)
      move.w    d3,d4
      move.w    t_space_(a6),d7
      bmi       text_pos
      move.w    t_add_len(a6),d2
      bpl       text_pos
      move.w    t_space_index(a6),d0
      add.w     d0,d0
      lea.l     2(a4,d0.w),a0
      move.w    (a0),d0
      sub.w     -(a0),d0
      mulu.w    t_cheight(a6),d0
      divu.w    t_iheight(a6),d0
      mulu.w    d7,d0
      neg.w     d0
      cmp.w     d2,d0
      ble       text_pos
      sub.w     d2,d4
      add.w     d0,d4
      move.w    d0,t_add_len(a6)
      bra       text_pos
fellipse1:
      tst.w     d4
      bne.s     fellipse2
      cmpi.w    #3600,d5
      beq       fellipse5
fellipse2:
      tst.w     d5
      bne.s     fellipse3
      cmpi.w    #3600,d4
      beq       fellipse5
fellipse3:
      movea.l   buffer_addr(a6),a1
      move.l    buffer_len(a6),-(sp)
      move.l    a1,-(sp)
      move.w    d0,(a1)+
      move.w    d1,(a1)+
      bsr.s     ellipse_2
      movea.l   (sp),a3
      move.l    (a3),(a1)+
      move.l    a1,d1
      sub.l     a3,d1
      move.l    a1,buffer_addr(a6)
      move.l    d1,buffer_len(a6)
      move.w    d0,d4
      addq.w    #1,d4
      bmi.s     fellipse4
      bsr       v_fillarray3
fellipse4:
      move.l    (sp)+,buffer_addr(a6)
      move.l    (sp)+,buffer_len(a6)
                  rts
ellipse_1:
      movea.l   buffer_addr(a6),a1
ellipse_2:
      ext.l     d4
      ext.l     d5
      move.w    #3600,d6
      cmp.w     d4,d5
      bne.s     ellipse_4
      divs.w    d6,d4
      clr.w     d4
      swap      d4
      tst.w     d4
      bpl.s     ellipse_3
      add.w     d6,d4
ellipse_3:
      divs.w    #10,d4
      bsr       ellipse_14
      move.l    -4(a1),(a1)+
      moveq.l   #2,d0
                  rts
ellipse_4:
      divs.w    d6,d4
      clr.w     d4
      swap      d4
      tst.w     d4
      bpl.s     ellipse_5
      add.w     d6,d4
ellipse_5:
      divs.w    d6,d5
      clr.w     d5
      swap      d5
      tst.w     d5
      bpl.s     ellipse_6
      add.w     d6,d5
ellipse_6:
      cmp.w     d4,d5
      bgt.s     ellipse_7
      add.w     d6,d5
ellipse_7:
      divs.w    #10,d4
      divs.w    #10,d5
      bsr       ellipse_14
      move.l    d5,-(sp)
      lea.l     sin,a0
ellipse_8:
      cmp.w     #100,d2
      bgt.s     ellipse_9
      cmp.w     #100,d3
      bgt.s     ellipse_9
      cmp.w     #20,d2
      ble.s     ellipse_9
      cmp.w     #20,d3
      ble.s     ellipse_9
      addq.w    #8,d4
      andi.w    #$FFF8,d4
      movea.w   #16,a2
      add.w     d4,d4
      adda.w    d4,a0
      lsr.w     #4,d4
      lsr.w     #3,d5
      bra.s     ellipse_11
ellipse_9:
      cmp.w     #300,d2
      bgt.s     ellipse_10
      cmp.w     #300,d3
      bgt.s     ellipse_10
      addq.w    #4,d4
      andi.w    #$FFFC,d4
      movea.w   #8,a2
      add.w     d4,d4
      adda.w    d4,a0
      lsr.w     #3,d4
      lsr.w     #2,d5
      bra.s     ellipse_11
ellipse_10:
      addq.w    #2,d4
      andi.w    #$FFFE,d4
      movea.w   #4,a2
      add.w     d4,d4
      adda.w    d4,a0
      lsr.w     #2,d4
      lsr.w     #1,d5
ellipse_11:
      sub.w     d4,d5
      moveq.l   #1,d4
      subq.w    #1,d5
      bmi.s     ellipse_13
      move.l    #$8000,d7
ellipse_12:
      move.w    (a0),d6
      muls.w    d2,d6
      add.l     d6,d6
      add.l     d7,d6
      swap      d6
      add.w     d0,d6
      bvc.s     ell_noov1
      tst.w     d6
      bmi.s     ell_over1
      move.w    #$8001,d6
      bra.s     ell_noov1
ell_over1:
      move.w    #$7FFF,d6
ell_noov1:
      move.w    d6,(a1)+
      move.w    180(a0),d6
      muls.w    d3,d6
      add.l     d6,d6
      add.l     d7,d6
      swap      d6
      add.w     d1,d6
      bvc.s     ell_noov2
      tst.w     d6
      bmi.s     ell_over2
      move.w    #$8001,d6
      bra.s     ell_noov2
ell_over2:
      move.w    #$7FFF,d6
ell_noov2:
      move.w    d6,(a1)+
      move.l    -(a1),d6
      cmp.l     -4(a1),d6
      beq.s     ell_next
      addq.l    #4,a1
      addq.w    #1,d4
ell_next:
      adda.w    a2,a0
      dbf       d5,ellipse_12
ellipse_13:
      move.w    d4,d5
      addq.w    #1,d5
      move.l    (sp)+,d4
      bsr.s     ellipse_14
      move.w    d5,d0
                  rts
ellipse_14:
      lea.l     sin,a0
      adda.w    d4,a0
      adda.w    d4,a0
      swap      d4
      move.w    (a0)+,d6
      move.w    (a0),d7
      sub.w     d6,d7
      muls.w    d4,d7
      add.l     d7,d7
      divs.w    #10,d7
      addq.w    #1,d7
      asr.w     #1,d7
      add.w     d7,d6
      muls.w    d2,d6
      add.l     d6,d6
      add.l     #$8000,d6
      swap      d6
      add.w     d0,d6
      bvc.s     ell_noov3
      tst.w     d6
      bmi.s     ell_over3
      move.w    #$8001,d6
      bra.s     ell_noov3
ell_over3:
      move.w    #$7FFF,d6
ell_noov3:
      move.w    d6,(a1)+
      lea.l     180(a0),a0
      move.w    (a0),d7
      move.w    -(a0),d6
      sub.w     d6,d7
      muls.w    d4,d7
      add.l     d7,d7
      divs.w    #10,d7
      addq.w    #1,d7
      asr.w     #1,d7
      add.w     d7,d6
      muls.w    d3,d6
      add.l     d6,d6
      add.l     #$8000,d6
      swap      d6
      add.w     d1,d6
      bvc.s     ell_noov4
      tst.w     d6
      bmi.s     ell_over4
      move.w    #$8001,d6
      bra.s     ell_noov4
ell_over4:
      move.w    #$7FFF,d6
ell_noov4:
      move.w    d6,(a1)+
      swap      d4
                  rts
fellipse5:
      moveq.l   #0,d4
      move.w    #3600,d5
      cmp.w     #1000,d2
      bgt       fellipse3
      cmp.w     #1000,d3
      bgt       fellipse3
      bsr.s     fellipse
      tst.w     f_perimeter(a6)
      beq.s     fellipse6
      bsr       ellipse_1
      move.w    d0,d4
      movea.l   buffer_addr(a6),a3
      bra       v_pline_8
fellipse6:
                  rts
fellipse:
      movem.l   d0-d7/a0-a1,-(sp)
      movea.l   buffer_addr(a6),a0
      tst.w     d2
      bgt.s     fellipse7
      neg.w     d2
fellipse7:
      tst.w     d3
      beq.s     fellipse9
      bgt.s     fellipse8
      neg.w     d3
fellipse8:
      bsr.s     fec
fellipse9:
      move.w    d0,d4
      sub.w     d2,d0
      add.w     d2,d2
      add.w     d0,d2
      movem.w   d0-d2/d4,-(sp)
      bsr       fline
      movem.w   (sp)+,d0-d2/d4
      tst.w     d3
      beq.s     fe_exit
      sub.w     d3,d1
      add.w     d3,d3
      add.w     d1,d3
fe_loop:
      move.w    d4,d0
      move.w    d4,d2
      sub.w     (a0),d0
      add.w     (a0)+,d2
      move.w    d4,-(sp)
      movem.w   d0-d2,-(sp)
      bsr       fline
      movem.w   (sp),d0-d2
      move.w    d3,d1
      bsr       fline
      movem.w   (sp)+,d0-d2
      move.w    (sp)+,d4
      addq.w    #1,d1
      subq.w    #1,d3
      cmp.w     d1,d3
      bne.s     fe_loop
fe_exit:
      movem.l   (sp)+,d0-d7/a0-a1
                  rts
fec:
      tst.w     d2
      beq.s     fec_small1
      cmp.w     #1,d2
      beq.s     fec_small3
      cmp.w     #1,d3
      beq       fec_small6
      movem.l   d0-d7/a0,-(sp)
      clr.w     d0
      move.w    d3,d1
      mulu.w    d2,d2
      move.l    d2,d6
      move.l    d2,d7
      add.l     d2,d2
      mulu.w    d3,d3
      add.l     d3,d6
      add.l     d3,d3
      move.l    d2,d5
      move.w    d5,d4
      swap      d5
      mulu.w    d1,d5
      swap      d5
      clr.w     d5
      mulu.w    d1,d4
      add.l     d4,d5
      sub.l     d7,d5
      move.l    d3,d4
      lsr.l     #1,d4
      subq.w    #1,d1
      bmi.s     fec_exit
      bra.s     fec_plus
fec_loop:
      add.l     d5,d6
      sub.l     d2,d5
fec_plus:
      tst.l     d6
      bmi.s     fec_outp
fec_x_lo:
      sub.l     d4,d6
      add.l     d3,d4
      addq.w    #1,d0
      tst.l     d6
      bpl.s     fec_x_lo
fec_outp:
      subq.w    #1,d0
      move.w    d0,(a0)+
      addq.w    #1,d0
      dbf       d1,fec_loop
fec_exit:
      movem.l   (sp)+,d0-d7/a0
                  rts
fec_small1:
      move.l    a0,-(sp)
      move.w    d3,-(sp)
fec_small2:
      clr.w     (a0)+
      dbf       d3,fec_small2
      move.w    (sp)+,d3
      movea.l   (sp)+,a0
                  rts
fec_small3:
      movem.l   d0/d3/a0,-(sp)
      move.w    d3,d0
      add.w     d0,d0
      add.w     d3,d0
      lsr.w     #2,d0
      sub.w     d0,d3
      subq.w    #1,d3
fec_small4:
      clr.w     (a0)+
      dbf       d3,fec_small4
fec_small5:
      move.w    #1,(a0)+
      dbf       d0,fec_small5
      movem.l   (sp)+,d0/d3/a0
                  rts
fec_small6:
      move.w    d0,-(sp)
      move.w    d2,d0
      add.w     d0,d0
      add.w     d2,d0
      lsr.w     #2,d0
      move.w    d0,(a0)
      move.w    (sp)+,d0
                  rts
rbox_cal:
      movea.l   buffer_addr(a6),a3
      cmp.w     d0,d2
      bge.s     rby1y2
      exg       d0,d2
rby1y2:
      cmp.w     d1,d3
      bge.s     rbtestx
      exg       d1,d3
rbtestx:
      move.w    d2,d4
      sub.w     d0,d4
      cmpi.w    #15,d4
      ble.s     rbsmall
rbtesty:
      move.w    d3,d4
      sub.w     d1,d4
      cmpi.w    #15,d4
      bgt.s     rbnormal
rbsmall:
      subq.w    #3,d4
      bpl.s     rbsmall2
      move.w    d0,(a3)+
      move.w    d1,(a3)+
      move.w    d2,(a3)+
      move.w    d1,(a3)+
      move.w    d2,(a3)+
      move.w    d3,(a3)+
      move.w    d0,(a3)+
      move.w    d3,(a3)+
      move.w    d0,(a3)+
      move.w    d1,(a3)+
      moveq.l   #5,d4
                  rts
rbsmall2:
      move.w    d0,d4
      move.w    d1,d5
      move.w    d2,d6
      move.w    d3,d7
      addq.w    #1,d4
      addq.w    #1,d5
      subq.w    #1,d6
      subq.w    #1,d7
      move.w    d4,(a3)+
      move.w    d1,(a3)+
      move.w    d6,(a3)+
      move.w    d1,(a3)+
      move.w    d2,(a3)+
      move.w    d5,(a3)+
      move.w    d2,(a3)+
      move.w    d7,(a3)+
      move.w    d6,(a3)+
      move.w    d3,(a3)+
      move.w    d4,(a3)+
      move.w    d3,(a3)+
      move.w    d0,(a3)+
      move.w    d7,(a3)+
      move.w    d0,(a3)+
      move.w    d5,(a3)+
      moveq.l   #8,d4
                  rts
rbnormal:
      addq.w    #8,d0
      subq.w    #8,d2
      move.w    d0,(a3)+
      move.w    d1,(a3)+
      move.w    d2,(a3)+
      move.w    d1,(a3)+
      moveq.l   #7,d4
      lea.l     round(pc),a4
rbloop1:
      add.w     (a4)+,d2
      addq.w    #1,d1
      move.w    d2,(a3)+
      move.w    d1,(a3)+
      dbf       d4,rbloop1
      subq.w    #8,d3
      move.w    d2,(a3)+
      move.w    d3,(a3)+
      moveq.l   #7,d4
rbloop2:
      sub.w     -(a4),d2
      addq.w    #1,d3
      move.w    d2,(a3)+
      move.w    d3,(a3)+
      dbf       d4,rbloop2
      move.w    d0,(a3)+
      move.w    d3,(a3)+
      lea.l     round(pc),a4
      moveq.l   #7,d4
rbloop3:
      sub.w     (a4)+,d0
      subq.w    #1,d3
      move.w    d0,(a3)+
      move.w    d3,(a3)+
      dbf       d4,rbloop3
      move.w    d0,(a3)+
      move.w    d1,(a3)+
      moveq.l   #7,d4
rbloop4:
      add.w     -(a4),d0
      subq.w    #1,d1
      move.w    d0,(a3)+
      move.w    d1,(a3)+
      dbf       d4,rbloop4
      moveq.l   #37,d4
                  rts
frbox:
      movem.l   d0-d7/a0-a1,-(sp)
frbx1x2:
      cmp.w     d0,d2
      bge.s     frby1y2
      exg       d0,d2
frby1y2:
      cmp.w     d1,d3
      bge.s     frbtestx
      exg       d1,d3
frbtestx:
      move.w    d2,d4
      sub.w     d0,d4
      cmpi.w    #15,d4
      ble.s     frbsmall
frbtesty:
      move.w    d3,d4
      sub.w     d1,d4
      cmpi.w    #15,d4
      bgt.s     frbnormal
frbsmall:
      subq.w    #3,d4
      bpl.s     frbsb
      bsr.s     fbox
      bra.s     frbexit
frbsb:
      addq.w    #1,d0
      subq.w    #1,d2
      bsr       fline_sa
      addq.w    #1,d1
      exg       d1,d3
      bsr       fline_sa
      subq.w    #1,d1
      exg       d1,d3
      subq.w    #1,d0
      addq.w    #1,d2
      bsr.s     fbox
      bra.s     frbexit
frbnormal:
      addq.w    #8,d0
      subq.w    #8,d2
      moveq.l   #7,d4
      lea.l     round(pc),a0
frbloop:
      move.w    d4,-(sp)
      movem.w   d0-d2,-(sp)
      bsr       fline
      movem.w   (sp),d0-d2
      move.w    d3,d1
      bsr       fline
      movem.w   (sp)+,d0-d2
      move.w    (sp)+,d4
      sub.w     (a0),d0
      add.w     (a0)+,d2
      addq.w    #1,d1
      subq.w    #1,d3
      dbf       d4,frbloop
      cmp.w     d1,d3
      blt.s     frbexit
      bsr.s     fbox
frbexit:
      movem.l   (sp)+,d0-d7/a0-a1
                  rts
round:
      ori.b     #$02,d2
      ori.b     #$01,d1
      ori.b     #$01,d0
      ori.b     #$01,d0
fbox:
      movem.l   d0-d7/a0-a6,-(sp)
      bsr.s     fbox_nor
      movem.l   (sp)+,d0-d7/a0-a6
fbox_exit:
                  rts
fbox_nor:
      cmp.w     d0,d2
      bge.s     fbox_exg
      exg       d0,d2
fbox_exg:
      cmp.w     d1,d3
      bge.s     fbox_clip1
      exg       d1,d3
fbox_clip1:
      lea.l     clip_xmin(a6),a1
fbox_clip2:
      cmp.w     (a1)+,d0
      bge.s     fbox_clip3
      move.w    -2(a1),d0
fbox_clip3:
      cmp.w     (a1)+,d1
      bge.s     fbox_clip4
      move.w    -2(a1),d1
fbox_clip4:
      cmp.w     (a1)+,d2
      ble.s     fbox_clip5
      move.w    -2(a1),d2
fbox_clip5:
      cmp.w     d0,d2
      blt.s     fbox_exit
fbox_clip6:
      cmp.w     (a1),d3
      ble.s     fbox_clip7
      move.w    (a1),d3
fbox_clip7:
      cmp.w     d1,d3
      blt.s     fbox_exit
      movea.l   p_fbox(a6),a1 ; ??? where is that set?
      jmp       (a1)
fline_sa:
      movem.l   d0-d2/d4-d7/a1,-(sp)
      bsr.s     fline
      movem.l   (sp)+,d0-d2/d4-d7/a1
                  rts
fline:
      cmp.w     d0,d2
      bge.s     fline_cl
      exg       d0,d2
fline_cl:
      lea.l     clip_xmin(a6),a1
fclip_x1:
      cmp.w     (a1)+,d0
      bge.s     fclip_y1
      move.w    -2(a1),d0
fclip_y1:
      cmp.w     (a1)+,d1
      blt.s     hline_ex
fclip_x2:
      cmp.w     (a1)+,d2
      ble.s     fclip_y2
      move.w    -2(a1),d2
fclip_y2:
      cmp.w     (a1)+,d1
      bgt.s     hline_ex
      cmp.w     d2,d0
      bgt.s     hline_ex
      move.w    (a1),d7
      movea.l   p_fline(a6),a1
      jmp       (a1)
fline_ex:
hline_ex:
                  rts
hline:
      cmp.w     d0,d2
      bge.s     hline_cl
      exg       d0,d2
hline_cl:
      add.w     l_lastpix(a6),d2
      lea.l     clip_xmin(a6),a1
hclip_x1:
      cmp.w     (a1)+,d0
      bge.s     hclip_y1
      move.w    -2(a1),d0
hclip_y1:
      cmp.w     (a1)+,d1
      blt.s     hline_ex
hclip_x2:
      cmp.w     (a1)+,d2
      ble.s     hclip_y2
      move.w    -2(a1),d2
hclip_y2:
      cmp.w     (a1)+,d1
      bgt.s     hline_ex
      cmp.w     d2,d0
      bgt.s     hline_ex
      move.w    (a1),d7
      movea.l   p_hline(a6),a1
      jmp       (a1)
vline:
      cmp.w     d1,d3
      blt.s     vline_ch
      add.w     l_lastpix(a6),d3
      lea.l     clip_xmin(a6),a1
      cmp.w     (a1)+,d0
      blt.s     vline_ex
vclip_y1:
      cmp.w     (a1)+,d1
      bge.s     vclip_x
      move.w    -2(a1),d1
vclip_x:
      cmp.w     (a1)+,d0
      bgt.s     vline_ex
vclip_y2:
      cmp.w     (a1)+,d3
      ble.s     vclip_y_
      move.w    -2(a1),d3
vclip_y_:
      cmp.w     d3,d1
      bgt.s     vline_ex
      move.w    (a1)+,d7
      movea.l   p_vline(a6),a1
      jmp       (a1)
vline_ch:
Clipping:
      exg       d1,d3
      add.w     l_lastpix(a6),d3
      lea.l     clip_xmin(a6),a1
      cmp.w     (a1)+,d0
      blt.s     vline_ex
      cmp.w     (a1)+,d1
      bge.s     vclip_c_1
      move.w    -2(a1),d1
vclip_c_1:
      cmp.w     (a1)+,d0
      bgt.s     vline_ex
      cmp.w     (a1)+,d3
      ble.s     vclip_c_2
      move.w    -2(a1),d3
vclip_c_2:
      cmp.w     d3,d1
      bgt.s     vline_ex
      move.w    (a1)+,d7
      move.w    d3,d2
      sub.w     d1,d2
      andi.w    #15,d2
      ror.w     d2,d6
      movea.l   p_vline(a6),a1
      jmp       (a1)
vline_ex:
                  rts
line:
      cmp.w     d0,d2
      bge.s     line_clip1
      exg       d0,d2
      exg       d1,d3
line_clip1:
      lea.l     clip_xmin(a6),a1
      cmp.w     clip_xmax(a6),d0
      bgt.s     line_exit
      cmp.w     (a1),d2
      blt.s     line_exit
      move.w    d2,d4
      sub.w     d0,d4
      cmp.w     d1,d3
      blt.s     line_clip5
      beq       hline
      move.w    d3,d5
      sub.w     d1,d5
      cmp.w     (a1)+,d0
      bge.s     line_clip2
      sub.w     -(a1),d0
      neg.w     d0
      mulu.w    d5,d0
      divu.w    d4,d0
      add.w     d0,d1
      move.w    (a1)+,d0
line_clip2:
      cmp.w     clip_ymax(a6),d1
      bgt.s     line_exit
      cmp.w     (a1)+,d1
      bge.s     line_clip3
      sub.w     -(a1),d1
      neg.w     d1
      mulu.w    d4,d1
      divu.w    d5,d1
      add.w     d1,d0
      move.w    (a1)+,d1
      cmp.w     (a1),d0
      bgt.s     line_exit
line_clip3:
      cmp.w     (a1)+,d2
      ble.s     line_clip4
      sub.w     -(a1),d2
      mulu.w    d5,d2
      divu.w    d4,d2
      sub.w     d2,d3
      move.w    (a1)+,d2
line_clip4:
      cmp.w     clip_ymin(a6),d3
      blt.s     line_exit
      cmp.w     (a1)+,d3
      ble.s     line_clip9
      sub.w     -(a1),d3
      muls.w    d4,d3
      divs.w    d5,d3
      sub.w     d3,d2
      move.w    (a1)+,d3
      cmp.w     clip_xmin(a6),d2
      bge.s     line_clip9
line_exit:
                  rts
line_clip5:
      move.w    d1,d5
      sub.w     d3,d5
      cmp.w     (a1)+,d0
      bge.s     line_clip6
      sub.w     -(a1),d0
      neg.w     d0
      mulu.w    d5,d0
      divu.w    d4,d0
      sub.w     d0,d1
      move.w    (a1)+,d0
line_clip6:
      cmp.w     (a1)+,d1
      blt.s     line_exit
      cmp.w     clip_ymax(a6),d1
      ble.s     line_clip7
      sub.w     clip_ymax(a6),d1
      mulu.w    d4,d1
      divu.w    d5,d1
      add.w     d1,d0
      move.w    clip_ymax(a6),d1
      cmp.w     (a1),d0
      bgt.s     line_exit
line_clip7:
      cmp.w     (a1)+,d2
      ble.s     line_clip8
      sub.w     -(a1),d2
      mulu.w    d5,d2
      divu.w    d4,d2
      add.w     d2,d3
      move.w    (a1)+,d2
line_clip8:
      cmp.w     (a1)+,d3
      bgt.s     line_exit
      cmp.w     clip_ymin(a6),d3
      bge.s     line_clip9
      sub.w     clip_ymin(a6),d3
      neg.w     d3
      mulu.w    d4,d3
      divu.w    d5,d3
      sub.w     d3,d2
      move.w    clip_ymin(a6),d3
      cmp.w     clip_xmin(a6),d2
      blt.s     line_exit
line_clip9:
      cmp.w     d0,d2
      blt.s     line_exit
      move.w    (a1),d7
      movea.l   p_line(a6),a1
      jmp       (a1)
a_dummy:
                  rts
linea_tab:
      dc.l  linea_init
      dc.l  put_pixel
      dc.l  get_pixel
      dc.l  linea_line
      dc.l  linea_hline
      dc.l  linea_rect
      dc.l  a_dummy ; filled polygon
      dc.l  linea_bit_blt
      dc.l  linea_text_blt
      dc.l  show_mouse
      dc.l  hide_mouse
      dc.l  transform_mouse
      dc.l  undraw_sprite
      dc.l  draw_sprite ; 8eaa
      dc.l  linea_copy_raster
linea_a0:
      dc.l  a_dummy ; seedfill
int_linea:
linea_di:
      movea.l   2(sp),a1
      move.w    (a1)+,d2
      move.l    a1,2(sp)
      subi.w    #$A00F,d2
      bgt.s     linea_ex1
      cmp.w     #$FFF1,d2
      beq.s     linea_ge
      movea.l   (linea_wk_ptr).w,a1
      movea.w   r_planes(a1),a1
      addq.w    #1,a1
      cmpa.w    (PLANES).w,a1
      bne.s     planes_c
linea_ge:
      add.w     d2,d2
      add.w     d2,d2
      movea.l   linea_a0(pc,d2.w),a1
      movem.l   d3-d7/a3-a5,-(sp)
      jsr       (a1)
      movem.l   (sp)+,d3-d7/a3-a5
linea_ex1:
      rte
planes_c:
      rte
linea_init:
      lea.l     (LINE_A_BASE).w,a0
      move.l    a0,d0
      lea.l     linea_font_tab,a1
      lea.l     linea_tab(pc),a2
                  rts
set_lclip:
      lea.l     clip_xmin(a6),a1
      clr.l     (a1)+
      move.l    #$7FFF7FFF,(a1)+
      move.w    (WMODE).w,(a1) ; wr_mode
      move.w    (PLANES).w,d0
      subq.w    #1,d0
      move.w    d0,r_planes(a6)
                  rts
set_lclip2:
      tst.w     (CLIP).w
      beq.s     set_lclip
      lea.l     clip_xmin(a6),a1
      move.l    (XMINCL).w,(a1)+
      move.l    (XMAXCL).w,(a1)+
      move.w    (WMODE).w,(a1) ; wr_mode
      move.w    (PLANES).w,d0
      subq.w    #1,d0
      move.w    d0,r_planes(a6)
                  rts
get_line:
      moveq.l   #0,d0
      moveq.l   #3,d1
      lea.l     (LSTLIN).w,a0
linea_co1:
      add.w     d0,d0
      tst.w     -(a0)
      beq.s     linea_co2
      addq.w    #1,d0
linea_co2:
      dbf       d1,linea_co1
      moveq.l   #15,d1
      and.w     colors(a6),d1
      and.w     d1,d0
      cmp.w     d0,d1
      bne.s     linea_co4
linea_co3:
      moveq.l   #1,d0
                  rts
linea_co4:
      lea.l     color_remap_tab,a0
      move.b    0(a0,d0.w),d0
                  rts
get_line2:
      movea.l   (PATPTR).w,a0
      lea.l     WK_LENGTH(a6),a1
      move.w    #4,f_interior(a6)
      move.l    a1,f_pointer(a6)
      move.w    (MFILL).w,f_splanes(a6)
      bne.s     get_lpat3
      movea.l   (buffer_ptr).w,a1
      move.w    (PATMSK).w,d0
      addq.w    #1,d0
      moveq.l   #16,d2
      divu.w    d0,d2
      subq.w    #1,d0
      subq.w    #1,d2
      bpl.s     get_lpat1
      moveq.l   #15,d0
      moveq.l   #0,d2
get_lpat1:
      move.w    d0,d1
      movea.l   a0,a2
get_lpat2:
      move.w    (a2)+,(a1)+
      dbf       d1,get_lpat2
      dbf       d2,get_lpat1
      movea.l   (buffer_ptr).w,a0
      moveq.l   #0,d0
      bra.s     get_lpat4
get_lpat3:
      move.w    r_planes(a6),d0
get_lpat4:
      addq.w    #1,d0
      lsl.w     #4,d0
      movea.l   f_spointer(a6),a1
      movea.l   p_set_pattern(a6),a2
      jmp       (a2)
put_pixel:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      movea.l   (INTIN).w,a0
      move.w    (a0)+,d2
      movea.l   (PTSIN).w,a0
      move.w    (a0)+,d0
      move.w    (a0)+,d1
      movea.l   p_set_pixel(a6),a0
      jsr       (a0)
      movea.l   (sp)+,a6
                  rts
get_pixel:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      movea.l   (PTSIN).w,a0
      move.w    (a0)+,d0
      move.w    (a0),d1
      movea.l   p_get_pixel(a6),a0
      jsr       (a0)
      movea.l   (sp)+,a6
                  rts
linea_line:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      bsr       set_lclip
      bsr       get_line
      move.w    d0,l_color(a6)
      movem.w   (X1).w,d0-d3
      move.w    (LNMASK).w,d6
      tst.w     (LSTLIN).w
      seq       d4
      ext.w     d4
      move.w    d4,l_lastpix(a6)
      pea.l     linea_line1(pc)
      cmp.w     d1,d3
      beq       hline
      cmp.w     d0,d2
      beq       vline
      bra       line
linea_line1:
      clr.w     l_lastpix(a6)
      movea.l   (sp)+,a6
                  rts
linea_hline:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      bsr       set_lclip
      bsr       get_line
      move.w    d0,f_color(a6)
      bsr       get_line2
      movem.w   (X1).w,d0-d2
      bsr       fline
      movea.l   (sp)+,a6
                  rts
linea_rect:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      bsr       set_lclip2
      bsr       get_line
      move.w    d0,f_color(a6)
      bsr       get_line2
      movem.w   (X1).w,d0-d3
      bsr       fbox
      movea.l   (sp)+,a6
                  rts
linea_bit_blt:
      move.l    a6,-(sp)
      movea.l   a6,a5 ; -> BITBLT structure
      movea.l   (linea_wk_ptr).w,a6
      move.l    18(a5),r_saddr(a6)
      move.w    24(a5),r_swidth(a6)
      move.w    26(a5),d0
      beq.s     linea_blt1
      move.w    4(a5),d0
      subq.w    #1,d0
linea_blt1:
      move.w    d0,r_splanes(a6)
      move.l    32(a5),r_daddr(a6)
      move.w    38(a5),r_dwidth(a6)
      move.w    40(a5),d0
      beq.s     linea_blt2
      move.w    4(a5),d0
      subq.w    #1,d0
linea_blt2:
      move.w    d0,r_dplanes(a6)
      move.w    14(a5),d0
      move.w    16(a5),d1
      move.w    28(a5),d2
      move.w    30(a5),d3
      move.w    (a5),d4
      subq.w    #1,d4
      move.w    2(a5),d5
      subq.w    #1,d5
      move.w    6(a5),d6
      move.w    8(a5),d7
      move.w    d6,r_fgcol(a6)
      move.w    d7,r_bgcol(a6)
      and.w     #1,d6
      and.w     #1,d7
      add.w     d6,d6
      add.w     d7,d6
      move.b    10(a5,d6.w),d7
      move.w    d7,r_wmode(a6)
      cmpi.w    #1,4(a5)
      bne.s     linea_bit_blt1
      movea.l   (mono_bitblt).w,a0
      jsr       (a0)
      bra.s     linea_blt3
linea_bit_blt1:
      move.w    r_splanes(a6),d6
      cmp.w     r_dplanes(a6),d6
      bne.s     linea_bit_blt2
      movea.l   p_bitblt(a6),a0
      jsr       (a0)
      bra.s     linea_blt3
linea_bit_blt2:
      move.l    10(a5),d6
      moveq.l   #3,d7
      cmp.l     #$010D010D,d6
      beq.s     linea_ex2
      moveq.l   #2,d7
      cmp.l     #$06060606,d6
      beq.s     linea_ex2
      moveq.l   #1,d7
      cmp.l     #$04040707,d6
      beq.s     linea_ex2
      moveq.l   #0,d7
linea_ex2:
      move.w    d7,r_wmode(a6)
      movea.l   p_expblt(a6),a0
      jsr       (a0)
linea_blt3:
      movea.l   (sp)+,a6
      lea.l     76(a6),a6
                  rts
linea_text_blt:
      move.l    a6,-(sp)
      lea.l     -130(sp),a7
      movea.l   (linea_wk_ptr).w,a6
      bsr       set_lclip2
      movea.l   a7,a1
      lea.l     32(a1),a2
      lea.l     2(a2),a3
      lea.l     4(a3),a4
      lea.l     4(a4),a5
      lea.l     color_remap_tab,a0
      move.w    (TEXTFG).w,d0
      moveq.l   #15,d1
      and.w     colors(a6),d1
      and.w     d1,d0
      move.w    #1,t_color(a6)
      cmp.w     d0,d1
      beq.s     atext_in
      move.b    0(a0,d0.w),t_color(a6)
atext_in:
      clr.b     t_mapping(a6)
      clr.w     t_first_ade(a6)
      clr.w     t_ades(a6)
      clr.w     t_space_index(a6)
      clr.w     t_unknown_index(a6)
      move.b    #$01,t_prop(a6)
      clr.b     t_grow(a6)
      clr.w     t_no_kern(a6)
      clr.w     t_no_track(a6)
      clr.l     t_hor(a6) ; also clr t_ver
      clr.l     t_base(a6) ; also clr t_half
      clr.l     t_descent(a6) ; also clr t_bottom
      clr.l     t_ascent(a6) ; also clr t_top 
      clr.l     t_left_off(a6) ; also clr t_whole_off
      move.w    (WEIGHT).w,d0
      tst.w     (MONO).w
      beq.s     atext_th1
      moveq.l   #0,d0
atext_th1:
      cmp.w     #15,d0
      bls.s     atext_th2
      moveq.l   #15,d0
atext_th2:
      move.w    d0,t_thicken(a6)
      move.l    a5,t_pointer(a6)
      move.l    a5,t_fonthdr(a6)
      move.l    a4,t_offtab(a6)
      move.w    (SOURCEX).w,d0
      move.w    d0,(a4)
      add.w     (DELX).w,d0
      move.w    d0,2(a4)
      movem.w   (DESTX).w,d2-d5
      move.w    (FWIDTH).w,d0
      move.w    d0,t_iwidth(a6)
      mulu.w    (SOURCEY).w,d0
      movea.l   (FBASE).w,a0
      adda.l    d0,a0
      move.l    a0,t_image(a6)
      move.w    d5,t_iheight(a6)
      move.l    a4,off_table(a5)
      movea.l   t_image(a6),a0
      move.l    a0,dat_table(a5)
      move.w    t_iwidth(a6),form_width(a5)
      move.w    t_iheight(a6),form_height(a5)
      clr.l     next_font(a5)
      move.w    (STYLE).w,d0
      bclr      #3,d0
      move.w    d0,t_effects(a6)
      move.w    (SCALE).w,d6
      beq.s     atext_se
      move.w    (DDAINC).w,d1
      mulu.w    d5,d1
      swap      d1
      moveq.l   #-1,d6
      tst.w     (SCALDIR).w
      bgt.s     atext_he
      moveq.l   #1,d6
      moveq.l   #0,d5
atext_he:
      add.w     d1,d5
atext_se:
      move.w    d5,t_cheight(a6)
      move.b    d6,t_grow(a6)
      move.w    d5,d0
      lsr.w     #1,d0
      move.w    d0,t_whole_off(a6)
      mulu.w    d5,d4
      divu.w    (DELY).w,d4
      move.w    d4,t_cwidth(a6)
      move.w    t_effects(a6),d0
      btst      #0,d0
      beq.s     atext_out
      add.w     t_thicken(a6),d4
atext_out:
      btst      #4,d0
      beq.s     atext_ro1
      addq.w    #2,d4
      addq.w    #2,d5
atext_ro1:
      moveq.l   #0,d0
      move.w    (CHUP).w,d0
      divu.w    #$0384,d0
      move.w    d0,t_rotation(a6)
      bne.s     atext_ro2
      add.w     d4,(DESTX).w
      bra.s     atext_ca
atext_ro2:
      subq.w    #1,d0
      bne.s     atext_ro3
      sub.w     d4,(DESTY).w
      bra.s     atext_ca
atext_ro3:
      subq.w    #1,d0
      bne.s     atext_ro4
      sub.w     d4,(DESTX).w
      bra.s     atext_ca
atext_ro4:
      add.w     d4,(DESTY).w
atext_ca:
      move.w    #1,6(a1)
      clr.w     (a2)
      movem.w   d2-d3,(a3)
      bsr       text
      lea.l     130(sp),a7
      movea.l   (sp)+,a6
                  rts
show_mouse:
      move.l    a6,-(sp)
      moveq.l   #122,d0
      lea.l     (CONTRL).w,a0
      move.l    a0,d1
      movea.l   (linea_wk_ptr).w,a6
      bsr       call_nvd
      movea.l   (sp)+,a6
                  rts
hide_mouse:
      move.l    a6,-(sp)
      moveq.l   #123,d0
      lea.l     (CONTRL).w,a0
      move.l    a0,d1
      movea.l   (linea_wk_ptr).w,a6
      bsr       call_nvd
      movea.l   (sp)+,a6
                  rts
transform_mouse:
      movea.l   (INTIN).w,a2
transform_mouse1:
      move.w    (DEV_TAB+26).w,d5
      subq.w    #1,d5
      lea.l     -44(sp),a7
      bra       vsc_form3
undraw_sprite:
      move.l    (undraw_spr_vec).w,-(sp)
                  rts
undraw_sprite_in:
      move.w    (a2)+,d2
      subq.w    #1,d2
      bmi.s     undraw_error
      cmpi.w    #30,(nvdi_cpu_type).w
      bne.s     undraw_sprite1
      btst      #0,(blitter+1).w
      beq.s     undraw_sprite1
      dc.w $4e7a,$0002 ; movec     cacr,d0
      bset      #11,d0
      dc.w $4e7b,$0002 ; movec     d0,cacr
undraw_sprite1:
      movea.l   (a2)+,a1
      bclr      #0,(a2)
      beq.s     undraw_error
      movea.w   (BYTES_LIN).w,a3
      addq.l    #2,a2
      move.w    (PLANES).w,d0
      moveq.l   #0,d1
      move.b    undraw_tab-1(pc,d0.w),d1
      add.w     d0,d0
      add.w     d0,d0
      suba.w    d0,a3
      jmp       undraw_tab(pc,d1.w)
undraw_tab:
      dc.b undraw_1-undraw_tab
      dc.b undraw_2-undraw_tab
      dc.b undraw_error-undraw_tab
      dc.b undraw_4-undraw_tab
      dc.b undraw_error-undraw_tab
      dc.b undraw_error-undraw_tab
      dc.b undraw_error-undraw_tab
      dc.b undraw_8-undraw_tab
undraw_1:
      move.l    (a2)+,(a1)+
      adda.w    a3,a1
      dbf       d2,undraw_1
undraw_error:
                  rts
undraw_2:
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      adda.w    a3,a1
      dbf       d2,undraw_2
                  rts
undraw_4:
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      adda.w    a3,a1
      dbf       d2,undraw_4
                  rts
undraw_8:
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      move.l    (a2)+,(a1)+
      adda.w    a3,a1
      dbf       d2,undraw_8
vbl_mouse1:
                  rts
vbl_mouse2:
      tst.w     (M_HID_CNT).w
      bne.s     vbl_mouse1
      tst.b     (MOUSE_FLAG).w
      bne.s     vbl_mouse1
      bclr      #0,(CUR_FLAG).w
      beq.s     vbl_mouse1
      movea.l   (mouse_buffer).w,a2
      move.l    a2,-(sp)
      bsr       undraw_sprite
      movea.l   (sp)+,a2
      movem.w   (CUR_X).w,d0-d1
      lea.l     (M_POS_HX).w,a0
draw_sprite:
      move.l    (draw_spr_vec).w,-(sp)
                  rts
draw_sprite_in:
      move.l    a6,-(sp)
      move.w    6(a0),-(sp)
      move.w    8(a0),-(sp)
      clr.w     d2
      tst.w     4(a0)
      bge.s     vdi_form
      moveq.l   #16,d2
vdi_form:
      move.w    d2,-(sp)
      clr.w     d2
      sub.w     (a0),d0
      bcs.s     Xko_lt_i
      move.w    (DEV_TAB).w,d3
      subi.w    #15,d3
      cmp.w     d3,d0
      bhi.s     X_am_rRa
      bra.s     get_yhot
Xko_lt_i:
      addi.w    #16,d0
      moveq.l   #4,d2
      bra.s     get_yhot
X_am_rRa:
      moveq.l   #8,d2
get_yhot:
      sub.w     2(a0),d1
      lea.l     10(a0),a0
      bcs.s     Y_am_oRa
      move.w    (DEV_TAB+2).w,d3
      subi.w    #15,d3
      cmp.w     d3,d1
      bhi.s     Y_am_uRa
      moveq.l   #16,d5
      bra.s     hole_Koo
Y_am_oRa:
      move.w    d1,d5
      addi.w    #16,d5
      asl.w     #2,d1
      suba.w    d1,a0
      clr.w     d1
      bra.s     hole_Koo
Y_am_uRa:
      move.w    (DEV_TAB+2).w,d5
      sub.w     d1,d5
      addq.w    #1,d5
hole_Koo:
      bsr       calc_add
      andi.w    #15,d0
      lea.l     draw_sprite15(pc),a3 ; 904e
      move.w    d0,d6
      cmpi.w    #8,d6
      bcs.s     load_drr
      lea.l     draw_sprite14(pc),a3 ; 9040
      move.w    #16,d6
      sub.w     d0,d6
load_drr:
      movea.l   draw_sprite2(pc,d2.w),a5 ; 8f7e
      movea.l   draw_sprite3(pc,d2.w),a6 ; 8f8a
      move.w    (PLANES).w,d7
      move.w    d7,d3
      add.w     d3,d3
      ext.l     d3
      move.w    (BYTES_LIN).w,d4
      cmpi.w    #30,(nvdi_cpu_type).w
      bne.s     draw_sprite1
      btst      #0,(blitter+1).w
      beq.s     draw_sprite1
      dc.w $4e7a,$0002 ; movec     cacr,d0
      bset      #11,d0
      dc.w $4e7b,$0002 ; movec     d0,cacr
draw_sprite1:
      move.w    d5,(a2)+
      move.l    a1,(a2)+
      cmpa.l    #draw_sprite12,a6
      bne.s     draw_x_o
      sub.l     d3,-4(a2)
draw_x_o:
      move.w    #$0300,(a2)+
      subq.w    #1,d5
      bpl.s     draw_sprite5
      bra.s     draw_sprite6
draw_sprite2:
      dc.l draw_sprite9
      dc.l draw_sprite11
      dc.l draw_sprite13
draw_sprite3:
      dc.l draw_sprite8
      dc.l draw_sprite10
      dc.l draw_sprite12
draw_sprite4:
      clr.w     d0
      lsr.w     2(sp)
      addx.w    d0,d0
      lsr.w     4(sp)
      roxl.w    #3,d0
      add.w     (sp),d0
      movea.l   draw_sprite7(pc,d0.w),a4 ; 8fc6
      move.w    d5,-(sp)
      movem.l   a0-a2,-(sp)
      jsr       (a6)
      movem.l   (sp)+,a0-a2
      move.w    (sp)+,d5
      addq.l    #2,a1
      addq.l    #2,a2
draw_sprite5:
      dbf       d7,draw_sprite4
draw_sprite6:
      addq.l    #6,a7
      movea.l   (sp)+,a6
                  rts
draw_sprite7:
      dc.l draw_sprite16
      dc.l draw_sprite17
      dc.l draw_sprite18
      dc.l draw_sprite19
      dc.l draw_sprite20
      dc.l draw_sprite21
      dc.l draw_sprite22
      dc.l draw_sprite23
draw_sprite8:
      move.w    (a1),d2
      move.w    d2,(a2)
      adda.w    d3,a2
      swap      d2
      move.w    0(a1,d3.w),d2
      move.w    d2,(a2)
      adda.w    d3,a2
      jmp       (a3)
draw_sprite9:
      move.w    d2,0(a1,d3.w)
      swap      d2
      move.w    d2,(a1)
      adda.w    d4,a1
      dbf       d5,draw_sprite8
                  rts
draw_sprite10:
      move.w    (a1),d2
      move.w    d2,(a2)
      adda.w    d3,a2
      move.w    0(a1,d3.w),(a2)
      adda.w    d3,a2
      jmp       (a3)
draw_sprite11:
      move.w    d2,(a1)
      adda.w    d4,a1
      dbf       d5,draw_sprite10
                  rts
draw_sprite12:
      move.w    (a1),d2
      neg.w     d3
      move.w    0(a1,d3.w),(a2)
      neg.w     d3
      adda.w    d3,a2
      move.w    d2,(a2)
      adda.w    d3,a2
      swap      d2
      jmp       (a3)
draw_sprite13:
      swap      d2
      move.w    d2,(a1)
      adda.w    d4,a1
      dbf       d5,draw_sprite12
                  rts
draw_sprite14:
      moveq.l   #0,d0
      moveq.l   #0,d1
      move.w    (a0)+,d0
      move.w    (a0)+,d1
      rol.l     d6,d0
      rol.l     d6,d1
      jmp       (a4)
draw_sprite15:
      move.l    (a0)+,d0
      move.w    d0,d1
      swap      d1
      clr.w     d0
      clr.w     d1
      ror.l     d6,d0
      ror.l     d6,d1
      jmp       (a4)
draw_sprite16:
      or.l      d1,d0
      not.l     d0
      and.l     d0,d2
      jmp       (a5)
draw_sprite17:
      or.l      d0,d2
      not.l     d1
      and.l     d1,d2
      jmp       (a5)
draw_sprite18:
      not.l     d0
      and.l     d0,d2
      or.l      d1,d2
      jmp       (a5)
draw_sprite19:
      or.l      d0,d2
      or.l      d1,d2
      jmp       (a5)
draw_sprite20:
      eor.l     d1,d2
      not.l     d0
      and.l     d0,d2
      jmp       (a5)
draw_sprite21:
      or.l      d0,d2
      eor.l     d1,d2
      jmp       (a5)
draw_sprite22:
      not.l     d0
      and.l     d0,d2
      eor.l     d1,d2
      jmp       (a5)
draw_sprite23:
      eor.l     d0,d2
      or.l      d1,d2
      jmp       (a5)
calc_add:
      move.w    d0,-(sp)
      move.w    d1,-(sp)
      movea.l   (v_bas_ad).w,a1
      muls.w    (BYTES_LIN).w,d1
      adda.l    d1,a1
      and.w     #$FFF0,d0
      asr.w     #3,d0
      mulu.w    (PLANES).w,d0
      adda.w    d0,a1
      move.w    (sp)+,d1
      move.w    (sp)+,d0
                  rts
linea_copy_raster:
      move.l    a6,-(sp)
      movea.l   (linea_wk_ptr).w,a6
      lea.l     clip_xmin(a6),a0
      clr.l     (a0)+
      move.l    #$7FFF7FFF,(a0)+
      move.w    (DEV_TAB+26).w,d0
      subq.w    #1,d0
      move.w    d0,colors(a6)
      lea.l     (CONTRL).w,a0
      move.l    a0,d1
      pea.l     linea_cf(pc)
      tst.w     (COPYTRAN).w
      beq       vro_cpyfm
      bra       vrt_cpyfm
linea_cf:
      movea.l   (sp)+,a6
                  rts
mouse_int:
      move.w    sr,-(sp)
      movem.l   d0-d3/a0-a1,-(sp)
      ori.w     #$0700,sr
      nop ; was andi.w    #$FDFF,sr
      nop
mouse_int2:
      move.b    (a0)+,d0
      move.b    d0,d1
      moveq.l   #-8,d2
      and.b     d2,d1
      sub.b     d2,d1
      bne.s     mouse_ex
      moveq.l   #3,d2
      and.w     d2,d0
      lsr.w     #1,d0
      bcc.s     mouse_button
      addq.w    #2,d0
mouse_button:
      move.b    (CUR_MS_STAT).w,d1
      and.w     d2,d1
      cmp.w     d1,d0
      beq.s     mouse_no
      movea.l   (USER_BUT).w,a1
      move.w    d1,-(sp)
      jsr       (a1)
      move.w    (sp)+,d1
      move.w    d0,(MOUSE_BT).w
      eor.b     d0,d1
      ror.b     #2,d1
      or.b      d0,d1
mouse_no:
      move.b    d1,(CUR_MS_STAT).w
      move.b    (a0)+,d2
      move.b    (a0)+,d3
      move.b    d2,d0
      or.b      d3,d0
      beq.s     mouse_ex
      ext.w     d2
      ext.w     d3
      movem.w   (GCURX).w,d0-d1
      add.w     d2,d0
      add.w     d3,d1
      bsr.s     clip_mouse
      cmp.w     (GCURX).w,d0
      bne.s     mouse_user
      cmp.w     (GCURY).w,d1
      beq.s     mouse_ex
mouse_user:
      bset      #5,(CUR_MS_STAT).w
      movem.w   d0-d1,-(sp)
      movea.l   (USER_MOT).w,a1
      jsr       (a1)
      movem.w   (sp)+,d2-d3
      sub.w     d0,d2
      sub.w     d1,d3
      or.w      d2,d3
      beq.s     mouse_sa
      bsr.s     clip_mouse
mouse_sa:
      movem.w   d0-d1,(GCURX).w
      movea.l   (USER_CUR).w,a1
      jsr       (a1)
mouse_ex:
      movem.l   (sp)+,d0-d3/a0-a1
      move.w    (sp)+,sr
                  rts
clip_mouse:
      tst.w     d0
      bpl.s     clip_mouse1
      moveq.l   #0,d0
      bra.s     clip_mouse2
clip_mouse1:
      cmp.w     (V_REZ_HZ).w,d0
      blt.s     clip_mouse2
      move.w    (V_REZ_HZ).w,d0
      subq.w    #1,d0
clip_mouse2:
      tst.w     d1
      bpl.s     clip_mouse3
      moveq.l   #0,d1
                  rts
clip_mouse3:
      cmp.w     (V_REZ_VT).w,d1
      blt.s     clip_mouse4
      move.w    (V_REZ_VT).w,d1
      subq.w    #1,d1
clip_mouse4:
                  rts
user_cur:
      move.w    sr,-(sp)
      ori.w     #$0700,sr
      move.w    d0,(CUR_X).w
      move.w    d1,(CUR_Y).w
      bset      #0,(CUR_FLAG).w
      move.w    (sp)+,sr
                  rts
sys_time:
      move.l    (NEXT_TIM).w,-(sp)
      move.l    (USER_TIM).w,-(sp)
                  rts
v_escape_call:
      move.l    p_escape(a6),-(sp)
                  rts
v_escape:
      tst.w     bitmap_width(a6)
      bne.s     v_escape2
      movea.l   (a0),a1
      move.w    opcode2(a1),d0
      cmp.w     #19,d0
      bhi.s     v_escape2
      movem.l   d1-d7/a2-a5,-(sp)
      movem.l   4(a0),a2-a5
      add.w     d0,d0
      move.w    v_escape_tab(pc,d0.w),d2
      movea.l   a2,a5
      movea.l   a1,a0
      movem.w   (V_CUR_XY).w,d0-d1
      movea.l   (V_CUR_AD).w,a1
      movea.w   (BYTES_LIN).w,a2
      jsr       v_escape_tab(pc,d2.w)
      movem.l   (sp)+,d1-d7/a2-a5
v_escape1:
                  rts
v_escape2:
                  rts
v_escape_tab:
      dc.w  v_escape1-v_escape_tab
      dc.w  vq_chcells-v_escape_tab
      dc.w  v_exit_cur-v_escape_tab
      dc.w  v_enter_cur-v_escape_tab
      dc.w  vt_seq_A-v_escape_tab
      dc.w  vt_seq_B-v_escape_tab
      dc.w  vt_seq_C-v_escape_tab
      dc.w  vt_seq_D-v_escape_tab
      dc.w  vt_seq_H-v_escape_tab
      dc.w  vt_seq_J-v_escape_tab
      dc.w  v_eeol-v_escape_tab
      dc.w  vs_curaddress-v_escape_tab
      dc.w  v_curtext-v_escape_tab
      dc.w  vt_seq_p-v_escape_tab
      dc.w  vt_seq_q-v_escape_tab
      dc.w  vq_curaddress-v_escape_tab
      dc.w  vq_tabstatus-v_escape_tab
      dc.w  v_hardcopy-v_escape_tab
      dc.w  v_dspcur-v_escape_tab
      dc.w  v_rmcur-v_escape_tab
vq_chcells:
      move.l    (V_CEL_MX).w,d3
      addi.l    #$00010001,d3
      swap      d3
      move.l    d3,(a4)
      move.w    #2,n_intout(a0)
                  rts
v_exit_cur:
      addq.w    #1,(V_HID_CNT).w
      bclr      #1,(V_STAT_0).w
      bra       clear_screen
v_enter_cur:
      clr.l     (V_CUR_XY).w
      move.l    (v_bas_ad).w,(V_CUR_AD).w
      move.l    (con_vec).w,(con_state).w
      jsr       clear_screen
      bclr      #1,(V_STAT_0).w
      move.w    #1,(V_HID_CNT).w
      bra       cursor_off2
vs_curaddress:
      move.w    (a5)+,d1
      move.w    (a5)+,d0
      subq.w    #1,d0
      subq.w    #1,d1
      bra       set_curs1
v_curtext:
      moveq.l   #0,d1
      move.w    6(a0),d1
      subq.w    #1,d1
      bmi.s     v_curtext2
      movea.l   buffer_addr(a6),a0
      movea.l   a0,a1
      move.l    buffer_len(a6),d0
      subq.l    #1,d0
      sub.l     d1,d0
      bgt.s     v_curtext1
      add.l     d1,d0
      move.l    d0,d1
v_curtext1:
      move.w    (a5)+,d0
      move.b    d0,(a1)+
      dbf       d1,v_curtext1
      clr.b     (a1)+
      move.l    a0,-(sp)
      move.w    #9,-(sp)
      trap      #1
      addq.l    #6,a7
v_curtext2:
                  rts
vq_curaddress:
      addq.w    #1,d0
      addq.w    #1,d1
      move.w    d1,(a4)+
      move.w    d0,(a4)+
      move.w    #2,n_intout(a0)
                  rts
vq_tabstatus:
      move.w    #1,(a4)
      move.w    #1,n_intout(a0)
                  rts
v_dspcur:
v_rmcur:
                  rts
v_hardcopy:
      move.w    #20,-(sp) ; Scrdmp
      trap      #14
      addq.l    #2,a7
                  rts
Blitmode:
      move.w    (a0),d0
      bmi.s     Blitmode1
      lea.l     (blitter).w,a0
      btst      #1,1(a0)
      beq.s     Blitmode1
      and.w     #1,d0
      andi.w    #$FFFE,(a0)
      or.w      d0,(a0)
Blitmode1:
      move.w    (blitter).w,d0
      rte
vdi_cursor:
      tst.w     (V_HID_CNT).w
      bne.s     vdi_cursor1
      subq.b    #1,(V_CUR_CT).w
      bne.s     vdi_cursor1
      move.b    (V_PERIOD).w,(V_CUR_CT).w
      move.l    (cursor_vbl_vec).w,-(sp)
vdi_cursor1:
                  rts
rawcon:
vdi_rawout:
      lea.l     6(sp),a0
      move.w    (a0),d1
      and.w     #$ff,d1
      movea.l   (rawcon_vec).w,a0
      jmp       (a0)
bconout:
vdi_conout:
      lea.l     6(sp),a0
      move.w    (a0),d1
      and.w     #$ff,d1
      movea.l   (con_state).w,a0
      jmp       (a0)
set_curs1:
      bsr.w     cursor_off
set_cur_1:
      move.w    (V_CEL_MX).w,d2
      tst.w     d0
      bpl.s     set_cur_2
      moveq.l   #0,d0
set_cur_2:
      cmp.w     d2,d0
      ble.s     set_cur_3
      move.w    d2,d0
set_cur_3:
      move.w    (V_CEL_MY).w,d2
      tst.w     d1
      bpl.s     set_cur_4
      moveq.l   #0,d1
set_cur_4:
      cmp.w     d2,d1
      ble.s     set_curs2
      move.w    d2,d1
set_curs2:
      movem.w   d0-d1,(V_CUR_XY).w
      movea.l   (v_bas_ad).w,a1
      mulu.w    (V_CEL_WR).w,d1
      adda.l    d1,a1
      moveq.l   #1,d1
      and.w     d0,d1
      and.w     #$FFFE,d0
      mulu.w    (PLANES).w,d0
      add.w     d1,d0
      adda.w    d0,a1
      adda.w    (V_CUR_OF).w,a1
      move.l    a1,(V_CUR_AD).w
      bra.s     cursor_off2
cursor_off:
      addq.w    #1,(V_HID_CNT).w
      cmpi.w    #1,(V_HID_CNT).w
      bne.s     cursor_off1
      bclr      #1,(V_STAT_0).w
      bne.s     cursor
cursor_off1:
                  rts
cursor_off2:
      cmpi.w    #1,(V_HID_CNT).w
      bcs.s     cursor_off4
      bhi.s     cursor_off3
      move.b    (V_PERIOD).w,(V_CUR_CT).w
      bsr.s     cursor
      bset      #1,(V_STAT_0).w
cursor_off3:
      subq.w    #1,(V_HID_CNT).w
cursor_off4:
                  rts
vbl_cursor:
      btst      #0,(V_STAT_0).w
      beq.s     vbl_no_b
      bchg      #1,(V_STAT_0).w
      bra.s     cursor
vbl_no_b:
      bset      #1,(V_STAT_0).w
      beq.s     cursor
                  rts
cursor:
      movem.l   d0-d2/a0-a2,-(sp)
      move.w    (PLANES).w,d0
      subq.w    #1,d0
      move.w    (V_CEL_HT).w,d2
      subq.w    #1,d2
      movea.l   (V_CUR_AD).w,a0
      movea.w   (BYTES_LIN).w,a2
cursor_b:
      movea.l   a0,a1
      move.w    d2,d1
cursor_l:
      not.b     (a1)
      adda.w    a2,a1
      dbf       d1,cursor_l
      addq.l    #2,a0
      dbf       d0,cursor_b
      movem.l   (sp)+,d0-d2/a0-a2
cursor_e:
                  rts
vt_bel:
      btst      #2,(conterm).w
      beq.s     cursor_e
      movea.l   (bell_hook).w,a0
      jmp       (a0)
make_pling:
      pea.l     pling(pc)
      move.w    #32,-(sp) ; Dosound
      trap      #14
      addq.l    #6,a7
                  rts
pling:
      dc.w  $0034,$0100,$0200,$0300
      dc.w  $0400,$0500,$0600,$07FE
      dc.w  $0810,$0900,$0A00,$0B00
      dc.w  $0C10,$0D09,$FF00
vt_bs:
      movem.w   (V_CUR_XY).w,d0-d1
      subq.w    #1,d0
      bra       set_curs1
vt_ht:
      andi.w    #$FFF8,d0
      addq.w    #8,d0
      bra       set_curs1
vt_lf:
      pea.l     cursor_off2(pc)
      bsr       cursor_off
      sub.w     (V_CEL_MY).w,d1
      beq       scroll_up
      move.w    (V_CEL_WR).w,d1
      add.l     d1,(V_CUR_AD).w
      addq.w    #1,(V_CUR_XY+2).w
                  rts
vt_cr:
      bsr       cursor_off
      pea.l     cursor_off2(pc)
      movea.l   (V_CUR_AD).w,a1
set_x0:
      move.w    (PLANES).w,d2
      btst      #0,d0
      beq.s     set_x0_e
      subq.w    #1,d0
      mulu.w    d2,d0
      addq.l    #1,d0
      bra.s     set_x0_a
set_x0_e:
      mulu.w    d2,d0
set_x0_a:
      suba.l    d0,a1
      move.l    a1,(V_CUR_AD).w
      clr.w     (V_CUR_XY).w
                  rts
vt_esc:
      move.l    #vt_esc_s,(con_state).w
                  rts
vt_contr:
      cmpi.w    #27,d1
      beq.s     vt_esc
      subq.w    #7,d1
      subq.w    #6,d1
      bhi.s     vt_c_exit
      move.l    #vt_con,(con_state).w
      add.w     d1,d1
      move.w    vt_c_tab(pc,d1.w),d2
      movem.w   (V_CUR_XY).w,d0-d1
      jmp       vt_c_tab(pc,d2.w)
vt_c_exit:
                  rts

      dc.w      vt_bel-vt_c_tab
      dc.w      vt_bs-vt_c_tab
      dc.w      vt_ht-vt_c_tab
      dc.w      vt_lf-vt_c_tab
      dc.w      vt_lf-vt_c_tab
      dc.w      vt_lf-vt_c_tab
vt_c_tab:
      dc.w      vt_cr-vt_c_tab

vt_con:
      cmpi.w    #32,d1
      blt.s     vt_contr
vt_rawcon:
      move.l    d3,-(sp)
      move.w    (V_CEL_HT).w,d0
      subq.w    #1,d0
      movea.l   (V_FNT_AD).w,a0
      movea.l   (V_CUR_AD).w,a1
      movea.w   (BYTES_LIN).w,a2
      adda.w    d1,a0
      move.w    (PLANES).w,d2
      subq.w    #1,d2
      move.l    (V_COL_BG).w,d3
      move.b    #$04,(V_CUR_CT).w
      bclr      #1,(V_STAT_0).w
      btst      #4,(V_STAT_0).w
      beq.s     vtc_char1
      swap      d3
vtc_char1:
      movem.l   d0/a0-a1,-(sp)
      pea.l     vtc_char3(pc)
      lsr.l     #1,d3
      bcc.s     vtc_char2
      btst      #15,d3
      beq       vtc_char4
      bra       vtc_bg_b
vtc_char2:
      btst      #15,d3
      bne       vtc_char5
      bra       vtc_bg_w
vtc_char3:
      movem.l   (sp)+,d0/a0-a1
      addq.l    #2,a1
      dbf       d2,vtc_char1
      move.l    (sp)+,d3
      move.w    (V_CUR_XY).w,d0
      cmp.w     (V_CEL_MX).w,d0
      bge.s     vtc_l_co
      addq.w    #1,(V_CUR_XY).w
      lsr.w     #1,d0
      bcs.s     vtc_n_co
      addq.l    #1,(V_CUR_AD).w
                  rts
vtc_n_co:
      subq.l    #1,a1
      move.l    a1,(V_CUR_AD).w
                  rts
vtc_l_co:
      btst      #3,(V_STAT_0).w
      beq.s     vtc_con_2
      addq.w    #1,(V_HID_CNT).w
      subq.w    #1,d0
      mulu.w    (PLANES).w,d0
      addq.w    #1,d0
      movea.l   (V_CUR_AD).w,a1
      suba.w    d0,a1
      move.l    a1,(V_CUR_AD).w
      clr.w     (V_CUR_XY).w
      move.w    (V_CUR_XY+2).w,d1
      pea.l     vtc_con_1(pc)
      cmp.w     (V_CEL_MY).w,d1
      bge       scroll_up
      addq.l    #4,a7
      adda.w    (V_CEL_WR).w,a1
      move.l    a1,(V_CUR_AD).w
      addq.w    #1,(V_CUR_XY+2).w
vtc_con_1:
      subq.w    #1,(V_HID_CNT).w
vtc_con_2:
                  rts
vtc_char4:
      move.b    (a0),(a1)
      lea.l     256(a0),a0
      adda.w    a2,a1
      dbf       d0,vtc_char4
                  rts
vtc_char5:
      move.b    (a0),d1
      not.b     d1
      move.b    d1,(a1)
      lea.l     256(a0),a0
      adda.w    a2,a1
      dbf       d0,vtc_char5
                  rts
vtc_bg_w:
      moveq.l   #0,d1
      bra.s     vtc_bg
vtc_bg_b:
      moveq.l   #-1,d1
vtc_bg:
      move.b    d1,(a1)
      adda.w    a2,a1
      dbf       d0,vtc_bg
                  rts
vt_esc_s:
      cmpi.w    #'Y',d1
      beq       vt_seq_Y
      move.w    d1,d2
      movem.w   (V_CUR_XY).w,d0-d1
      movea.l   (V_CUR_AD).w,a1
      movea.w   (BYTES_LIN).w,a2
      move.l    #vt_con,(con_state).w
vt_seq_t:
      subi.w    #$0041,d2
      cmpi.w    #12,d2
      bhi.s     vt_seq_t2
      add.w     d2,d2
      move.w    vt_seq_tab1(pc,d2.w),d2
      jmp       vt_seq_tab1(pc,d2.w)
vt_seq_t2:
      subi.w    #33,d2
      cmpi.w    #21,d2
      bhi.s     vt_seq_error
      add.w     d2,d2
      move.w    vt_seq_tab2(pc,d2.w),d2
      jmp       vt_seq_tab2(pc,d2.w)
vt_seq_error:
                  rts
vt_seq_tab1:
   dc.w  vt_seq_A-vt_seq_tab1
   dc.w  vt_seq_B-vt_seq_tab1
   dc.w  vt_seq_C-vt_seq_tab1
   dc.w  vt_seq_D-vt_seq_tab1
   dc.w  vt_seq_E-vt_seq_tab1
   dc.w  vt_seq_error-vt_seq_tab1
   dc.w  vt_seq_error-vt_seq_tab1
   dc.w  vt_seq_H-vt_seq_tab1
   dc.w  vt_seq_I-vt_seq_tab1
   dc.w  vt_seq_J-vt_seq_tab1
   dc.w  v_eeol-vt_seq_tab1
   dc.w  vt_seq_L-vt_seq_tab1
   dc.w  vt_seq_M-vt_seq_tab1
vt_seq_tab2:
   dc.w  vt_seq_b-vt_seq_tab2
   dc.w  vt_seq_c-vt_seq_tab2
   dc.w  vt_seq_d-vt_seq_tab2
   dc.w  vt_seq_e-vt_seq_tab2
   dc.w  vt_seq_f-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_j-vt_seq_tab2
   dc.w  vt_seq_k-vt_seq_tab2
   dc.w  vt_seq_l-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_o-vt_seq_tab2
   dc.w  vt_seq_p-vt_seq_tab2
   dc.w  vt_seq_q-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_error-vt_seq_tab2
   dc.w  vt_seq_v-vt_seq_tab2
   dc.w  vt_seq_w-vt_seq_tab2

vt_seq_A:
v_curup:
      subq.w    #1,d1
      bra       set_curs1
vt_seq_B:
v_curdown:
      addq.w    #1,d1
      bra       set_curs1
vt_seq_C:
v_curright:
      addq.w    #1,d0
      bra       set_curs1
vt_seq_D:
v_curleft:
      subq.w    #1,d0
      bra       set_curs1
vt_seq_E:
      bsr       cursor_off
      bsr       clear_screen
      bra.s     vt_seq_H1
vt_seq_H:
v_curhome:
      bsr       cursor_off
vt_seq_H1:
      clr.l     (V_CUR_XY).w
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      move.l    a1,(V_CUR_AD).w
      bra       cursor_off2
vt_seq_I:
      pea.l     cursor_off2(pc)
      bsr       cursor_off
      subq.w    #1,d1
      blt       scroll_down
      suba.w    (V_CEL_WR).w,a1
      move.l    a1,(V_CUR_AD).w
      move.w    d1,(V_CUR_XY+2).w
                  rts
vt_seq_J:
v_eeos:
      bsr.s     vt_seq_K
      move.w    (V_CUR_XY+2).w,d1
      move.w    (V_CEL_MY).w,d2
      sub.w     d1,d2
      beq.s     vt_seq_J1
      movem.l   d2-d7/a1-a6,-(sp)
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      addq.w    #1,d1
      mulu.w    (V_CEL_WR).w,d1
      adda.l    d1,a1
      move.w    d2,d7
      mulu.w    (V_CEL_HT).w,d7
      subq.w    #1,d7
      bra       clear_line2 ; 99ee
vt_seq_J1:
                  rts
vt_seq_K:
v_eeol:
      bsr       cursor_off
      move.w    (V_CEL_MX).w,d2
      sub.w     d0,d2
      bsr       clear_line5 ; 9d50
      bra       cursor_off2
vt_seq_L:
      pea.l     cursor_off2(pc)
      bsr       cursor_off
      bsr       set_x0
      movem.l   d2-d7/a1-a6,-(sp)
      move.w    (V_CEL_MY).w,d7
      move.w    d7,d5
      sub.w     d1,d7
      beq.s     vt_seq_L1
      move.w    (V_CEL_WR).w,d6
      mulu.w    d6,d5
      movea.l   (v_bas_ad).w,a0
      adda.w    (V_CUR_OF).w,a0
      adda.l    d5,a0
      lea.l     0(a0,d6.w),a1
      mulu.w    d6,d7
      divu.w    #320,d7
      subq.w    #1,d7
      bsr       scroll_down1
vt_seq_L1:
      movea.l   (V_CUR_AD).w,a1
      bra       clear_line1 ; 99e8
vt_seq_M:
      pea.l     cursor_off2(pc)
      bsr       cursor_off
      bsr       set_x0
      movem.l   d2-d7/a1-a6,-(sp)
      move.w    (V_CEL_MY).w,d7
      sub.w     d1,d7
      beq       clear_line1 ; 99e8
      move.w    (V_CEL_WR).w,d6
      lea.l     0(a1,d6.w),a0
      mulu.w    d6,d7
      divu.w    #320,d7
      subq.w    #1,d7
      bra       scroll_up1
vt_seq_Y:
      move.l    #vt_set_y,(con_state).w
                  rts
vt_set_y:
      subi.w    #32,d1
      move.w    (V_CUR_XY).w,d0
      move.l    #vt_set_x,(con_state).w
      bra       set_curs1
vt_set_x:
      subi.w    #32,d1
      move.w    d1,d0
      move.w    (V_CUR_XY+2).w,d1
      move.l    #vt_con,(con_state).w
      bra       set_curs1
vt_seq_b:
      move.l    #vt_set_b,(con_state).w
                  rts
vt_set_b:
      moveq.l   #15,d0
      and.w     d0,d1
      cmp.w     d0,d1
      bne.s     vt_set_b1
      moveq.l   #-1,d1
vt_set_b1:
      move.w    d1,(V_COL_FG).w
      move.l    #vt_con,(con_state).w
                  rts
vt_seq_c:
      move.l    #vt_set_c,(con_state).w
                  rts
vt_set_c:
      moveq.l   #15,d0
      and.w     d0,d1
      cmp.w     d0,d1
      bne.s     vt_set_c1
      moveq.l   #-1,d1
vt_set_c1:
      move.w    d1,(V_COL_BG).w
      move.l    #vt_con,(con_state).w
                  rts
vt_seq_d:
      bsr.s     vt_seq_o
      move.w    (V_CUR_XY+2).w,d1
      beq.s     vt_seq_d1
      movem.l   d2-d7/a1-a6,-(sp)
      mulu.w    (V_CEL_HT).w,d1
      move.w    d1,d7
      subq.w    #1,d7
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      bra       clear_line2 ; 99ee
vt_seq_d1:
                  rts
vt_seq_e:
      tst.w     (V_HID_CNT).w
      beq.s     vt_seq_e1
      move.w    #1,(V_HID_CNT).w
      bra       cursor_off2
vt_seq_e1:
                  rts
vt_seq_f:
      bra       cursor_off
vt_seq_j:
      bset      #5,(V_STAT_0).w
      move.l    (V_CUR_XY).w,(V_SAV_XY).w
                  rts
vt_seq_k:
      movem.w   (V_SAV_XY).w,d0-d1
      bclr      #5,(V_STAT_0).w
      bne       set_curs1
      moveq.l   #0,d0
      moveq.l   #0,d1
      bra       set_curs1
vt_seq_l:
      bsr       cursor_off
      bsr       set_x0
      bsr       clear_line ; 99e4
      bra       cursor_off2
vt_seq_o:
      move.w    d0,d2
      subq.w    #1,d2
      bmi.s     vt_seq_o1
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      mulu.w    (V_CEL_WR).w,d1
      adda.l    d1,a1
      bra       clear_line5 ; 9d50
vt_seq_o1:
                  rts
vt_seq_p:
v_rvon:
      bset      #4,(V_STAT_0).w
                  rts
vt_seq_q:
v_rvoff:
      bclr      #4,(V_STAT_0).w
                  rts
vt_seq_v:
      bset      #3,(V_STAT_0).w
                  rts
vt_seq_w:
      bclr      #3,(V_STAT_0).w
                  rts
scroll_up:
      movem.l   d2-d7/a1-a6,-(sp)
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      movea.l   a1,a0
      move.w    (V_CEL_WR).w,d7
      adda.w    d7,a0
      mulu.w    (V_CEL_MY).w,d7
      divu.w    #320,d7
      subq.w    #1,d7
scroll_up1:
      pea.l     clear_line1(pc) ; 99e8
scroll_up2:
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,(a1)
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,40(a1)
      lea.l     80(a1),a1
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,(a1)
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,40(a1)
      lea.l     80(a1),a1
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,(a1)
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,40(a1)
      lea.l     80(a1),a1
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,(a1)
      movem.l   (a0)+,d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,40(a1)
      lea.l     80(a1),a1
      dbf       d7,scroll_up2
      swap      d7
      lsr.w     #1,d7
      dbf       d7,scroll_up3
                  rts
scroll_up3:
      move.w    (a0)+,(a1)+
      dbf       d7,scroll_up3
                  rts
scroll_down:
      movem.l   d2-d7/a1-a6,-(sp)
      movea.l   (v_bas_ad).w,a0
      adda.w    (V_CUR_OF).w,a0
      move.w    (V_CEL_WR).w,d6
      move.w    (V_CEL_MY).w,d7
      mulu.w    d6,d7
      lea.l     -40(a0,d7.l),a0
      lea.l     40(a0,d6.w),a1
      divu.w    #320,d7
      subq.w    #1,d7
      bsr.s     scroll_down2
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      bra.s     clear_line1 ; 99e8
scroll_down1:
      lea.l     -40(a0),a0
scroll_down2:
      movem.l   (a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      movem.l   -40(a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      lea.l     -80(a0),a0
      movem.l   (a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      movem.l   -40(a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      lea.l     -80(a0),a0
      movem.l   (a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      movem.l   -40(a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      lea.l     -80(a0),a0
      movem.l   (a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      movem.l   -40(a0),d2-d6/a2-a6
      movem.l   d2-d6/a2-a6,-(a1)
      lea.l     -80(a0),a0
      dbf       d7,scroll_down2
      swap      d7
      lea.l     40(a0),a0
      lsr.w     #1,d7
      dbf       d7,scroll_down3
                  rts
scroll_down3:
      move.w    -(a0),-(a1)
      dbf       d7,scroll_down3
                  rts
clear_line:
      movem.l   d2-d7/a1-a6,-(sp)
clear_line1:
      move.w    (V_CEL_HT).w,d7
      subq.w    #1,d7
clear_line2:
      move.w    (V_CEL_MX).w,d5
      addq.w    #1,d5
      move.w    (V_COL_BG).w,d6
      movea.w   (BYTES_LIN).w,a2
      move.w    (PLANES).w,d2
      cmp.w     #8,d2
      bgt       clear_line4 ; 9d0e
      add.w     d2,d2
      move.w    clear_tab(pc,d2.w),d2
      jmp       clear_tab(pc,d2.w)
clear_tab:
      dc.w clear_line3-clear_tab ; 9b6c
      dc.w clear_mo1-clear_tab
      dc.w clear_co1-clear_tab
      dc.w clear_line3-clear_tab ; 9b6c
      dc.w clear_co2-clear_tab
      dc.w clear_line3-clear_tab ; 9b6c
      dc.w clear_line3-clear_tab ; 9b6c
      dc.w clear_line3-clear_tab ; 9b6c
      dc.w clear_co3-clear_tab
clear_mo1:
      moveq.l   #0,d2
      lsr.w     #1,d6
      negx.l    d2
      suba.w    d5,a2
      subq.w    #4,d5
      lsr.w     #2,d5
      bcc.s     clear_mo2
      lea.l     clear_sc2(pc),a3
      move.w    d5,d6
      lsr.w     #7,d5
      not.w     d6
      and.w     #$007F,d6
      add.w     d6,d6
      lea.l     clear_sc3(pc,d6.w),a4
      move.w    d5,d6
      jmp       (a3)
clear_mo2:
      move.w    d5,d6
      lsr.w     #7,d5
      not.w     d6
      and.w     #$007F,d6
      add.w     d6,d6
      lea.l     clear_sc3(pc,d6.w),a3
clear_sc1:
      move.w    d5,d6
      jmp       (a3)
clear_sc2:
      move.w    d2,(a1)+
      jmp       (a4)
clear_sc3:
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      move.l    d2,(a1)+
      dbf       d6,clear_sc3
      adda.w    a2,a1
      dbf       d7,clear_sc1
clear_line3:
      movem.l   (sp)+,d2-d7/a1-a6
                  rts
clear_co1:
      add.w     d5,d5
      moveq.l   #0,d2
      lsr.w     #1,d6
      negx.w    d2
      swap      d2
      lsr.w     #1,d6
      negx.w    d2
clear_re1:
      move.l    d2,d3
clear_re2:
      move.l    d2,d4
      movea.l   d3,a4
clear_re3:
      suba.w    d5,a2
      subq.w    #1,d5
      lsr.w     #2,d5
      move.w    d5,d6
      lsr.w     #7,d5
      not.w     d6
      and.w     #$007F,d6
      add.w     d6,d6
      lea.l     clear_sc5(pc,d6.w),a3
clear_sc4:
      move.w    d5,d6
      jmp       (a3)
clear_sc5:
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      move.l    d2,(a1)+
      move.l    d3,(a1)+
      move.l    d4,(a1)+
      move.l    a4,(a1)+
      dbf       d6,clear_sc5
      adda.w    a2,a1
      dbf       d7,clear_sc4
      movem.l   (sp)+,d2-d7/a1-a6
                  rts
clear_co2:
      add.w     d5,d5
      add.w     d5,d5
      moveq.l   #0,d2
      moveq.l   #0,d3
      lsr.w     #1,d6
      negx.w    d2
      swap      d2
      lsr.w     #1,d6
      negx.w    d2
      lsr.w     #1,d6
      negx.w    d3
      swap      d3
      lsr.w     #1,d6
      negx.w    d3
      bra       clear_re2
clear_co3:
      moveq.l   #0,d2
      moveq.l   #0,d3
      moveq.l   #0,d4
      moveq.l   #0,d5
      lsr.w     #1,d6
      negx.w    d2
      swap      d2
      lsr.w     #1,d6
      negx.w    d2
      lsr.w     #1,d6
      negx.w    d3
      swap      d3
      lsr.w     #1,d6
      negx.w    d3
      lsr.w     #1,d6
      negx.w    d4
      swap      d4
      lsr.w     #1,d6
      negx.w    d4
      lsr.w     #1,d6
      negx.w    d5
      swap      d5
      lsr.w     #1,d6
      negx.w    d5
      movea.l   d5,a4
      move.w    (V_CEL_MX).w,d5
      addq.w    #1,d5
      lsl.w     #3,d5
      bra       clear_re3
clear_line4:
      addq.w    #1,d7
      mulu.w    (BYTES_LIN).w,d7
      lsr.l     #5,d7
      subq.l    #1,d7
      moveq.l   #-1,d6
clear_un:
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      move.l    d6,(a1)+
      subq.l    #1,d7
      bpl.s     clear_un
      movem.l   (sp)+,d2-d7/a1-a6
                  rts
clear_screen:
      movem.l   d2-d7/a1-a6,-(sp)
      move.w    (V_CEL_MY).w,d7
      addq.w    #1,d7
      mulu.w    (V_CEL_HT).w,d7
      subq.w    #1,d7
      movea.l   (v_bas_ad).w,a1
      adda.w    (V_CUR_OF).w,a1
      bra       clear_line2 ; 99ee
clear_line5:
      movem.l   d3-d6/a3-a4,-(sp)
      move.w    (V_COL_BG).w,d4
      move.w    (PLANES).w,d5
      move.w    d5,d6
      add.w     d5,d5
      subq.w    #1,d6
      movea.l   a1,a3
clear_lp1:
      move.w    d2,d3
      movea.l   a3,a0
      lea.l     vtc_bg_w(pc),a4
      lsr.w     #1,d4
      bcc.s     clear_lp2
      lea.l     vtc_bg_b(pc),a4
clear_lp2:
      movea.l   a0,a1
      move.w    (V_CEL_HT).w,d0
      subq.w    #1,d0
      jsr       (a4)
      addq.l    #1,a0
      move.l    a0,d1
      lsr.w     #1,d1
      bcs.s     clear_lp3
      subq.l    #2,a0
      adda.w    d5,a0
clear_lp3:
      dbf       d3,clear_lp2
      addq.l    #2,a3
      dbf       d6,clear_lp1
      movem.l   (sp)+,d3-d6/a3-a4
                  rts
opcode_err0:
      pea.l     vdi_exit(pc)
opcode_error:
      movea.l   d1,a1
      movea.l   (a1),a1
      move.w    (a1),d0
      clr.w     n_intout(a1)
      clr.w     n_ptsout(a1)
                  rts
handle_err:
      move.w    (a1),d0
      subq.w    #1,d0
      beq.s     handle_0
      subi.w    #99,d0
      beq.s     handle_0
      nop
handle_0:
      movea.l   (linea_wk_ptr).w,a6
      clr.w     handle(a1)
      moveq.l   #0,d0
      bra.s     handle_f
vdi_entry:
      movem.l   a0-a1/a6,-(sp)
      movea.l   d1,a0
      movea.l   (a0),a1
      move.w    handle(a1),d0
      beq.s     handle_err
      cmp.w     #MAX_HANDLES,d0
      bhi.s     handle_err
      subq.w    #1,d0
      add.w     d0,d0
      add.w     d0,d0
      lea.l     (wk_tab).w,a6
      movea.l   0(a6,d0.w),a6
      movea.l   disp_addr1(a6),a0
      jmp       (a0)
handle_f:
      movea.l   d1,a0
      movea.l   (a0),a1
      move.w    (a1),d0
      cmp.w     #131,d0
      bhi.s     opcode_err0
      cmp.w     #39,d0
      bhi.s     vdi_dispatch
      lsl.w     #3,d0
      lea.l     vdi_tab(pc,d0.w),a0
      bra.s     vdi_dispatch1
vdi_dispatch:
      sub.w     #100,d0
      bmi.s     opcode_err0
      lsl.w     #3,d0
      lea.l     vdi_tab1(pc),a0
      adda.w    d0,a0
vdi_dispatch1:
      move.w    (a0)+,n_ptsout(a1)
      move.w    (a0)+,n_intout(a1)
      movea.l   (a0),a1
      movea.l   d1,a0
      jsr       (a1)
vdi_exit:
      movem.l   (sp)+,a0-a1/a6
      moveq.l   #0,d0
                  rts
vdi_tab:
   dc.w  0,0
   dc.l  opcode_error
   dc.w  6,45
   dc.l  v_opnwk
   dc.w  0,0
   dc.l  v_clswk
   dc.w  0,0
   dc.l  v_clrwk
   dc.w  0,0
   dc.l  v_updwk
   dc.w  0,0
   dc.l  v_escape_call
   dc.w  0,0
   dc.l  v_pline
   dc.w  0,0
   dc.l  v_pmarker
   dc.w  0,0
   dc.l  v_gtext
   dc.w  0,0
   dc.l  v_fillarray
   dc.w  0,0
   dc.l  v_cellarray
   dc.w  0,0
   dc.l  v_gdp
   dc.w  2,0
   dc.l  vst_height
   dc.w  0,1
   dc.l  vst_rotation
   dc.w  0,0
   dc.l  vs_color
   dc.w  0,1
   dc.l  vsl_type
   dc.w  1,0
   dc.l  vsl_width
   dc.w  0,1
   dc.l  vsl_color
   dc.w  0,1
   dc.l  vsm_type
   dc.w  1,0
   dc.l  vsm_height
   dc.w  0,1
   dc.l  vsm_color
   dc.w  0,1
   dc.l  vst_font
   dc.w  0,1
   dc.l  vst_color
   dc.w  0,1
   dc.l  vsf_interior
   dc.w  0,1
   dc.l  vsf_style
   dc.w  0,1
   dc.l  vsf_color
   dc.w  0,4
   dc.l  vq_color
   dc.w  0,0
   dc.l  vq_cellarray
   dc.w  0,0
   dc.l  v_locator
   dc.w  0,2
   dc.l  v_valuator
   dc.w  0,1
   dc.l  v_choice
   dc.w  0,0
   dc.l  v_string
   dc.w  0,1
   dc.l  vswr_mode
   dc.w  0,1
   dc.l  vsin_mode
   dc.w  0,0
   dc.l  opcode_error
   dc.w  1,5
   dc.l  vql_attributes
   dc.w  1,3
   dc.l  vqm_attributes
   dc.w  0,5
   dc.l  vqf_attributes
   dc.w  2,6
   dc.l  vqt_attributes
   dc.w  0,2
   dc.l  vst_alignment
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
   dc.w  0,0
   dc.l  opcode_error
vdi_tab1:
   dc.w  6,45
   dc.l  v_opnvwk
   dc.w  0,0
   dc.l  v_clsvwk
   dc.w  6,45
   dc.l  vq_extnd
   dc.w  0,0
   dc.l  v_contour_fill
   dc.w  0,1
   dc.l  vsf_perimeter
   dc.w  0,2
   dc.l  v_get_pixel
   dc.w  0,1
   dc.l  vst_effects
   dc.w  2,1
   dc.l  vst_point
   dc.w  0,0
   dc.l  vsl_ends
   dc.w  0,0
   dc.l  vro_cpyfm
   dc.w  0,0
   dc.l  vr_trnfm
   dc.w  0,0
   dc.l  vsc_form
   dc.w  0,0
   dc.l  vsf_udpat
   dc.w  0,0
   dc.l  vsl_udstyle
   dc.w  0,0
   dc.l  vr_recfl
   dc.w  0,1
   dc.l  vqin_mode
   dc.w  4,0
   dc.l  vqt_extend
   dc.w  3,1
   dc.l  vqt_width
   dc.w  0,1
   dc.l  vex_timv
   dc.w  0,1
   dc.l  vst_load_fonts
   dc.w  0,0
   dc.l  vst_unload_fonts
   dc.w  0,0
   dc.l  vrt_cpyfm
   dc.w  0,0
   dc.l  v_show_c
   dc.w  0,0
   dc.l  v_hide_c
   dc.w  1,1
   dc.l  vq_mouse
   dc.w  0,0
   dc.l  vex_butv
   dc.w  0,0
   dc.l  vex_motv
   dc.w  0,0
   dc.l  vex_curv
   dc.w  0,1
   dc.l  vq_key_s
   dc.w  0,0
   dc.l  vs_clip
   dc.w  0,33
   dc.l  vqt_name
   dc.w  5,2
   dc.l  vqt_fontinfo


; end: 0000a24c


; 0000001c a V_LOCATO
; 0000001c a D_XMIN
; 0000001c a VBLVEC
; 0000001c a v_42
; 0000001c a os_conf
; 0000001e a METAFILE
; 0000001e a D_YMIN
; 0000001e a v_44
; 0000001f a N_META
; 00000020 a D_FORM
; 00000020 a V_PS_HAL
; 00000020 a GLOBAL_M
; 00000020 a sizeof_c
; 00000020 a sizeof_d
; 00000020 a v_46
; 00000022 a v_48
; 00000024 a VQ_TRAY_
; 00000024 a D_NXWD
; 00000024 a kbshift
; 00000024 a v_4a
; 00000025 a V_PAGE_S
; 00000026 a D_NXLN
; 00000028 a CAMERA
; 00000028 a run
; 00000028 a D_NXPL
; 00000028 a LAST_MB
; 0000002a a P_ADDR
; 0000002d a BIOSVEC
; 0000002e a P_NXLN
; 0000002e a XBIOSVEC
; 00000030 a SUPER_ME
; 00000030 a P_NXPL
; 00000032 a P_MASK
; 00000032 a TABLETT
; 0000003c a MEMORY
; 0000003d a N_MEMORY
; 0000003d a V_SOUND
; 00000040 a PRIVATER




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
