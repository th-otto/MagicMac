**********************************************************************
*
* INCLUDES fuer Mag!X- AES
*
**********************************************************************


     INCLUDE "kernel.inc"
     INCLUDE "dos.inc"
	include "country.inc"


MACOS_SUPPORT  EQU  1
NEU_SUBMEN     EQU  1
SUBMEN         EQU  1
N_WINOBJS EQU  16             ; Anzahl der Objekte

__a_aes   EQU  $3300

* AES fuer MagiX


OUTSIDE   EQU  1
NVDI      EQU  1                   ; NVDI- Unterstuetzung
MAXDEPTH  EQU  8
NAPPS     EQU  126                 ; Gesamtanzahl der Applikationen
NACCS     EQU  6                   ; Gesamtanzahl der ACCs (menuregs)
NPOPAPPS  EQU  16                  ; Anzahl APPs im Popup
MIN_NWIND EQU  16                  ; Gesamtanzahl der Windows einschl. 0
MAX_NWIND EQU  64
SHLBFLEN  EQU  8192                ; Mindestlaenge des shel_put/get Puffers
RNGBFLEN  EQU  32                  ; Laenge des Interrupt- Ringpuffers

XE_INVWHDL     EQU  -1             ; Fenster nicht offen bzw. nicht existent
XE_OTHWHDL     EQU  -2             ; Fenster gehoert anderer Applikation

* Listbox

LBOX_CNT_ITEMS      EQU  0
LBOX_GET_TREE       EQU  1
LBOX_FREE_ITEMS     EQU  2
LBOX_GET_UDATA      EQU  3
LBOX_GET_AFIRST     EQU  4
LBOX_GET_SLCT_IDX   EQU  5
LBOX_GET_ITEMS      EQU  6
LBOX_GET_ITEM       EQU  7
LBOX_GET_SLCT_ITEM  EQU  8
LBOX_GET_IDX        EQU  9
LBOX_GET_BVIS       EQU  10
LBOX_GET_BENTRS     EQU  11
LBOX_GET_BFIRST     EQU  12

LBOX_SET_ASLDR      EQU  0
LBOX_SET_ITEMS      EQU  1
LBOX_FREE_LIST      EQU  3
LBOX_ASCROLL_TO     EQU  4
LBOX_SET_BSLIDER    EQU  5
LBOX_SET_BENTRS     EQU  6
LBOX_BSCROLL_TO     EQU  7

* WORKSTATION- Tabelle fuer NVDI:

NVDI_device_id      EQU 10         ;Geraetenummer - 1
NVDI_colors         EQU 20
NVDI_wr_mode        EQU 60         ;Grafikmodus - 1 (!!!!!!!!!!)

;Begrenzung der Grafikkommandos
NVDI_clip_flag      EQU 50         ;Flag fuer Clipping
NVDI_clip_xmin      EQU 52         ;Minimum - x
NVDI_clip_ymin      EQU 54         ;Minimum - y
NVDI_clip_xmax      EQU 56         ;Maximum - x
NVDI_clip_ymax      EQU 58         ;Maximum - y

;Textdarstellung
NVDI_t_color        EQU 100        ;Textfarbe

;Liniendarstellung
NVDI_l_color        EQU 70         ;Linienfarbe
NVDI_l_width        EQU 72         ;Linienbreite
NVDI_l_start        EQU 74         ;Linienanfang
NVDI_l_end          EQU 76         ;Linienende
NVDI_l_lastpix      EQU 78         ;1 = letzten Punkt nicht setzen
NVDI_l_style        EQU 80         ;Linienstil
NVDI_l_styles       EQU 82         ;Linienmuster
NVDI_l_sdstyle      EQU 94         ;selbstdefinierter Linienstil

;Musterdarstellung
NVDI_f_color        EQU 190        ;Fuellfarbe
NVDI_f_interior     EQU 192        ;Fuelltyp
NVDI_f_style        EQU 194        ;Musterindex
NVDI_f_pointer      EQU 198        ;Zeiger aufs aktuelle Fuellmuster

;negative LineA
V_CUR_AD            EQU  -$22      ; Cursoradresse ??!!??
V_CUR_XY            EQU  -$1c      ; int[2], Cursorposition

;Tastatur

K_CTRL              EQU  4         ; Bit 2
K_ALT               EQU  8         ; Bit 3

* OBJECT

ob_next   EQU  0
ob_head   EQU  2
ob_tail   EQU  4
ob_type   EQU  6
ob_flags  EQU  8
ob_state  EQU  $a
ob_spec   EQU  $c
ob_x      EQU  $10
ob_y      EQU  $12
ob_width  EQU  $14
ob_height EQU  $16

* TEDINFO

     OFFSET

te_ptext:      DS.L 1              ; 0
te_ptmplt:     DS.L 1              ; 4
te_pvalid:     DS.L 1              ; 8
te_font:       DS.W 1              ; $c
te_resvd1:     DS.W 1
te_just:       DS.W 1              ; $10
te_color:      DS.W 1              ; $12
te_resvd2:     DS.W 1
te_thickness:  DS.W 1              ; $16
te_txtlen:     DS.W 1              ; $18
te_tmplen:     DS.W 1              ; $1a
te_sizeof:

* ICONBLK
     OFFSET
ib_pmask:      DS.L 1
ib_pdata:      DS.L 1
ib_ptext:      DS.L 1
ib_char:       DS.W 1
ib_xchar:      DS.W 1
ib_ychar:      DS.W 1
ib_xicon:      DS.W 1
ib_yicon:      DS.W 1
ib_wicon:      DS.W 1
ib_hicon:      DS.W 1
ib_xtext:      DS.W 1
ib_ytext:      DS.W 1
ib_wtext:      DS.W 1
ib_htext:      DS.W 1
ib_sizeof:
cib_mainlist:  DS.L 1         ; CICON *mainlist;
cib_sizeof:

     TEXT

* CICON
     OFFSET
ci_num_planes: DS.W 1
ci_col_data:   DS.L 1
ci_col_mask:   DS.L 1
ci_sel_data:   DS.L 1
ci_sel_mask:   DS.L 1
ci_next_res:   DS.L 1
ci_sizeof:
     TEXT

* BITBLK

bi_pdata       EQU  0
bi_wb          EQU  4
bi_hl          EQU  6
bi_x           EQU  8
bi_y           EQU  $a
bi_color       EQU  $c

* MFDB

fd_addr        EQU  0
fd_w           EQU  4
fd_h           EQU  6
fd_wdwidth     EQU  8
fd_stand       EQU  10
fd_nplanes     EQU  12
fd_sizeof      EQU  20


     OFFSET

rsh_vrsn:      DS.W 1
rsh_object:    DS.W 1
rsh_tedinfo:   DS.W 1
rsh_iconblk:   DS.W 1
rsh_bitblk:    DS.W 1
rsh_frstr:     DS.W 1
rsh_string:    DS.W 1
rsh_imdata:    DS.W 1
rsh_frimg:     DS.W 1
rsh_trindex:   DS.W 1
rsh_nobs:      DS.W 1
rsh_ntree:     DS.W 1
rsh_nted:      DS.W 1
rsh_nib:       DS.W 1
rsh_nbb:       DS.W 1
rsh_nstring:   DS.W 1
rsh_nimages:   DS.W 1
rsh_rssize:    DS.W 1
rsh_sizeof:

     OFFSET

w_state:       DS.W 1
w_attr:        DS.W 1
w_owner:       DS.L 1
w_kind:        DS.W 1
w_name:        DS.L 1
w_info:        DS.L 1
w_curr:        DS.W 4
w_prev:        DS.W 4
w_full:        DS.W 4
w_work:        DS.W 4
w_overall:     DS.W 4              /* w_curr+Schatten */
w_unic:        DS.W 4
w_min_g:       DS.W 4              ; Minimalgroesse
w_oldheight:   DS.W 1
w_hslide:      DS.W 1
w_vslide:      DS.W 1
w_hslsize:     DS.W 1
w_vslsize:     DS.W 1
w_wg:          DS.L 1
w_nextwg:      DS.L 1
w_whdl:        DS.W 1
w_tree:        DS.B N_WINOBJS*24
w_ted1:        DS.B te_sizeof      ; TEDINFO fuer NAME
w_ted2:        DS.B te_sizeof      ; TEDINFO fuer INFO
w_sizeof:

     OFFSET

fontID:        DS.W 1              /* Font-ID (Default ist 1)              */
fontH:         DS.W 1              /* Netto-Zeichenhoehe fuer vst_height     */
fontmono:      DS.W 1              /* Flag fuer "monospaced"                */
fontcharW:     DS.W 1              /* Zeichenbreite bei mono               */
fontcharH:     DS.W 1              /* Zeichenhoehe (brutto)                 */
fontUpos:      DS.W 1              /* Position des Unterstrichs            */
finfo_sizeof:

     OFFSET

wg_nextwg:     DS.L 1
wg_grect:      DS.W 4
wg_sizeof:


; fuer menu_attach:

     OFFSET

atpop_tree:    DS.L 1         ; Objektbaum des Popups
atpop_menu:    DS.W 1         ; Objekt, das die Menueeintraege enthaelt
atpop_item:    DS.W 1         ; erster Menueeintrag
atpop_scroll:  DS.W 1         ; 0 bzw. Objekt, ab dem das Menue scrollt
atpop_refcnt:  DS.W 1         ; Referenzzaehler fuer Popup-Liste
atpop_sizeof:

; fuer menu_settings:

     OFFSET

mns_Display:   DS.L 1
mns_Drag:      DS.L 1
mns_Delay:     DS.L 1
mns_Speed:     DS.L 1
mns_Height:    DS.W 1
mns_sizeof:

     TEXT


g_x            EQU  0
g_y            EQU  2
g_w            EQU  4
g_h            EQU  6
g_sizeof       EQU  8


/* wind_create: Fensterelemente */

NAME           EQU  $0001
NAME_B         EQU  0
CLOSER         EQU  $0002
CLOSER_B       EQU  1
FULLER         EQU  $0004
FULLER_B       EQU  2
MOVER          EQU  $0008
MOVER_B        EQU  3
INFO           EQU  $0010
INFO_B         EQU  4
SIZER          EQU  $0020
SIZER_B        EQU  5
UPARROW        EQU  $0040
UPARROW_B      EQU  6
DNARROW        EQU  $0080
DNARROW_B      EQU  7
VSLIDE         EQU  $0100
VSLIDE_B       EQU  8
LFARROW        EQU  $0200
LFARROW_B      EQU  9
RTARROW        EQU  $0400
RTARROW_B      EQU  10
HSLIDE         EQU  $0800
HSLIDE_B       EQU  11
HOTCLOSEBOX    EQU  $1000                              /* GEM 2.x     */
BACKDROP       EQU  $2000                              /* KAOS 1.4    */
ICONIFIER      EQU  $4000                              /* AES 4.1     */
ICONIFIER_B    EQU  14

/* w_state */

WSTAT_OPENED_B      EQU  0              /* Fenster geoeffnet */
WSTAT_COVERED_B     EQU  1              /* Fenster ueberdeckt */
WSTAT_ACTIVE        EQU  4              /* Fenster aktiv */
WSTAT_ACTIVE_B      EQU  2
WSTAT_LOCKED_B      EQU  3              /* gegen Schliessen gesperrt */
WSTAT_QUIET_B       EQU  4              /* (intern verwendet) */
WSTAT_ICONIFIED     EQU  32             /* ikonifiziert */
WSTAT_ICONIFIED_B   EQU  5
WSTAT_SHADED        EQU  64             /* shaded */
WSTAT_SHADED_B      EQU  6

/* w_attr */

WATTR_BEVENT_B      EQU  0              /* Hintergrundbedienung */
WATTR_INFOEVENT_B   EQU  1              /* Message bei Klick auf INFO-Box */

/* wind_set(WF_DCOLOR) */

W_FULLER       EQU  4

/* wind_set/wind_get */

WF_KIND        EQU  1
WF_NAME        EQU  2
WF_INFO        EQU  3
WF_WORKXYWH    EQU  4
WF_CURRXYWH    EQU  5
WF_PREVXYWH    EQU  6
WF_FULLXYWH    EQU  7
WF_HSLIDE      EQU  8
WF_VSLIDE      EQU  9
WF_TOP         EQU  10
WF_FIRSTXYWH   EQU  11
WF_NEXTXYWH    EQU  12
WF_RESVD       EQU  13
WF_NEWDESK     EQU  14
WF_HSLSIZE     EQU  15
WF_VSLSIZE     EQU  16
WF_SCREEN      EQU  17
WF_COLOR       EQU  18
WF_DCOLOR      EQU  19
WF_OWNER       EQU  20
WF_BEVENT      EQU  24
WF_BOTTOM      EQU  25
WF_ICONIFY     EQU  26        ; AES 4.1
WF_UNICONIFY   EQU  27        ; AES 4.1
WF_UNICONIFYXYWH EQU 28       ; AES 4.1
;WF_TOOLBAR    EQU  30        ; AES 4.1
;WF_FTOOLBAR   EQU  31        ; AES 4.1
;WF_NTOOLBAR   EQU  32        ; AES 4.1
WF_M_BACKDROP  EQU  100
WF_M_OWNER     EQU  101
WF_M_WINDLIST  EQU  102
WF_MINXYWH     EQU  103       ; MagiC 6
WF_INFOXYWH    EQU  104       ; MagiC 6.10
WF_SHADE       EQU  $575d     ; WINX 2.3
WF_STACK       EQU  $575e     ; WINX 2.3
WF_TOPALL      EQU  $575f     ; WINX 2.3
WF_BOTTOMALL   EQU  $5760     ; WINX 2.3

/* Messages */

MN_SELECTED    EQU  10
WM_REDRAW      EQU  20
WM_TOPPED      EQU  21
WM_CLOSED      EQU  22
WM_FULLED      EQU  23
WM_ARROWED     EQU  24
WM_HSLID       EQU  25
WM_VSLID       EQU  26
WM_SIZED       EQU  27
WM_MOVED       EQU  28
WM_NEWTOP      EQU  29
WM_UNTOPPED    EQU  30
WM_ONTOP       EQU  31
;WM_BACKDROPPED EQU  31            ; inkompatibel und ueberholt
;SM_SPECIAL     EQU  32            ; ueberholt
WM_BOTTOMED    EQU  33             ; AES 4.1
WM_ICONIFY     EQU  34             ; AES 4.1
WM_UNICONIFY   EQU  35             ; AES 4.1
WM_ALLICONIFY  EQU  36             ; AES 4.1
;WM_TOOLBAR    EQU  37             ; AES 4.1
AC_OPEN        EQU  40
AC_CLOSE       EQU  41
AP_TERM        EQU  50             ; AES 4.0
AP_TFAIL       EQU  51             ; AES 4.0
AP_RESCHG      EQU  57             ; AES 4.0
SHUT_COMPLETED EQU  60             ; AES 4.0
RESCH_COMPLETED EQU 61             ; AES 4.0
AP_DRAGDROP    EQU  63
SH_WDRAW       EQU  72
SC_CHANGED     EQU  80             ; (hier nicht benutzt, aber merken!)
PRN_CHANGED    EQU  82             ; (hier nicht benutzt, aber merken!)
FNT_CHANGED    EQU  83             ; (hier nicht benutzt, aber merken!)
THR_EXIT       EQU  88             ; MagiC 4.5
PA_EXIT        EQU  89             ; MagiC 3
CH_EXIT        EQU  90             ; laut Doku 80, aber MultiTOS hat 90
;WM_M_BDROPPED EQU  100            ; ueberholt (=> WM_BOTTOMED)
SM_M_SPECIAL   EQU  101            ; Meldung an SCRENMGR
WM_SHADED      EQU  $5758          ; WINX 2.3x
WM_UNSHADED    EQU  $5759          ; WINX 2.3x

/* SRENMGR messages */

SMC_TERMINATE  EQU  1

/* shel_write "doex" modes */

SHW_NOEXEC     EQU  0
SHW_EXEC       EQU  1
SHW_EXEC_ACC   EQU  3              ; MagiC 3 seit 15.9.95
SHW_SHUTDOWN   EQU  4
SHW_RESCHNG    EQU  5
SHW_BROADCAST  EQU  7
SHW_INFRECGN   EQU  9
SHW_AESSEND    EQU  10
; ab 29.2.96:
SHW_THR_CREATE EQU  20
SHW_THR_EXIT   EQU  21
SHW_THR_KILL   EQU  22

/* Schreibmodi */

REPLACE        EQU  1
TRANSPARENT    EQU  2
XOR            EQU  3

/* Farben */

WHITE          EQU  0
BLACK          EQU  1
RED            EQU  2
GREEN          EQU  3
BLUE           EQU  4
CYAN           EQU  5
YELLOW         EQU  6
MAGENTA        EQU  7
LWHITE         EQU  8              ; hellgrau
LBLACK         EQU  9              ; dunkelgrau
LRED           EQU 10
LGREEN         EQU 11
LBLUE          EQU 12
LCYAN          EQU 13
LYELLOW        EQU 14
LMAGENTA       EQU 15

/* Muster */

IP_HOLLOW      EQU  0
IP_1PATT       EQU  1
IP_2PATT       EQU  2
IP_3PATT       EQU  3
IP_4PATT       EQU  4
IP_5PATT       EQU  5
IP_6PATT       EQU  6
IP_SOLID       EQU  7

/* Bitblt modi */

ALL_WHITE      EQU  0
S_AND_D        EQU  1
S_AND_NOTD     EQU  2
S_ONLY         EQU  3
NOTS_AND_D     EQU  4
D_ONLY         EQU  5
S_XOR_D        EQU  6
S_OR_D         EQU  7
NOT_SORD       EQU  8
NOT_SXORD      EQU  9
D_INVERT       EQU  10
NOT_D          EQU  11
S_OR_NOTD      EQU  12
NOTS_OR_D      EQU  13
NOT_SANDD      EQU  14
ALL_BLACK      EQU  15

/* Objekttypen */

NOBTYPES       EQU  19             ; Anzahl versch. Objekttypen
G_BOX          EQU  20
G_TEXT         EQU  21
G_BOXTEXT      EQU  22
G_IMAGE        EQU  23
G_USERDEF      EQU  24
G_IBOX         EQU  25
G_BUTTON       EQU  26
G_BOXCHAR      EQU  27
G_STRING       EQU  28
G_FTEXT        EQU  29
G_FBOXTEXT     EQU  30
G_ICON         EQU  31
G_TITLE        EQU  32
G_CICON        EQU  33             ; (Sicherheitsabstand)
G_SWBUTTON     EQU  34             ; Switchbutton
G_POPUP        EQU  35             ; Popup- Menue
G_WINTITLE     EQU  36             ; Fenstertitel
G_EDIT         EQU  37             ; MagiC 5.20: Editor
G_SHORTCUT     EQU  38             ; G_STRING mit Tastatur-Shortcut

; ob_flags

SELECTABLE     EQU  1              ; Bit 0
DEFAULT        EQU  2              ; Bit 1
EXIT           EQU  4              ; Bit 2
EXIT_B         EQU  2
EDITABLE       EQU  8              ; Bit 3
RBUTTON        EQU  16             ; Bit 4
RBUTTON_B      EQU  4
LASTOB         EQU  32             ; Bit 5
TOUCHEXIT      EQU  64             ; Bit 6
HIDETREE       EQU  128            ; Bit 7
INDIRECT       EQU  256            ; Bit 8
FL3DIND        EQU  512            ; Bit 9
FL3DBAK        EQU  1024           ; Bit 10
FL3DACT        EQU  512+1024       ; Bits 9 und 10
SUBMENU        EQU  2048           ; Bit 11 (nur bei G_STRING)
SUBMENU_B      EQU  11

; ob_state

SELECTED       EQU  1
SELECTED_B     EQU  0
CROSSED        EQU  2
CROSSED_B      EQU  1
CHECKED        EQU  4
CHECKED_B      EQU  2
DISABLED       EQU  8
DISABLED_B     EQU  3
OUTLINED       EQU  16
OUTLINED_B     EQU  4
SHADOWED       EQU  32
SHADOWED_B     EQU  5
WHITEBAK       EQU  64
WHITEBAK_B     EQU  6
DRAW3D         EQU  128
DRAW3D_B       EQU  7

; TEDINFO.te_font

IBM            EQU  3
PFINFO         EQU  4              ; MagiC 6
SMALL          EQU  5

; TEDINFO.te_just

TE_LEFT        EQU  0
TE_RIGHT       EQU  1
TE_CNTR        EQU  2
TE_SPECIAL     EQU  3              ; MagiC 6

; fuer rsrc_gaddr()

R_TREE         EQU  0
R_OBJECT       EQU  1
R_TEDINFO      EQU  2
R_ICONBLK      EQU  3
R_BITBLK       EQU  4
R_STRING       EQU  5
R_BIPDATA      EQU  14

; Event-Typen

EVB_KEY        EQU  0
EV_KEY         EQU  1              ; Taste
EVB_BUT        EQU  1
EV_BUT         EQU  2              ; Mausknopf
EVB_MG1        EQU  2
EV_MG1         EQU  4              ; erstes Mausrechteck
EVB_MG2        EQU  3
EV_MG2         EQU  8              ; zweites Mausrechteck
EVB_MSG        EQU  4
EV_MSG         EQU  16             ; Nachricht
EVB_TIM        EQU  5
EV_TIM         EQU  32             ; Timer
EVB_SEM        EQU  6
EV_SEM         EQU  64             ; Semphore
EVB_IO         EQU  7
EV_IO          EQU  128            ; I/O
EVB_PID        EQU  8
EV_PID         EQU  256            ; MagiC 5.04: Pwaitpid()
EVB_FORK       EQU  9
EV_FORK        EQU  512            ; MagiC 6.10: P(v)fork()
EV_RESVD       EQU  $8000

/* AES- Variablen */

TMPLEN         SET  24*(NAPPS+9)   ; Platz fuer NAPPS+9 Objekte
TMPLEN2        SET  24*10+5*41+3*21; Platz fuer einen Alert
     IF   TMPLEN2>TMPLEN
TMPLEN         SET  TMPLEN2
     ENDC


     OFFSET __a_aes

*  fuer Events

mcl_timer:     DS.W 1              /* int  mcl_timer                       */
mcl_bstate:    DS.W 1              /* int  mcl_bstate                      */
mcl_count:     DS.W 1              /* int  mcl_count                       */
mcl_in_events: DS.W 1              /* int  mcl_in_events                   */

prev_count:    DS.W 1              /* int  prev_count                      */
prev_mnclicks: DS.W 1              /* int  prev_mnclicks                   */
prev_mkmstate: DS.W 1              /* int  prev_mkmstate                   */
prev_mkmx:     DS.W 1              /* int  prev_mkmx                       */
prev_mkmy:     DS.W 1              /* int  prev_mkmy                       */

gr_mnclicks:   DS.W 1              /* int  gr_mnclicks                     */
gr_mkkstate:   DS.W 1              /* int  gr_mkkstate                     */
gr_mkmstate:   DS.W 1              /* int  gr_mkmstate                     */
gr_mkmx:       DS.W 1              /* int  gr_mkmx                         */
gr_mkmy:       DS.W 1              /* int  gr_mkmy                         */
gr_evbstate:   DS.W 1              /* int  : bstate bei Event              */

* Fuer die VDI- Bibliothek

nvdi_workstn:  DS.L 1              /* int    *nvdi_workstn                 */
nvdi_patterns: DS.L 1              /* int    *(nvdi_patterns[16])          */

vintin_len:    DS.W 1              /* Laenge der Zeichenkette in vintin[]   */
vintin_dirty:  DS.W 1              /* Zeichenkette enthaelt Steuerzeichen   */
vdipb:         DS.L 5              /* long   vdipb[5]                      */
                                   /*        vdipb[0]->vcontrl             */
                                   /*        vdipb[1]->vintin              */
                                   /*        vdipb[2]->vptsin              */
                                   /*        vdipb[3]->vintout             */
vcontrl:       DS.W 12             /* int    vcontrl[12]                   */
vintin:        DS.W 4              /* 4 Integers extra                     */
txvintin:      DS.W 256            /* 256 Zeichen                          */
vintout:       DS.W 10             /* int    vintout[10]                   */
vptsin:        DS.W 30             /* int    vptsin[30]                    */
vptsout:       DS.W 20             /* int    vptsout[10]                   */
work_out:      DS.W 58             /* int    work_out[58]                  */

xclip:         DS.W 1              /* aktueller Clippingbereich            */
yclip:         DS.W 1
wclip:         DS.W 1
hclip:         DS.W 1

vdi_device:    DS.W 1              /* int    vdi_device                    */
dflt_xdv:      DS.W 1              /* zusaetzlicher Falcon-Modus            */

/* Infos fuer RSC-Umrechnung und Objektgroessen */

big_wchar:     DS.W 1
big_hchar:     DS.W 1

/* Infos fuer Fensterrahmen */

gr_hwbox:      DS.W 1              /* int    gr_hwbox                      */
gr_hhbox:      DS.W 1              /* int    gr_hhbox                      */

/* Infos fuer Zeichensaetze */

finfo_sys:     DS.B finfo_sizeof   /* fuer grossen System-Zeichensatz        */
finfo_big:     DS.B finfo_sizeof   /* fuer grossen AES-Zeichensatz (IBM)     */
finfo_sml:     DS.B finfo_sizeof   /* fuer kleinen AES-Zeichensatz (SMALL)  */
isfsm_big:     DS.W 1              /* Rueckgabewert fuer appl_getinfo(0)     */
isfsm_sml:     DS.W 1              /* Rueckgabewert fuer appl_getinfo(1)     */
dummyvws:      DS.W 1              /* Dummy-VDI-Workstation fuer alte Pgme. */

curr_wmode:    DS.W 1              /* int    curr_wmode                    */
curr_style:    DS.W 1              /* int    curr_style                    */
curr_patt:     DS.W 1              /* int    curr_patt                     */
curr_font:     DS.W 1              /* int  (5 oder 3)                      */
curr_finfo:    DS.L 1              /* Eingestellter Font                   */
curr_fid:      DS.W 1              /* eingestellte Font-ID                 */
curr_tcolor:   DS.W 1              /* int   curr_tcolor                    */
curr_fcolor:   DS.W 1              /* int   curr_fcolor                    */
curr_pcolor:   DS.W 1              /* int   curr_pcolor                    */
curr_scrmode:  DS.W 1              /* int : 0=Text 1=Grafik                */

menubar_grect: DS.W 4              /* GRECT  menubar_grect                 */
desk_g:        DS.W 4              /* Bildschirm ohne Menueleiste           */
full_g:        DS.W 2              /* Bildschirm mit Menueleiste            */
scr_w:         DS.W 1              /* int    scr_w                         */
scr_h:         DS.W 1              /* int    scr_h                         */

nplanes:       DS.W 1              /* int    nplanes                       */
xp_mode:       DS.W 1              /* 0=err 1=wandeln -1=nicht_wandeln     */
xp_ptr:        DS.L 1              /* Farbicon-Wandlungsfunktion           */
xp_tab:        DS.L 1              /* Farbicon-Farbtabelle                 */
ms_per_click:  DS.W 1              /* int    ms_per_click                  */

mfdb1:         DS.W 10             /* MFDB                                 */
mfdb2:         DS.W 10             /* MFDB                                 */
scrbuf:        DS.W 4              /* GRECT                                */
scrbuf_mfdb:   DS.W 10             /* MFDB                                 */
screenbuf_len: DS.L 1              /* long   screenbuf_len                 */

* Interrupt- Variablen

was_warmboot:  DS.W 1              /* int:  muss Ctrl-Alt-Del verarbeiten   */
old_warmbvec:  DS.L 1              /* long: alter Vektor oder NULL         */
old_trap2:     DS.L 1              /* long: alter Trap #2 Vektor           */
old_timer_int: DS.L 1              /* long   old_timer_int                 */
old_mov_int:   DS.L 1              /* long   old_mov_int                   */
old_but_int:   DS.L 1              /* long   old_but_int                   */
int_mx:        DS.W 1              /* Interrupt-Mauspos X                  */
int_my:        DS.W 1              /* Interrupt-Mauspos Y                  */
int_butstate:  DS.W 1              /* int, vom Interrupt gesetzter Status  */
int_but_dirty: DS.W 1              /* int: Ringpuffer-Ueberlauf             */
alrm_cntup:    DS.L 1              /* long, zaehlt bei Dekrem. countdown    */
alrm_cntdown:  DS.L 1              /* long */
timer_cntup:   DS.L 1              /* long, zaehlt bei Dekrem. countdown    */
timer_cntdown: DS.L 1              /* long */
timer_cnt:     DS.L 1              /* long, zaehlt jeden Aufruf             */
iocpbuf_cnt:   DS.W 1              /* Anzahl Ereignisse im Festpuffer      */
ringbuf_cnt:   DS.W 1              /* Anzahl Ereignisse im Ringpuffer      */
ringbuf_head:  DS.W 1              /* int    ringbuf_head                  */
ringbuf_tail:  DS.W 1              /* int    ringbuf_tail                  */
ringbuf:       DS.B RNGBFLEN*8     /* Ringpuffer                           */
iocpbuf:       DS.B NAPPS          /* IOcomplete- Flags                    */
               EVEN


* Fuer den Kernel und Applicationmanager

inaes:         DS.B 1              /* char: Kernel sperren                 */
no_switch:     DS.B 1              /* char: Taskwechsel verbieten          */
suspend_list:  DS.L 1              /* APPL*  Zeitscheibe verbraucht        */
notready_list: DS.L 1              /* APPL*  warten auf Ereignis           */
timer_evlist:  DS.L 1              /* long *                               */
alrm_evlist:   DS.L 1              /* long *                               */

topwind_app:   DS.L 1              /* APPL *                               */
mouse_app:     DS.L 1              /* APPL *                               */
keyb_app:      DS.L 1              /* APPL *                               */
menu_app:      DS.L 1              /* APPL *                               */

menutree:      DS.L 1              /* OBJECT *menutree                     */
desktree:      DS.L 1              /* OBJECT *desktree                     */
desktree_1stob:DS.W 1              /* int    desktree_1stob                */
pop_list:      DS.L 1              /* popupS *poplist                      */

scmgr_mm:      DS.W 5              /* MGRECT des Menuebalkens               */
menu_grect:    DS.W 4              /* GRECT  menu_grect                    */
no_of_menuregs:DS.W 1              /* int, Anzahl der registrierten ACCs   */
reg_entries:   DS.L 6              /* char *reg_entries[6]                 */
reg_apidx:     DS.W 6              /* int  reg_apidx[6]                    */
                                   /*        -1: freier Eintrag            */
scmgr_wakeup:  DS.W 1              /* int: Zaehler fuer SCRENMGR             */
button_grect:  DS.W 4              /* GRECT (etwa WORKXYWH von topwind)    */
moff_cnt:      DS.W 1              /* int : Zaehler fuer Mausabschaltung     */

upd_blockage:  DS.B bl_sizeof      /* BLOCKAGE                             */
beg_mctrl_cnt: DS.W 1              /* int    beg_mctrl_cnt                 */

mctrl_mnrett:  DS.L 1              /* long   mctrl_mnrett                  */
mctrl_btrett:  DS.W 4              /* GRECT  mctrl_btrett                  */
mctrl_karett:  DS.L 1              /* long   mctrl_karett                  */

aptr_flag:     DS.W 1              /* int  : appl_trecord laeuft            */
aptr_count:    DS.W 1              /* int    aptr_count                    */
aptp_dirtyint: DS.W 1              /* int    aptp_dirtyint                 */
aptr_buf:      DS.L 1              /* Zeiger -> Eventpuffer (je 8 Bytes)   */

dclick_clicks: DS.W 1              /* int    dclick_clicks                 */
dclick_val:    DS.W 1              /* int  (0..4)                          */

* Fuer Timeslice

pe_un_susp:    DS.W 1
pe_unsuspcnt:  DS.W 1

* Verschiedenes

enable_3d:     DS.W 1              /* int    ist 1, wenn 3D-Objekte        */
aes_bootdrv:   DS.B 1              /* char   aes_bootdrv                   */
               DS.B 1              /* char   serno_isok                    */
_basepage:     DS.L 1              /* long   _basepage                     */
mdraw_int_adr: DS.L 1              /* long   mdraw_int_adr                 */

* Struktur fuer Uebergabe an GEMDOS

dos_magic:     DS.L 1              /* 'XAES'                               */
act_appl:      DS.L 1              /* APPL *                               */
ap_pd_offs:    DS.W 1              /* Offset fuer ap_pd                     */
appln:         DS.W 1              /* Anzahl der APPLs                     */
maxappln:      DS.W 1              /* Tabellenlaenge                        */
applx:         DS.L NAPPS          /* APPL *applx[NAPPS]                   */

* Fuer den Window- Manager

wg_freelist:   DS.L 1              /* long wg_freelist                     */
nwindows:      DS.W 1              /* Anzahl Fenster                       */
topwhdl:       DS.W 1              /* int: Handle des obersten Fensters    */
whdlx:         DS.W MAX_NWIND      /* Liste der Fenster von oben ab        */
windx:         DS.L 1              /* WINDOW *windx                        */
wsizeof:       DS.L 1              /* Speicherblockgroesse fuer Fenster       */
wbm_hshade:    DS.W 1              /* Hoehe des ge-shade-ten Fensters       */
wbm_create:    DS.L 1              /* Callback fuer wind_create()           */
wbm_skind:     DS.L 1              /* Callback f. wind_create(),wind_set() */
wbm_ssize:     DS.L 1              /* Callback f. wind_set()               */
wbm_sslid:     DS.L 1              /* Callback f. wind_set()               */
wbm_sstr:      DS.L 1              /* Callback f. wind_set()               */
wbm_sattr:     DS.L 1              /* Callback f. wind_set()               */
wbm_calc:      DS.L 1              /* Callback f. wind_calc()              */
wbm_obfind:    DS.L 1              /* Callback f. SCRENMGR                 */
wbm_endvars:

/* Farben/Raender fuer Fensterobjekte */
dcol_box:      DS.W 2              /* umfassende Box             W_BOX     */
dcol_closer:   DS.W 2              /* Schliessbox                 W_CLOSER  */
dcol_name:     DS.W 2              /* Titelzeile                 W_NAME    */
dcol_bdrop:    DS.W 2              /* Backdrop-Button      (wie W_FULLER)  */
dcol_fuller:   DS.W 2              /* Maximalknopf               W_FULLER  */
dcol_info:     DS.W 2              /* Infozeile                  W_INFO    */
dcol_sizer:    DS.W 2              /* Groessenknopf                W_SIZER   */
dcol_arup:     DS.W 2              /* Pfeil hoch                 W_UPARROW */
dcol_ardwn:    DS.W 2              /* Pfeil runter               W_DNARROW */
dcol_vsld:     DS.W 2              /* Hintergrund vert. Balken   W_VSLIDE  */
dcol_vbar:     DS.W 2              /* vertikaler Balken          W_VELEV   */
dcol_arlft:    DS.W 2              /* Pfeil links                W_LFARROW */
dcol_arrgt:    DS.W 2              /* Pfeil rechts               W_RTARROW */
dcol_hsld:     DS.W 2              /* Hintergrund horiz. Balken  W_HSLIDE  */
dcol_hbar:     DS.W 2              /* horizontaler Balken        W_HELEV   */
dcol_iconify:  DS.W 2              /* Iconifier (wie W_FULLER)             */

/* 3D-Flags fuer Fensterobjekte */
f3d_box:       DS.B 1              /* umfassende Box             W_BOX     */
f3d_closer:    DS.B 1              /* Schliessbox                 W_CLOSER  */
f3d_name:      DS.B 1              /* Titelzeile                 W_NAME    */
f3d_bdrop:     DS.B 1              /* Backdrop-Button      (wie W_FULLER)  */
f3d_fuller:    DS.B 1              /* Maximalknopf               W_FULLER  */
f3d_info:      DS.B 1              /* Infozeile                  W_INFO    */
f3d_sizer:     DS.B 1              /* Groessenknopf                W_SIZER   */
f3d_arup:      DS.B 1              /* Pfeil hoch                 W_UPARROW */
f3d_ardwn:     DS.B 1              /* Pfeil runter               W_DNARROW */
f3d_vsld:      DS.B 1              /* Hintergrund vert. Balken   W_VSLIDE  */
f3d_vbar:      DS.B 1              /* vertikaler Balken          W_VELEV   */
f3d_arlft:     DS.B 1              /* Pfeil links                W_LFARROW */
f3d_arrgt:     DS.B 1              /* Pfeil rechts               W_RTARROW */
f3d_hsld:      DS.B 1              /* Hintergrund horiz. Balken  W_HSLIDE  */
f3d_hbar:      DS.B 1              /* horizontaler Balken        W_HELEV   */
f3d_iconify:   DS.B 1              /* Iconifier (wie W_FULLER)             */
     EVEN

tedinfo1:      DS.B $1c            /* TEDINFO ($1c Bytes)  fuer NAME        */
tedinfo2:      DS.B $1c            /* TEDINFO ($1c Bytes)  fuer INFO        */

/* globale Fenster-Einstellungen => WINFRAME */

wsg_flags:     DS.W 1              /* Bit 0: kein Bdrop-Button             */
inw_height:    DS.W 1              /* Hoehe der INFO-Zeile                  */
pfinfo_inw:    DS.L 1              /* Zeiger auf finfo_inw                 */
finfo_inw:     DS.B finfo_sizeof   /* fuer INFO-Zeile im Fenster            */

* fuer den variablen AES-Dispatcher (ab V5.20)

fn_rellen:     DS.W 1              /* max. Funktionsnummer +1 fuer interne,
                                      relative AES- Sprungtabelle          */
fn_abstab:     DS.L 1              /* Sprungtabelle mit abs. Adressen      */
fn_abslen:     DS.W 1              /* Tabellenlaenge                        */
fn_getinfo:    DS.L 1              /* zum Einklinken                       */
fn_editor:     DS.L 1              /* fuer Objekttyp G_EDIT                 */

* Tabellen

wgrects:       DS.L 1              /* WGRECT *wgrects                      */
shel_isfirst:  DS.W 1
shel_name:     DS.B 128            /* char shel_name[128]                  */
scrp_dir:      DS.B 128            /* char scrp_dir[128]                   */
popup_tmp:     DS.B TMPLEN         /* OBJECT [NAPPS+4]                     */
                                   /* OBJECT [10],char[5][41],char[3][21]  */

shel_vector:   DS.L 1              /* void (*shel_vector)()                */
shel_buf_len:  DS.W 1              /* int    shel_buf_len                  */
shel_buf:      DS.L 1              /* char   *shel_buf                     */

p_fsel:        DS.L 1              /* long: Fileselect- Vektor             */
fslx_sortmode: DS.W 1              /* Sortiermodus fuer Dateiauswahl        */
fslx_flags:    DS.W 1              /* ... globale Flags                    */
fslx_exts:     DS.B 256            /* selbstdef. Datentypen                */
fslx_d2s:      DS.L 1              /* void (*date2str)(WORD date, char *s) */
fslx_dlw:      DS.W 1              /* Dialogbreite                         */
fslx_dlm:      DS.W 1              /* min. Dialogbreite                    */
old_etvc:      DS.L 1              /* long: alter etv_critic- Vektor       */
dflt_etvt:     DS.L 1              /* long: alter etv_term- Vektor         */
shelw_startpic:DS.B 2*24+28        /* OBJECT [2], TEDINFO                  */

/* Fuer den Backdrop-Button */

bdrop_thdl:    DS.W 1              /* int:  zu toppendes Fenster           */
bdrop_hdl:     DS.W 1              /* int:  zu droppendes Fenster          */
bdrop_timer:   DS.L 1              /* long: timer_cnt beim Aufruf          */

/* Fuer Applikationsumschaltung per TOPALL */

topall_thdl:   DS.W 1              /* int:  zu toppendes Fenster           */
topall_timer:  DS.L 1              /* long: timer_cnt beim Aufruf          */

termprog:      DS.B 80             /* Pfad des TOS-in-Fenster-Programms    */
shutdown_id:   DS.W 1              /* ap_id des shutdown- Initiators       */
shutdown_dev:  DS.W 1              /* fuer Aufloesungswechsel */
shutdown_xdv:  DS.W 1              /* Falcon-Aufloesung */
shutdown_txt:  DS.W 1              /* fuer Aufloesungswechsel */
look_flags:    DS.W 1              /* Bestimmen den Geschmack              */
                                   /*  Bit 0: Position des Logos           */
                                   /*  Bit 1: 3D-Effekte ausschalten       */
                                   /*  Bit 2: Backdrop-Button abschalten   */
                                   /*  Bit 3: kein neuer Fenstertitel      */
                                   /*  Bit 4: Fenstertitelname nicht 3D    */
                                   /*  Bit 5: Onlinescrolling nur mit Ctrl */
                                   /*  Bit 6: Online move/size mit Ctrl    */
                                   /*  Bit 7: 3D-Menues                     */
hotkey_sem:    DS.B 1              /* char: Alt-Ctrl-... verarbeiten       */
     EVEN
vmn_set:       DS.B mns_sizeof     /* fuer menu_settings */

     EVEN

bootstack: ds.b 1024

endofvars:

     TEXT


E_OK      EQU 0
ERROR     EQU -1
EDRVNR    EQU -2
EUNCMD    EQU -3
E_CRC     EQU -4
EBADRQ    EQU -5
E_SEEK    EQU -6
EMEDIA    EQU -7
ESECNF    EQU -8
EPAPER    EQU -9
EWRITF    EQU -10
EREADF    EQU -11
EWRPRO    EQU -13
E_CHNG    EQU -14
EUNDEV    EQU -15
EBADSF    EQU -16
EOTHER    EQU -17

EINVFN    EQU -32
EFILNF    EQU -33
EPTHNF    EQU -34
ENHNDL    EQU -35
EACCDN    EQU -36
EIHNDL    EQU -37
ENSMEM    EQU -39
EIMBA     EQU -40
EDRIVE    EQU -46
ENSAME    EQU -48
ENMFIL    EQU -49
ERANGE    EQU -64
EINTRN    EQU -65
EPLFMT    EQU -66
EGSBF     EQU -67

EBREAK    EQU -68             * KAOS
EXCPT     EQU -69             * KAOS
EPTHOV    EQU -70             * MAGIX


/***************************************************************************/
/*  Struktur WGRECT                                                        */
/*  Laenge: $c Bytes                                                       */
/***************************************************************************/

;typedef struct {
;    WGRECT    *wg_nextwg;    /* 0x00: Naechstes WGRECT in Liste            */
;    GRECT     wg_grect;      /* 0x04: WGRECT- Daten                       */
;} WGRECT;


/***************************************************************************/
/*   Struktur EVPARM                                                       */
/*   Laenge: 8 Bytes                                                       */
/***************************************************************************/

;typedef struct {
;     int       evp_id         /* 0x00: Empfaenger- Applikation              */
;     int       evp_len;       /* 0x02: Laenge der Nachricht in Bytes        */
;     int       *evp_bufp;     /* 0x04: Zeiger auf Nachrichtenbytes         */
;} EVPARM;


/***************************************************************************/
/*   Struktur BLOCKAGE                                                     */
/*   Laenge: $a Bytes                                                       */
/***************************************************************************/

;typedef struct {
;     int       bl_cnt;        /* 0x00: Anzahl der BEG_UPDATEs              */
;     APPL      *bl_app;       /* 0x02: sperrende Applikation oder NULL     */
;     APPL      *bl_waiting;   /* 0x06: wartende Applikationen              */
;     PD        *bl_pd;
;     long      bl_name;
;     BLOCKAGE  *bl_next;
;} BLOCKAGE;


/***************************************************************************/
/*   Struktur MGRECT                                                       */
/*   Laenge: $a Bytes                                                       */
/***************************************************************************/

;typedef struct {
;     int       mg_flag;       /* 0x00: 0=betreten 1=verlasssen             */
;     GRECT     mg_grect;      /* 0x02: Mausrechteck                        */
;} MGRECT;


/***************************************************************************/
/*   Struktur KOORD                                                        */
/*   Laenge: 4 Bytes                                                        */
/***************************************************************************/

;typedef struct {
;     int       k_x;           /* 0x00:                                     */
;     int       k_y;           /* 0x02:                                     */
;} KOORD;


/***************************************************************************/
/*   Bitfeld EVBUTTON                                                      */
/*   Laenge: 4 Bytes                                                        */
/***************************************************************************/

;typedef struct {
;     unsigned  bt_stat : 8;   /*  0.. 7: ausloesender Status                */
;     unsigned  bt_msk  : 8;   /*  8..15: beruecksichtigte Maustasten        */
;     unsigned  bt_n    : 8;   /* 16..23: n-fach Klick                      */
;     unsigned  bt_flag : 8;   /* 24..31: TRUE, wenn Match invertieren      */
;} EVBUTTON;

