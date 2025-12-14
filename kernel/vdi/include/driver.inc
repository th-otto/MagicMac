;Die Offsets der nvdi_struct
_nvdi_id                EQU -4                  ;.l zu schreibende Kennung
_nvdi_version           EQU 0                   ;.w Versionsnummer im BDC-Format
_nvdi_datum             EQU 2                   ;.l Datum
_nvdi_conf              EQU 6                   ;.w Konfigurationswort
_nvdi_aes_wk            EQU 8                   ;.l Zeiger auf die AES-Workstation
_nvdi_fills             EQU 12                  ;.l Zeiger auf die Fuellmuster des Bildschirmtreibers
_nvdi_wks               EQU 16                  ;.l Zeiger auf Workstationtabelle
_nvdi_path              EQU 20                  ;.l Zeiger auf den GDOS-Pfad
_nvdi_drivers           EQU 24                  ;.l Zeiger auf die Treibertabelle
_nvdi_fonts             EQU 28                  ;.l Zeiger auf die Bitmap-Fonttabelle

_nvdi_fonthdr           EQU 32                  ;.l Zeiger auf den ersten Systemfontheader
_nvdi_sys_font_info     EQU 36                  ;.l Zeiger auf Informationen ueber den Systemzeichensatz
_nvdi_colmaptab         EQU 40                  ;.l Zeiger auf Standard-Farbzuordnungen
_nvdi_opnwk_work_out    EQU 44                  ;.l Zeiger auf die Standard-Ausgaben fuer v_opnwk/v_opnvwk/v_opnbm
_nvdi_extnd_work_out    EQU 48                  ;.l Zeiger auf die Standard-Ausgaben fuer vq_extnd
_nvdi_no_wks            EQU 52                  ;.w Maximale Anzahl der Workstations
_nvdi_max_vdi           EQU 54                  ;.w hoechste VDI-Funktionsnummer
_nvdi_status            EQU 56                  ;.w Statuswort
;58.w
_nvdi_vdi_tab           EQU 60                  ;.l Zeiger auf die VDI-Funktionstabelle
_nvdi_linea_tab         EQU 64                  ;.l Zeiger auf die LineA-Funktionstabelle
_nvdi_gemdos_tab        EQU 68                  ;.l Zeiger auf den GEMDOS-Vektor
_nvdi_bios_tab          EQU 72                  ;.l Zeiger auf die Bconout-Tabelle
_nvdi_xbios_tab         EQU 76                  ;.l Zeiger auf den XBIOS-Vektor
_nvdi_mouse_tab         EQU 80                  ;.l Zeiger auf Mausroutinen-Tabelle
_nvdi_blitter           EQU 86                  ;.w Blitterstatus
_nvdi_modecode          EQU 88                  ;.w Falcon-Modus
_nvdi_xbios_res         EQU 90                  ;.w Xbios-Aufloesung + 1
_nvdi_cookie_CPU        EQU 92                  ;.l
_nvdi_cookie_VDO        EQU 96                  ;.l
_nvdi_cookie_MCH        EQU 100                 ;.l
_nvdi_first_device      EQU 104                 ;.w
_nvdi_cpu020            EQU 106                 ;.w
_nvdi_magix             EQU 108                 ;.w
_nvdi_mint              EQU 110                 ;.w
_nvdi_search_cookie     EQU 112
_nvdi_init_cookie       EQU 116
_nvdi_reset_cookie      EQU 120
_nvdi_init_virtual_vbl  EQU 124
_nvdi_reset_virtual_vbl EQU 128
_nvdi_Malloc_sys        EQU 132
_nvdi_Mfree_sys         EQU 136
_nvdi_nmalloc           EQU 140
_nvdi_nmfree            EQU 144
_nvdi_load_file         EQU 148
_nvdi_load_prg          EQU 152
_nvdi_load_NOD_driver   EQU 156
_nvdi_unload_NOD_driver EQU 160
_nvdi_init_NOD_drivers  EQU 164
_nvdi_id_to_font_file   EQU 168
_nvdi_set_FONT_pathes   EQU 172
_nvdi_get_FONT_path     EQU 176
_nvdi_set_caches        EQU 180
_nvdi_get_caches        EQU 184
_nvdi_get_FIF_path      EQU 188
_nvdi_get_INF_name      EQU 192
_nvdi_vdi_setup_ptr     EQU 196
_nvdi_vdi_exit          EQU 200
/* below only present in NVDI 5.x */
_nvdi_create_ctab       EQU 300
_nvdi_create_itab       EQU 304
_nvdi_color2pixel       EQU 308
_nvdi_color2value       EQU 312

_sf_no_font_hdr     EQU 0                   ;Anzahl der Systemfontheader
_sf_font_hdr_ptr    EQU 2                   ;Adresse der hintereinanderliegenden Systemfont-Header
_sf_font_addr       EQU 6                   ;Adresse des Bitimage des 8*16 Systemfonts
_sf_image           EQU 10                  ;Zeiger auf das umsortierte Bitimage des 8*16 Systemfonts   
_sf_bold_image      EQU 14                  ;Zeiger auf das umsortierte fette Bitimage des 8*16 Systemfonts

/* device driver (DEVICE_DRIVER) */
                 OFFSET 0
driver_name:     ds.b 9                 ;unsigned char [9]  Name
driver_status:   ds.b 1                 ;unsigned char    Status
driver_use:      ds.w 1                 ;unsigned int         Semaphore
driver_addr:     ds.l 1                 ;void *    Adresse
driver_wk_len:   ds.l 1                 ;Laenge der Treiberworkstation
driver_offscreen:ds.l 1                 ;Adresse der DRIVER-Strukur des Offscreen-Treibers
driver_open_hdl: ds.w 1                 ;Handle, mit dem der Treiber geoeffnet wurde
                 ds.w 3
sizeof_driver:

;Defines fuer driver_status
DRIVER_DYNAMIC      EQU 1                   ;Treiber dynamisch verwalten
DRIVER_RESIDENT     EQU 2                   ;Treiber resident verwalten
DRIVER_NVDI         EQU 3                   ;NVDI-Bildschirmtreiber
DRIVER_AVDI         EQU 4                   ;ATARI-VDI


                                        ;typedef struct
                                        ;{
                        OFFSET 0
ORGANISATION_colors:    DS.L    1   ;   LONG    colors;
ORGANISATION_planes:    DS.W    1   ;   WORD    planes;
ORGANISATION_format:    DS.W    1   ;   WORD    format;
ORGANISATION_flags:     DS.W    1   ;   WORD    flags;
ORGANISATION_reser:     DS.W    3   ;   WORD    reserved[3];            /* reserviert */
                                        ;} ORGANISATION;
sizeof_ORGANISATION:


                                        ;typedef struct DRIVER_tag
                                        ;{
                        OFFSET 0
DRIVER_next:            DS.L    1   ;   struct DRIVER_tag   *next;
    
DRIVER_code:            DS.L    1   ;   DRVR_HEADER *code;
DRIVER_wk_len:          DS.L    1   ;   LONG    wk_len;
DRIVER_used:            DS.W    1   ;   WORD    used;

DRIVER_info:            DS.B    sizeof_ORGANISATION ;   ORGANISATION    info;

DRIVER_file_name:       DS.B    16  ;   BYTE    file_name[16];
DRIVER_file_size:       DS.L    1   ;   ULONG   file_size;
DRIVER_file_path:       DS.L    1   ;   BYTE    *file_path;
sizeof_DRIVER:                      ;} DRIVER;

;Offsets innerhalb von gemdos_tab
_call_old_gemdos    EQU 0                       ;Zeiger auf Routine, die zum GEMDOS springt
_gemdos_vec         EQU 4                       ;Zeiger auf NVDI-GEMDOS-Routinen

;Offsets innerhalb von bconout_tab
_cursor_cnt_vec     EQU 0                       ;Zeiger auf cursor_cnt
_cursor_vbl_vec     EQU 4                       ;Zeiger auf die Cursor-Routine im VBL
_vt52_vec_vec       EQU 8                       ;Zeiger auf bconout_vec
_con_vec            EQU 12                      ;Vektor fuer Bios-Ausgabe ueber CON
_rawcon_vec         EQU 16                      ;Vektor fuer Bios-Ausgabe ueber RAWCON

;Offsets innerhalb von xbios_tab
_call_old_xbios     EQU 0                       ;Zeiger auf Routine, die zum XBIOS springt
_xbios_vec          EQU 4                       ;Zeiger auf NVDI-XBIOS-Routinen

;Offsets innerhalb von color_map_tab
_color_map_ptr      EQU 0
_color_remap_ptr    EQU 4

;Offsets innerhalb von mouse_tab
_mouse_buffer       EQU 0                       ;Zeiger auf den Hintergrundbuffer
_draw_spr_vec       EQU 4                       ;Vektor fuer DRAW SPRITE
_undraw_spr_vec     EQU 8                       ;Vektor fuer UNDRAW SPRITE

N_OFFSCREEN         EQU 0
N_SCREEN            EQU 1
N_PLOTTER           EQU 11
N_PRINTER           EQU 21
N_META              EQU 31
N_MEMORY            EQU 61
N_IMAGE             EQU 91

/* driver file header (DRVR_HEADER) */
                  OFFSET 0
DRVR_branch:      ds.w 1
DRVR_magic:       ds.b 8
DRVR_version:     ds.w 1
DRVR_headersize:  ds.w 1
DRVR_type:        ds.w 1
DRVR_init:        ds.l 1
DRVR_reset:       ds.l 1
DRVR_wk_init:     ds.l 1
DRVR_wk_reset:    ds.l 1
DRVR_opnwkinfo:   ds.l 1
DRVR_extndinfo:   ds.l 1
DRVR_scrninfo:    ds.l 1
DRVR_name:        ds.l 1
DRVR_res2:        ds.l 4
DRVR_colors:      ds.l 1
DRVR_planes:      ds.w 1
DRVR_format:      ds.w 1
DRVR_flags:       ds.w 1
DRVR_res00:       ds.w 1
DRVR_res01:       ds.w 1
DRVR_res02:       ds.w 1

;Struktur fuer Bitmap-Fonts
                    OFFSET 0
font_name:          ds.b 9                      ;unsigned char [9]  Name
font_status:        ds.b 1                      ;unsigned char Status
font_use:           ds.w 1                      ;unsigned int Semaphore
font_addr:          ds.l 1                      ;unsigned long Adresse
sizeof_BM_FONT:

;Defines fuer font_status
FONT_DYNAMIC        EQU 1                       ;Font dynamisch verwalten
FONT_RESIDENT       EQU 2                       ;Font resident verwalten
FONT_SYSTEM         EQU 3                       ;Font als Systemfont verwalten

; COLOR_TAB
                    OFFSET 0
ctab_magic:         ds.l 1
ctab_length:        ds.l 1
ctab_format:        ds.l 1
                    ds.l 1 ; reserved
ctab_map_id:        ds.l 1
ctab_color_space:   ds.l 1
ctab_flags:         ds.l 1
ctab_no_colors:     ds.l 1
                    ds.l 4 ; reserved
ctab_colors:
