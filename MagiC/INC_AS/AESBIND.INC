************************************************************************
*   AESBIND.INC
* 14.2.89 Andreas Kromke
************************************************************************

* AES Bibliothek

* _aes:
*  lea      control(pc),a0
*  movep    d0,5(a0)
*  swap     d0
*  movep    d0,1(a0)
*  move.w   #$c8,d0
*  move.l   #aespb,d1
*  trap     #2
*  rts

MACRO          M_appl_init
               move.l    #$0a000100,d0
               bsr       _aes
               ENDM

MACRO          M_appl_read
               move.l    #$0b020101,d0
               bsr       _aes
               ENDM

MACRO          M_appl_write
               move.l    #$0c020101,d0
               bsr       _aes
               ENDM

MACRO          M_appl_find
               move.l    #$0d000101,d0
               bsr       _aes
               ENDM

MACRO          M_appl_tplay
               move.l    #$0e020101,d0
               bsr       _aes
               ENDM

MACRO          M_appl_trecord
               move.l    #$0f010101,d0
               bsr       _aes
               ENDM

MACRO          M_appl_bvset
               move.l    #$10020100,d0
               bsr       _aes
               ENDM

MACRO          M_appl_yield
               move.l    #$11000100,d0
               bsr       _aes
               ENDM

MACRO          M_appl_exit
               move.l    #$13000100,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_keybd
               move.l    #$14000100,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_button
               move.l    #$15030500,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_mouse
               move.l    #$16050500,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_mesag
               move.l    #$17000101,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_timer
               move.l    #$18020100,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_multi
               move.l    #$19100701,d0
               bsr       _aes
               ENDM

MACRO          M_evnt_dclicks
               move.l    #$1a020100,d0
               bsr       _aes
               ENDM

MACRO          M_menu_bar
               move.l    #$1e010101,d0
               bsr       _aes
               ENDM

MACRO          M_menu_icheck
               move.l    #$1f020101,d0
               bsr       _aes
               ENDM

MACRO          M_menu_ienable
               move.l    #$20020101,d0
               bsr       _aes
               ENDM

MACRO          M_menu_tnormal
               move.l    #$21020101,d0
               bsr       _aes
               ENDM

MACRO          M_menu_text
               move.l    #$22010102,d0
               bsr       _aes
               ENDM

MACRO          M_menu_register
               move.l    #$23010101,d0
               bsr       _aes
               ENDM

MACRO          M_menu_unregister
               move.l    #$24010100,d0
               bsr       _aes
               ENDM

MACRO          M_objc_draw
               move.l    #$2a060101,d0
               bsr       _aes
               ENDM

MACRO          M_objc_find
               move.l    #$2b040101,d0
               bsr       _aes
               ENDM

MACRO          M_form_do
               move.l    #$32010101,d0
               bsr       _aes
               ENDM

MACRO          M_form_dial
               move.l    #$33090100,d0
               bsr       _aes
               ENDM

MACRO          M_form_alert
               move.l    #$34010101,d0
               bsr       _aes
               ENDM

MACRO          M_form_error
               move.l    #$35010100,d0
               bsr       _aes
               ENDM

MACRO          M_form_center
               move.l    #$36000501,d0
               bsr       _aes
               ENDM

MACRO          M_graf_dragbox
               move.l    #$47080300,d0
               bsr       _aes
               ENDM

MACRO          M_graf_slidebox
               move.l    #$4c030101,d0
               bsr       _aes
               ENDM

MACRO          M_graf_handle
               move.l    #$4d000500,d0
               bsr       _aes
               ENDM

MACRO          M_graf_mouse
               move.l    #$4e010101,d0
               bsr       _aes
               ENDM

MACRO          M_graf_mkstate
               move.l    #$4f000500,d0
               bsr       _aes
               ENDM

MACRO		M_scrp_read
			move.l	#$50000101,d0
			bsr		_aes
			ENDM

MACRO		M_scrp_write
			move.l	#$51000101,d0
			bsr		_aes
			ENDM

MACRO		M_scrp_clear
			move.l	#$52000100,d0
			bsr		_aes
			ENDM

MACRO          M_fsel_input
               move.l    #$5a000202,d0
               bsr       _aes
               ENDM

MACRO          M_fsel_exinput
               move.l    #$5b000203,d0
               bsr       _aes
               ENDM

MACRO          M_wind_create
               move.l    #$64050100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_open
               move.l    #$65050100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_close
               move.l    #$66010100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_delete
               move.l    #$67010100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_get
               move.l    #$68020500,d0
               bsr       _aes
               ENDM

MACRO          M_wind_set
               move.l    #$69060100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_find
               move.l    #$6a020100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_update
               move.l    #$6b010100,d0
               bsr       _aes
               ENDM

MACRO          M_wind_calc
               move.l    #$6c060500,d0
               bsr       _aes
               ENDM

MACRO          M_wind_new
               move.l    #$6d000000,d0
               bsr       _aes
               ENDM

MACRO          M_rsrc_load
               move.l    #$6e000101,d0
               bsr       _aes
               ENDM

MACRO          M_rsrc_free
               move.l    #$6f000100,d0
               bsr       _aes
               ENDM

MACRO          M_rsrc_gaddr
               move.l    #$70020100,d0
               bsr       _aes
               ENDM

MACRO          M_rsrc_obfix
               move.l    #$72010101,d0
               bsr       _aes
               ENDM

MACRO          M_shel_read
               move.l    #$78000102,d0
               bsr       _aes
               ENDM

MACRO          M_shel_write
               move.l    #$79030102,d0
               bsr       _aes
               ENDM

MACRO          M_shel_find
               move.l    #$7c000101,d0
               bsr       _aes
               ENDM

MACRO          M_shel_envrn
               move.l    #$7d000102,d0
               bsr       _aes
               ENDM

MACRO          M_shel_rdef
               move.l    #$7e000102,d0
               bsr       _aes
               ENDM

MACRO          M_shel_wdef
               move.l    #$7f000002,d0
               bsr       _aes
               ENDM

/****** Object definitions **********************************************/

G_BOX          EQU      20
G_TEXT         EQU      21
G_BOXTEXT      EQU      22
G_IMAGE        EQU      23
G_USERDEF      EQU      24
G_IBOX         EQU      25
G_BUTTON       EQU      26
G_BOXCHAR      EQU      27
G_STRING       EQU      28
G_FTEXT        EQU      29
G_FBOXTEXT     EQU      30
G_ICON         EQU      31
G_TITLE        EQU      32


/* Object flags */

NONE           EQU      $0000
SELECTABLE     EQU      $0001
DEFAULT        EQU      $0002
EXIT           EQU      $0004
EDITABLE       EQU      $0008
RBUTTON        EQU      $0010
LASTOB         EQU      $0020
TOUCHEXIT      EQU      $0040
HIDETREE       EQU      $0080
INDIRECT       EQU      $0100


/* Object states */

NORMAL         EQU      $00
SELECTED       EQU      $01
CROSSED        EQU      $02
CHECKED        EQU      $04
DISABLED       EQU      $08
OUTLINED       EQU      $10
SHADOWED       EQU      $20
WHITEBAK       EQU      $40


/* Object colors */

WHITE          EQU       0
BLACK          EQU       1
RED            EQU       2
GREEN          EQU       3
BLUE           EQU       4
CYAN           EQU       5
YELLOW         EQU       6
MAGENTA        EQU       7
LWHITE         EQU       8
LBLACK         EQU       9
LRED           EQU      10
LGREEN         EQU      11
LBLUE          EQU      12
LCYAN          EQU      13
LYELLOW        EQU      14
LMAGENTA       EQU      15


ROOT           EQU       0
MAX_LEN        EQU      81              /* max string length */
MAX_DEPTH      EQU       8              /* max depth of search or draw */


IBM            EQU      3               /* font types */
SMALL          EQU      5


EDSTART        EQU      0               /* editable text field definitions */
EDINIT         EQU      1
EDCHAR         EQU      2
EDEND          EQU      3

TE_LEFT        EQU      0               /* editable text justification */
TE_RIGHT       EQU      1
TE_CNTR        EQU      2

*   EVENT Manager Definitions
*                   multi flags
MU_KEYBD       EQU  $0001
MU_BUTTON      EQU  $0002
MU_M1          EQU  $0004
MU_M2          EQU  $0008
MU_MESAG       EQU  $0010
MU_TIMER       EQU  $0020
*                   message values
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
AC_OPEN        EQU  40
AC_CLOSE       EQU  41

*   FORM Manager Definitions
*                   Form flags
FMD_START      EQU  0
FMD_GROW       EQU  1
FMD_SHRINK     EQU  2
FMD_FINISH     EQU  3

*   RESOURCE Manager Definitions
*                   data structure types
R_TREE         EQU  0
R_OBJECT       EQU  1
R_TEDINFO      EQU  2
R_ICONBLK      EQU  3
R_BITBLK       EQU  4
R_STRING       EQU  5      ; gets pointer to free strings
R_IMAGEDATA    EQU  6      ; gets pointer to free images
R_OBSPEC       EQU  7
R_TEPTEXT      EQU  8      ; sub ptrs in TEDINFO
R_TEPTMPLT     EQU  9
R_TEPVALID     EQU  10
R_IBPMASK      EQU  11      ; sub ptrs in ICONBLK
R_IBPDATA      EQU  12
R_IBPTEXT      EQU  13
R_BIPDATA      EQU  14      ; sub ptrs in BITBLK
R_FRSTR        EQU  15      ; gets addr of ptr to free strings
R_FRIMG        EQU  16      ; gets addr of ptr to free images

*   WINDOW Manager Definitions
*                   Window Attributes
NAME           EQU  $0001
CLOSER         EQU  $0002
FULLER         EQU  $0004
MOVER          EQU  $0008
INFO           EQU  $0010
SIZER          EQU  $0020
UPARROW        EQU  $0040
DNARROW        EQU  $0080
VSLIDE         EQU  $0100
LFARROW        EQU  $0200
RTARROW        EQU  $0400
HSLIDE         EQU  $0800
*                    wind_create flags
WC_BORDER      EQU  0
WC_WORK        EQU  1
*                    wind_get flags
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
*                   update flags
END_UPDATE     EQU  0
BEG_UPDATE     EQU  1
END_MCTRL      EQU  2
BEG_MCTRL      EQU  3

*   GRAPHICS Manager Definitions
*                   Mouse Forms
ARROW          EQU  0
TEXT_CRSR      EQU  1
BEE            EQU  2
POINT_HAND     EQU  3
FLAT_HAND      EQU  4
THIN_CROSS     EQU  5
THICK_CROSS    EQU  6
OUTLN_CROSS    EQU  7
USER_DEF       EQU  255
M_OFF          EQU  256
M_ON           EQU  257

* struct OBJECT
OBJECT_SIZE    EQU  24

     OFFSET
ob_next:       DS.W 1              ; 0
ob_head:       DS.W 1              ; 2
ob_tail:       DS.W 1              ; 4
ob_type:       DS.W 1              ; 6
ob_flags:      DS.W 1              ; 8
ob_state:      DS.W 1              ; $a
ob_spec:       DS.L 1              ; $c
ob_x:          DS.W 1              ; $10
ob_y:          DS.W 1              ; $12
ob_width:      DS.W 1              ; $14
ob_height:     DS.W 1              ; $16

*struct TEDINFO
     OFFSET
te_ptext:      DS.L 1              ; 0
te_ptmplt:     DS.L 1              ; 4
te_pvalid:     DS.L 1              ; 8
te_font:       DS.W 1              ; $c
te_resvdl:     DS.W 1
te_just:       DS.W 1
te_color:      DS.W 1
te_resvd2:     DS.W 1
te_thickness:  DS.W 1
te_txtlen:     DS.W 1
te_tmplen:     DS.W 1

     TEXT
