;VDI-Funktionsnummern
V_SET_APP_BUF       EQU -1
V_OPNWK             EQU 1
V_CLSWK             EQU 2
V_CLRWK             EQU 3
V_UPDWK             EQU 4
V_ESCAPE            equ 5
V_PLINE             EQU 6
V_GDP               EQU 11
VST_HEIGHT          EQU 12
VS_COLOR            EQU 14
VSL_TYPE            EQU 15
VSL_WIDTH           EQU 16
VSL_COLOR           EQU 17
VSM_TYPE            EQU 18
VSM_HEIGHT          EQU 19
VSM_COLOR           EQU 20
VST_FONT            EQU 21
VST_COLOR           EQU 22
VSF_INTERIOR        EQU 23
VSF_STYLE           EQU 24
VSF_COLOR           EQU 25
VQ_COLOR            EQU 26
V_LOCATOR           EQU 28
VQL_ATTRIBUTES      EQU 35
VQF_ATTRIBUTES      EQU 37
VST_ALIGNMENT       EQU 39
V_OPNVWK            EQU 100
V_CLSVWK            EQU 101
VQ_EXTND            EQU 102
V_CONTOURFILL       EQU 103
VSF_PERIMETER       EQU 104
V_GET_PIXEL         EQU 105
VSL_ENDS            EQU 108
VRO_CPYFM           EQU 109
VR_TRNFM            EQU 110
VSC_FORM            EQU 111
VSF_UDPAT           EQU 112
VSL_UDSTY           EQU 113
VR_RECFL            EQU 114
VST_LOAD_FONTS      EQU 119
VST_UNLOAD_FONTS    EQU 120
VRT_CPYFM           EQU 121
V_SHOW_C            EQU 122
V_HIDE_C            EQU 123
VQ_MOUSE            EQU 124
VEX_BUTV            EQU 125
VS_CLIP             EQU 129
VQT_FONTINFO        EQU 131
VQT_JUSTIFIED       EQU 132
VQT_CACHESIZE       EQU 255

;VDI-Unterfunktionsnummern
;GDP
V_BAR               EQU 1
V_ELLIPSE           EQU 5
V_ELLPIE            EQU 7
V_JUSTIFIED         EQU 10
V_BEZ_ONOFF         EQU 13

;Escapes
VQ_CHCELLS          EQU 1
V_CURTEXT           EQU 12
VQ_CURADDRESS       EQU 15
V_RMCUR             EQU 19
V_FORM_ADV          EQU 20
V_OUTPUT_WINDOW     EQU 21
V_CLEAR_DISP_LIST   EQU 22
V_BIT_IMAGE         EQU 23
VQ_SCAN             EQU 24
V_ALPHA_TEXT        EQU 25
V_ORIENT            EQU 27
V_PS_HALFTONE       EQU 32
VQ_TRAY_NAMES       EQU 36
V_PAGE_SIZE         EQU 37
VQ_PAGE_NAME        EQU 38
V_SOUND             EQU 61
VS_MUTE             EQU 62
VS_CALIBRATE        EQU 76
VQ_CALIBRATE        EQU 77
V_META_EXTENTS      EQU 98
V_BEZ_QUAL          EQU 99
VM_PAGESIZE         EQU 99
VM_COORDS           EQU 99
VM_FILENAME         EQU 100
V_OFFSET            EQU 101
V_FONTINIT          EQU 102
V_ESCAPE2000        EQU 2000

/* font header */
		OFFSET 0
font_id:        ds.w 1   /*  0 font id */
point:          ds.w 1   /*  2 height in points */
name:           ds.b 32  /*  4 font name */
first_ade:      ds.w 1   /* 36 first character */
last_ade:       ds.w 1   /* 38 last character */
top:            ds.w 1   /* 40 distance topline->baseline */
ascent:         ds.w 1   /* 42 distance ascentline->baseline */
half:           ds.w 1   /* 44 distance halfline->baseline */
descent:        ds.w 1   /* 46 distance descentline->baeline */
bottom:         ds.w 1   /* 48 distance bottomline->baseline */
max_char_width: ds.w 1   /* 50 largest character width */
max_cell_width: ds.w 1   /* 52 largest cell width */
left_offset:    ds.w 1   /* 54 left offset for italic */
right_offset:   ds.w 1   /* 56 right offset for italic */
thicken:        ds.w 1   /* 58 embolden factor */
ul_size:        ds.w 1   /* 60 height of underline */
lighten:        ds.w 1   /* 62 mask for light effect */
skew:           ds.w 1   /* 64 mask for italic effect */
flags:          ds.w 1   /* 66 flags */
hor_table:      ds.l 1   /* 68 offset/pointer to horizontal table */
off_table:      ds.l 1   /* 72 offset/pointer to character offset table */
dat_table:      ds.l 1   /* 76 offset/pointer to font image */
form_width:     ds.w 1   /* 80 width of font image in bytes */
form_height:    ds.w 1   /* 82 height of font image in pixel */
next_font:      ds.l 1   /* 84 pointer to next font */
sizeof_FONTHDR:          /* 88 */


;Bitnummern in flags
T_DEF_FONT_BIT      EQU 0                       ;Bitnummer fuer Defaultfont
T_HOT_BIT           EQU 1                       ;Bitnummer der HOT
T_SWAP_BIT          EQU 2                       ;Bitnummer des Bytetausch-Flags
T_MONO_BIT          EQU 3                       ;Bitnummer fuer aequidistante Fonts

/* MFDB */
		OFFSET 0
fd_addr:    ds.l 1   /* pointer to bitmap */
fd_w:       ds.w 1   /* width in pixel */
fd_h:       ds.w 1   /* height in pixel */
fd_wdwidth: ds.w 1   /* width in WORDs */
fd_stand:   ds.w 1   /* format */
fd_nplanes: ds.w 1   /* number of planes */
fd_r1:      ds.w 1   /* reserved */
fd_r2:      ds.w 1   /* reserved */
fd_r3:      ds.w 1   /* reserved */
sizeof_MFDB:


/* VDIPB */
		OFFSET 0
pb_control: ds.l 1
pb_intin:   ds.l 1
pb_ptsin:   ds.l 1
pb_intout:  ds.l 1
pb_ptsout:  ds.l 1
sizeof_PB:

/* VDI control */
		OFFSET 0
opcode:   ds.w 1
n_ptsin:  ds.w 1
n_ptsout: ds.w 1
n_intin:  ds.w 1
n_intout: ds.w 1
opcode2:  ds.w 1
handle:   ds.w 1
s_addr:   ds.l 1
d_addr:   ds.l 1
sizeof_contrl       EQU 32

;Linien
L_WIDTH_MIN         EQU 1                       ;minimale Linienbreite
L_WIDTH_MAX         EQU 99                      ;maximale Linienbreite
L_SOLID             EQU 1                       ;durchgehendes Linienmuster
L_USER_DEF          EQU 7                       ;benutzerdefiniertes Linienmuster
L_SQUARED           EQU 0                       ;eckiges Linienende
L_ARROW             EQU 1                       ;pfeilfoermiges Linienende
L_ROUNDED           EQU 2                       ;rundes Linienende

;Verknuepfungsmodi
REPLACE             EQU 1
TRANSPARENT         EQU 2
EX_OR               EQU 3
REV_TRANS           EQU 4

;Farben
WHITE               EQU 0                       ;Weiss
BLACK               EQU 1                       ;Schwarz

;Marker
M_DOT               EQU 1                       ;Punkt
M_ASTERISK          EQU 3                       ;Stern
M_DIAMOND           EQU 6                       ;Raute
M_WIDTH_MIN         EQU 1                       ;minimale Markerbreite
M_HEIGHT_MIN        EQU 1                       ;minimale Markerhoehe
M_WIDTH_MAX         EQU 1333                    ;maximale Markerbreite
M_HEIGHT_MAX        EQU 999                     ;maximale Markerhoehe

MARKER_COUNT        EQU 0
MARKER_ADDWIDTH     EQU 2
MARKER_OFFX         EQU 4
MARKER_OFFY         EQU 6

;Text
T_SYSTEM_FACE       EQU 1                       ;Systemzeichensatz

T_LEFT_ALIGN        EQU 0                       ;linksbuendige Ausrichtung
T_MID_ALIGN         EQU 1                       ;zentrierte Ausrichtung
T_RIGHT_ALIGN       EQU 2                       ;rechtsbuendige Ausrichtung

T_BASE_ALIGN        EQU 0                       ;Zeichenbasislinie
T_HALF_ALIGN        EQU 1                       ;Zeichenhalblinie
T_ASCENT_ALIGN      EQU 2                       ;Zeichenoberkante
T_BOTTOM_ALIGN      EQU 3                       ;Zellenunterkante
T_DESCENT_ALIGN     EQU 4                       ;Zeichenunterkante
T_TOP_ALIGN         EQU 5                       ;Zellenoberkante

T_BOLD              EQU 1                       ;Maske fuer fett
T_LIGHT             EQU 2                       ;Maske fuer hell
T_ITALICS           EQU 4                       ;Maske fuer kursiv
T_UNDERLINED        EQU 8                       ;Maske fuer unterstrichen
T_OUTLINED          EQU 16                      ;Maske fuer umrandet
T_BOLD_BIT          EQU 0                       ;Bitnummer fuer fett
T_LIGHT_BIT         EQU 1                       ;Bitnummer fuer hell
T_ITALICS_BIT       EQU 2                       ;Bitnummer fuer kursiv
T_UNDERLINED_BIT    EQU 3                       ;Bitnummer fuer unterstrichen
T_OUTLINED_BIT      EQU 4                       ;Bitnummer fuer umrandet

T_ROT_0 EQU 0
T_ROT_90 EQU 1
T_ROT_180 EQU 2
T_ROT_270 EQU 3

;Fuellmuster
F_HOLLOW            EQU 0                       ;hohl
F_SOLID             EQU 1                       ;durchgehend
F_PATTERN           EQU 2                       ;gemustert (Graustufen)
F_HATCH             EQU 3                       ;schraffiert
F_USER_DEF          EQU 4                       ;benutzerdefiniert

;Eingabegeraete
I_MOUSE             EQU 1                       ;Maus
I_CURSOR            EQU 2                       ;Cursortasten
I_FUNCTION_KEY      EQU 3                       ;Funktionstasten
I_KEYBOARD          EQU 4                       ;Tastatur allgemein
I_REQUEST           EQU 1                       ;Request-Eingabemodus
I_SAMPLE            EQU 2                       ;Sample-Eingabemodus

;Linie
SQUARE              EQU 0
ARROW               EQU 1
ROUND               EQU 2

;Treibernummen in driver_id (von 0 aus gezaehlt)
SCREEN              EQU 0                       ;Bildschirm-Treiber
SCREEN0             EQU 0
SCREEN9             EQU 9
PLOTTER             EQU 10                      ;Plotter-Treiber
PRINTER             EQU 20                      ;Drucker-Treiber
METAFILE            EQU 30                      ;Metafile-Treiber
CAMERA              EQU 40                      ;Kamera-Treiber
TABLETT             EQU 50                      ;Grafiktablett-Treiber
MEMORY              EQU 60                      ;Bitmap-Treiber


.OFFSET
                                        ;typedef struct
                                        ;{
XFI_size:           DS.L    1       ;   LONG    size;
XFI_format:         DS.W    1       ;   WORD    format;
XFI_id:             DS.W    1       ;   UWORD   id;
XFI_index:          DS.W    1       ;   WORD    index;
XFI_font_name:      DS.B    50      ;   BYTE    font_name[50];
XFI_family_name:    DS.B    50      ;   BYTE    family_name[50];
XFI_style_name:     DS.B    50      ;   BYTE    style_name[50];
XFI_file_name1:     DS.B    200 ;   BYTE    file_name1[200];
XFI_file_name2:     DS.B    200 ;   BYTE    file_name2[200];
XFI_file_name3:     DS.B    200 ;   BYTE    file_name3[200];
XFI_pt_cnt:         DS.W    1       ;   WORD    pt_cnt;
XFI_pt_sizes:       DS.W    64      ;   WORD    pt_sizes[64];
                                        ;} XFNT_INFO;

sizeof_XFNT_INFO:
