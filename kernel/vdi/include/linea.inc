
;
; Line-A-Basisadressen
;
TOS_100_BASE        EQU $293a                   ;TOS     1.00
TOS_102_BASE        EQU $299a                   ;TOS     1.02
TOS_103_BASE        EQU $2170                   ;TOS     1.03 vom 8.8.1988 (1.04 Beta)
TOS_104_BASE        EQU $2adc                   ;TOS     1.04
TOS_162_BASE        EQU $2b1c                   ;TOS     1.62
TOS_301_BASE        EQU $3930                   ;TOS     3.01
TOS_306_BASE        EQU $3a1a                   ;TOS     3.06
TOS_401_BASE        EQU $3e86                   ;TOS     4.01
KAOS_14_BASE        EQU $2adc                   ;KAOS  1.4x
MAGIX_100_BASE      EQU $2500                   ;MagiX 1.00
MAGIX_110_BASE      EQU $2070                   ;MagiX 1.10

;CMP_BASE           EQU TOS_306_BASE         ;Vergleichswert fuer die Relokation
;LINE_A_BASE        EQU TOS_306_BASE         ;Adresslage von LINE-A
;CMP_BASE           EQU TOS_401_BASE         ;Vergleichswert fuer die Relokation
;LINE_A_BASE        EQU TOS_401_BASE         ;Adresslage von LINE-A
CMP_BASE            EQU MAGIX_110_BASE      ;Vergleichswert fuer die Relokation
LINE_A_BASE         EQU MAGIX_110_BASE      ;Adresslage von LINE-A
;CMP_BASE           EQU KAOS_14_BASE         ;Vergleichswert fuer die Relokation
;LINE_A_BASE        EQU KAOS_14_BASE         ;Adresslage von LINE-A

/* Line-A variables */
			   OFFSET LINE_A_BASE-$038a

               .EXPORT CUR_FONT
CUR_FONT:      ds.l 1      /* (lineavars-$38a)  current font */
               ds.w 23     /* (lineavars-$386)  23 reserved words */
               .EXPORT M_POS_HX
M_POS_HX:      ds.w 1      /* (lineavars-$358)  x-hot-spot */
               .EXPORT M_POS_HY
M_POS_HY:      ds.w 1      /* (lineavars-$356)  y-hot-spot */
               .EXPORT M_PLANES
M_PLANES:      ds.w 1      /* (lineavars-$354)  number of planes (always 1) */
               .EXPORT M_CDB_BG
M_CDB_BG:      ds.w 1      /* (lineavars-$352)  background color */
               .EXPORT M_CDB_FG
M_CDB_FG:      ds.w 1      /* (lineavars-$350)  foreground color */
               .EXPORT MASK_FORM
MASK_FORM:     ds.w 32     /* (lineavars-$34e)  32 words of mask data */
               .EXPORT INQ_TAB
INQ_TAB:       ds.w 45     /* (lineavars-$30e)  45 words for vq_extnd intout */
INQ_TAB0            EQU INQ_TAB             ;Bildschirmtyp
INQ_TAB1            EQU INQ_TAB+2           ;Anzahl Farbabstufungen
INQ_TAB4            EQU INQ_TAB+8           ;Anzahl der Bildebenen
INQ_TAB5            EQU INQ_TAB+10          ;CLUT-Unterstuetzung
INQ_TAB6            EQU INQ_TAB+12          ;Anzahl der 16*16 Rasteroperationen
INQ_TAB19           EQU INQ_TAB+38          ;Clipping-Flag
               .EXPORT DEV_TAB
DEV_TAB:       ds.w 45     /* (lineavars-$2b4)  45 words */
DEV_TAB0            EQU DEV_TAB             ;adressierbare Rasterbreite
DEV_TAB1            EQU DEV_TAB+2           ;adressierbare Rasterhoehe
DEV_TAB3            EQU DEV_TAB+6           ;Pixelbreite in Mikrometern
DEV_TAB4            EQU DEV_TAB+8           ;Pixelhoehe in Mikrometern
DEV_TAB5            EQU DEV_TAB+10          ;Anzahl der Zeichenhoehen
DEV_TAB6            EQU DEV_TAB+12          ;
DEV_TAB13           EQU DEV_TAB+26          ;Anzahl der Farben
DEV_TAB35           EQU DEV_TAB+70          ;Farbdarstellungsflag
DEV_TAB39           EQU DEV_TAB+78          ;Groesse der Farbpalette
               .EXPORT GCURX
GCURX:         ds.w 1      /* (lineavars-$25a)  x-position of mouse */
               .EXPORT GCURY
GCURY:         ds.w 1      /* (lineavars-$258)  y-position of mouse */
               .EXPORT M_HID_CNT
M_HID_CNT:     ds.w 1      /* (lineavars-$256)  hide counter of mouse cursor */
               .EXPORT MOUSE_BT
MOUSE_BT:      ds.w 1      /* (lineavars-$254)  mouse button state */
               .EXPORT REQ_COL
REQ_COL:       ds.w 16*3   /* (lineavars-$252)  color values for first 16 colors */
               .EXPORT SIZ_TAB
SIZ_TAB:       ds.w 15     /* (lineavars-$1F2)  output values of v_opnwk/v_opnvwk */
SIZ_TAB2            EQU SIZ_TAB+4           ;groesste Zeichenbreite
SIZ_TAB3            EQU SIZ_TAB+6           ;groesste Zeichenhoehe
SIZ_TAB10           EQU SIZ_TAB+20          ;groesste Markerbreite
SIZ_TAB11           EQU SIZ_TAB+22          ;groesste Markerhoehe
               .EXPORT TERM_CH
TERM_CH:       ds.w 1      /* (lineavars-$1d4)  termination character */
               .EXPORT CHC_MOD
CHC_MOD:       ds.w 1      /* (lineavars-$1d2)  word */
               .EXPORT CUR_WORK
CUR_WORK:      ds.l 1      /* (lineavars-$1d0)  pointer to current VDI workstation */
               .EXPORT DEF_FONT
DEF_FONT:      ds.l 1      /* (lineavars-$1cc)  pointer to default font */
               .EXPORT FONT_RING
FONT_RING:     ds.l 4      /* (lineavars-$1c8)  system fonts */
               .EXPORT FONT_COUNT
FONT_COUNT:    ds.w 1      /* (lineavars-$1b8)  number of fonts in FONT_RING */
               .EXPORT LINE_CW
LINE_CW:       ds.w 1      /* (lineavars-$1b6) */
               .EXPORT LOC_MODE
LOC_MODE:      ds.w 1      /* (lineavars-$1b4) */
               .EXPORT NUM_QC_LIN
NUM_QC_LIN:    ds.w 1      /* (lineavars-$1b2) */
               .EXPORT TRAP14SAV
TRAP14SAV:     ds.l 1      /* (lineavars-$1b0) */
               .EXPORT COL_OR_MASK
COL_OR_MASK:   ds.l 1      /* (lineavars-$1ac) */
               .EXPORT COL_AND_MASK
COL_AND_MASK:  ds.l 1      /* (lineavars-$1a8) */
               .EXPORT TRAP14BSAV
TRAP14BSAV:    ds.l 1      /* (lineavars-$1a4) */
               ds.w 32       /*   (lineavars-$1a2)    32 reserved words */
               .EXPORT STR_MODE
STR_MODE:      ds.w 1      /* (lineavars-$160) */
               .EXPORT VAL_MODE
VAL_MODE:      ds.w 1      /* (lineavars-$15e) */
               .EXPORT CUR_MS_STAT
CUR_MS_STAT:   ds.b 1      /* (lineavars-$15c)  move flag and state of mouse buttons */
               ds.b 1                           /* padding */
               .EXPORT V_HID_CNT
V_HID_CNT:     ds.w 1      /* (lineavars-$15a)  visibility of text cursor */
               .EXPORT CUR_X
CUR_X:         ds.w 1      /* (lineavars-$158)  x-position of mouse cursor */
               .EXPORT CUR_Y
CUR_Y:         ds.w 1      /* (lineavars-$156)  y-position of mouse cursor */
               .EXPORT CUR_FLAG
CUR_FLAG:      ds.b 1      /* (lineavars-$154)  flag for drawing mouse cursor */
               .EXPORT MOUSE_FLAG
MOUSE_FLAG:    ds.b 1      /* (lineavars-$153)  flag for mouse cursor */
               .EXPORT V_SAV_XY
V_SAV_XY:      ds.w 2      /* (lineavars-$152)  saved coordinates for ESC j */
               .EXPORT RETSAV
RETSAV:        ds.l 1      /* (lineavars-$14e) */
/* sprite save buffer for a maximum of 4 planes */
               .EXPORT SAVE_LEN
SAVE_LEN:      ds.w 1      /* (lineavars-$14a)  number of lines */
               .EXPORT SAVE_ADDR
SAVE_ADDR:     ds.l 1      /* (lineavars-$148)  background address */
               .EXPORT SAVE_STAT
SAVE_STAT:     ds.w 1      /* (lineavars-$144)  background status */
               .EXPORT SAVE_AREA
SAVE_AREA:     ds.l 64     /* (lineavars-$142)  background data */
/* VDI interrupt vectors */
               .EXPORT USER_TIM
USER_TIM:      ds.l 1      /* (lineavars-$042)  vector for vex_timv */
               .EXPORT NEXT_TIM
NEXT_TIM:      ds.l 1      /* (lineavars-$03e)  vector for vex_timv */
               .EXPORT USER_BUT
USER_BUT:      ds.l 1      /* (lineavars-$03a)  vector for vex_butv */
               .EXPORT USER_CUR
USER_CUR:      ds.l 1      /* (lineavars-$036)  vector for vex_curv */
               .EXPORT USER_MOT
USER_MOT:      ds.l 1      /* (lineavars-$032)  vector for vex_motv */
/* data for VT52 emulator */
               .EXPORT V_CEL_HT
V_CEL_HT:      ds.w 1      /* (lineavars-$02e)  character height */
               .EXPORT V_CEL_MX
V_CEL_MX:      ds.w 1      /* (lineavars-$02c)  number of columns -1 */
               .EXPORT V_CEL_MY
V_CEL_MY:      ds.w 1      /* (lineavars-$02a)  number of lines -1 */
               .EXPORT V_CEL_WR
V_CEL_WR:      ds.w 1      /* (lineavars-$028)  line length in bytes */
               .EXPORT V_COL_BG
V_COL_BG:      ds.w 1      /* (lineavars-$026)  text background color */
               .EXPORT V_COL_FG
V_COL_FG:      ds.w 1      /* (lineavars-$024)  text foreground color */
               .EXPORT V_CUR_AD
V_CUR_AD:      ds.l 1      /* (lineavars-$022)  current cursor address */
               .EXPORT V_CUR_OF
V_CUR_OF:      ds.w 1      /* (lineavars-$01e)  byte offset to screen start */
               .EXPORT V_CUR_XY
V_CUR_XY:      ds.w 2      /* (lineavars-$01c)  2 words X,Y */
V_CUR_XY0           EQU V_CUR_XY     ;x-Koordinate des Textcursors
V_CUR_XY1           EQU V_CUR_XY+2   ;y-Koordinate des Textcursors
               .EXPORT V_PERIOD
V_PERIOD:      ds.b 1      /* (lineavars-$018)  text cursor blink frequency */
               .EXPORT V_CUR_CT
V_CUR_CT:      ds.b 1      /* (lineavars-$017)  counter for blink */
               .EXPORT V_FNT_AD
V_FNT_AD:      ds.l 1      /* (lineavars-$016)  pointer to font image */
               .EXPORT V_FNT_ND
V_FNT_ND:      ds.w 1      /* (lineavars-$012)  index of first character */
               .EXPORT V_FNT_ST
V_FNT_ST:      ds.w 1      /* (lineavars-$010)  index of last character */
               .EXPORT V_FNT_WD
V_FNT_WD:      ds.w 1      /* (lineavars-$00e)  width of font image in bytes */
               .EXPORT V_REZ_HZ
V_REZ_HZ:      ds.w 1      /* (lineavars-$00c)  horizontal resolution */
               .EXPORT V_OFF_AD
V_OFF_AD:      ds.l 1      /* (lineavars-$00a)  pointer to offset table */
               .EXPORT V_STAT_0
V_STAT_0:      ds.b 1      /* (lineavars-$006) */
               .EXPORT V_DELAY
V_DELAY:       ds.b 1      /* (lineavars-$005) */
               .EXPORT V_REZ_VT
V_REZ_VT:      ds.w 1      /* (lineavars-$004)  vertical resolution */
               .EXPORT BYTES_LIN
BYTES_LIN:     ds.w 1      /* (lineavars-$002)  bytes per line */

/* Line-A variables */
               .EXPORT PLANES
PLANES:        ds.w 1      /* (lineavars+$000)  number of planes */
               .EXPORT WIDTH
WIDTH:         ds.w 1      /* (lineavars+$002)  number of bytes per line */
               .EXPORT CONTRL
CONTRL:        ds.l 1      /* (lineavars+$004)  pb.contrl */
               .EXPORT INTIN
INTIN:         ds.l 1      /* (lineavars+$008)  pb.intin */
               .EXPORT PTSIN
PTSIN:         ds.l 1      /* (lineavars+$00c)  pb.ptsin */
               .EXPORT INTOUT
INTOUT:        ds.l 1      /* (lineavars+$010)  pb.intout */
               .EXPORT PTSOUT
PTSOUT:        ds.l 1      /* (lineavars+$014)  pb.ptsout */
/* flags for planar output */
               .EXPORT COLBIT0
COLBIT0:       ds.w 1      /* (lineavars+$018)  use plane 0 */
               .EXPORT COLBIT1
COLBIT1:       ds.w 1      /* (lineavars+$01a)  use plane 1 */
               .EXPORT COLBIT2
COLBIT2:       ds.w 1      /* (lineavars+$01c)  use plane 2 */
               .EXPORT COLBIT3
COLBIT3:       ds.w 1      /* (lineavars+$01e)  use plane 3 */
/* line data */
               .EXPORT LSTLIN
LSTLIN:        ds.w 1      /* (lineavars+$020)  flag for setting line end points */
               .EXPORT LNMASK
LNMASK:        ds.w 1      /* (lineavars+$022)  line pattern */
               .EXPORT WMODE
WMODE:         ds.w 1      /* (lineavars+$024)  0 = REPLACE, 1 = TRANSPARENT, */
WMODE_LOW           EQU WMODE+1              /* 2 = XOR    , 3 = NOT TRANSPARENT */
/* line coordinates */
               .EXPORT X1
X1:            ds.w 1      /* (lineavars+$026)  x1 */
               .EXPORT Y1
Y1:            ds.w 1      /* (lineavars+$028)  y1 */
               .EXPORT X2
X2:            ds.w 1      /* (lineavars+$02a)  x2 */
               .EXPORT Y2
Y2:            ds.w 1      /* (lineavars+$02c)  y2 */
/* fill pattern data */
               .EXPORT PATPTR
PATPTR:        ds.l 1      /* (lineavars+$02e)  fill pattern address */
               .EXPORT PATMSK
PATMSK:        ds.w 1      /* (lineavars+$032)  number of lines for pattern */
               .EXPORT MFILL
MFILL:         ds.w 1      /* (lineavars+$034)  pattern color fill flag */
/* clipping data */
               .EXPORT CLIP
CLIP:          ds.w 1      /* (lineavars+$036)  clipping flag */
               .EXPORT XMINCL
XMINCL:        ds.w 1      /* (lineavars+$038)  clip_xmin */
               .EXPORT YMINCL
YMINCL:        ds.w 1      /* (lineavars+$03a)  clip_ymin */
               .EXPORT XMAXCL
XMAXCL:        ds.w 1      /* (lineavars+$03c)  clip_xmax */
               .EXPORT YMAXCL
YMAXCL:        ds.w 1      /* (lineavars+$03e)  clip_ymax */
/* text blit variables */
               .EXPORT XDDA
XDDA:          ds.w 1      /* (lineavars+$040)  0x8000 fuer TEXTBLT (??) */
               .EXPORT DDAINC
DDAINC:        ds.w 1      /* (lineavars+$042)  scale factor */
               .EXPORT SCALDIR
SCALDIR:       ds.w 1      /* (lineavars+$044)  scale direction */
               .EXPORT MONO
MONO:          ds.w 1      /* (lineavars+$046)  flag for monospaced font */
               .EXPORT SOURCEX
SOURCEX:       ds.w 1      /* (lineavars+$048)  source x-coordinate */
               .EXPORT SOURCEY
SOURCEY:       ds.w 1      /* (lineavars+$04a)  source y-coordinate */
               .EXPORT DESTX
DESTX:         ds.w 1      /* (lineavars+$04c)  dest x-coordinate */
               .EXPORT DESTY
DESTY:         ds.w 1      /* (lineavars+$04e)  dest y-coordinate */
               .EXPORT DELX
DELX:          ds.w 1      /* (lineavars+$050)  width of character */
               .EXPORT DELY
DELY:          ds.w 1      /* (lineavars+$052)  height of chaarcter */
               .EXPORT FBASE
FBASE:         ds.l 1      /* (lineavars+$054)  font base */
               .EXPORT FWIDTH
FWIDTH:        ds.w 1      /* (lineavars+$058)  font image width in bytes */
               .EXPORT STYLE
STYLE:         ds.w 1      /* (lineavars+$05a)  text effects */
STYLELO             EQU STYLE+1
               .EXPORT LITEMASK
LITEMASK:      ds.w 1      /* (lineavars+$05c)  mask for light text */
               .EXPORT SKEWMASK
SKEWMASK:      ds.w 1      /* (lineavars+$05e)  mask for italic text */
               .EXPORT WEIGHT
WEIGHT:        ds.w 1      /* (lineavars+$060)  enlargement for bold text */
               .EXPORT ROFF
ROFF:          ds.w 1      /* (lineavars+$062)  right offset for italic */
               .EXPORT LOFF
LOFF:          ds.w 1      /* (lineavars+$064)  left offset for italic */
               .EXPORT SCALE
SCALE:         ds.w 1      /* (lineavars+$066)  scale flag */
               .EXPORT CHUP
CHUP:          ds.w 1      /* (lineavars+$068)  rotation angle */
               .EXPORT TEXTFG
TEXTFG:        ds.w 1      /* (lineavars+$06a)  foreground color */
               .EXPORT SCRTCHP
SCRTCHP:       ds.l 1      /* (lineavars+$06c)  address of text effect buffer */
               .EXPORT SCRPT2
SCRPT2:        ds.w 1      /* (lineavars+$070)  address of text 2nd buffer */
               .EXPORT TEXTBG
TEXTBG:        ds.w 1      /* (lineavars+$072)  background color */
               .EXPORT COPYTRAN
COPYTRAN:      ds.w 1      /* (lineavars+$074)  flag for vrt_cpyfm vs. vro_cpfm */
               .EXPORT SEEDABORT
SEEDABORT:     ds.l 1      /* (lineavars+$076)  user abort function for seed fill */
               ds.b 52  /* device dep. function ptr in TOS */
               .EXPORT REQ_COL_X
REQ_COL_X:     ds.w 240*3  /* (lineavars+$0ae)  color values for colors 16-255 */
               .EXPORT SSB_ADDR
SSB_ADDR:      ds.l 1      /* (lineavars+$64e)  pointer to SSB */
               .EXPORT LINEA_COLPLANES
LINEA_COLPLANES: ds.l 1    /* (lineavars+$652)  plane color flags */
               .EXPORT COLBIT4
COLBIT4:       ds.w 1      /* (lineavars+$656)  use plane 4 */
               .EXPORT COLBIT5
COLBIT5:       ds.w 1      /* (lineavars+$658)  use plane 5 */
               .EXPORT COLBIT6
COLBIT6:       ds.w 1      /* (lineavars+$65a)  use plane 6 */
               .EXPORT COLBIT7
COLBIT7:       ds.w 1      /* (lineavars+$65c)  use plane 7 */
               .EXPORT SAVLEN
/* sprite save buffer for a maximum of 8 planes */
SAVLEN:        ds.w 1      /* (lineavars+$65e)  number of lines */
               .EXPORT SAVADDR
SAVADDR:       ds.l 1      /* (lineavars+$660)  background address */
               .EXPORT SAVSTAT
SAVSTAT:       ds.w 1      /* (lineavars+$664)  background status */
               .EXPORT SAVAREA
SAVAREA:       ds.w 256    /* (lineavars+$666)  background data */

;BitBlt-Struktur
B_WD                EQU 0                   ;Breite des Blocks
B_HT                EQU 2                   ;Hoehe des Blocks
PLANE_CT            EQU 4                   ;Anzahl der Ebenen
FG_COL              EQU 6                   ;Vordergrundfarbe
BG_COL              EQU 8                   ;Hintergrundfarbe
OP_TAB              EQU 10                  ;Verknuepfungsmodi
S_XMIN              EQU 14                  ;X-Koordinate des Quellrasters
S_YMIN              EQU 16                  ;Y-Koordinate des Quellrasters
S_FORM              EQU 18                  ;Zeiger aufs Quellraster
S_NXWD              EQU 22                  ;Bytes zum naechsten Wort der Ebene
S_NXLN              EQU 24                  ;Breite des Quellrasters in Bytes
S_NXPL              EQU 26                  ;Abstand zur naechsten Quellebene
D_XMIN              EQU 28                  ;X-Koordinate des Zielrasters
D_YMIN              EQU 30                  ;Y-Koordinate des Zielrasters
D_FORM              EQU 32                  ;Zeiger aufs Zielraster
D_NXWD              EQU 36                  ;Bytes zum naechsten Wort der Ebene
D_NXLN              EQU 38                  ;Breite des Zielrasters in Bytes
D_NXPL              EQU 40                  ;Abstand zur naechsten Zielebene
P_ADDR              EQU 42                  ;Zeiger aufs Muster oder 0
P_NXLN              EQU 46                  ;Abstand zur naechsten Musterzeile
P_NXPL              EQU 48                  ;Abstand zur naechsten Musterebene
P_MASK              EQU 50                  ;(Musterlaenge -2) * Ebenenanzahl

;bit numbers for vt52 cursor state V_STAT_0
CURSOR_BL           EQU 0                   ;blink enabled
CURSOR_STATE        EQU 1                   ;currently visible
CURSOR_ONOFF        EQU 2                   ;cursor enabled (unused)
WRAP                EQU 3                   ;wrap at eol
INVERSE             EQU 4                   ;reverse video
CURSOR_SAVED        EQU 5                   ;cursor position was saved
