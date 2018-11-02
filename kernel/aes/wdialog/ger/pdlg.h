/*
 * resource set indices for pdlg
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        156
 * Number of Bitblks:        21
 * Number of Iconblks:       7
 * Number of Color Iconblks: 2
 * Number of Color Icons:    2
 * Number of Tedinfos:       44
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        115
 * Number of Trees:          10
 * Number of Userblks:       0
 * Number of Images:         35
 * Total file size:          14904
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "pdlg"
#endif
#undef RSC_ID
#ifdef pdlg
#define RSC_ID pdlg
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 156
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 35
#define NUM_BB 21
#define NUM_FRIMG 0
#define NUM_IB 7
#define NUM_CIB 2
#define NUM_TI 44
#define NUM_OBS 115
#define NUM_TREE 10
#endif



#define MAIN_DIALOG                        0 /* form/dialog */
#define MAIN_SCROLLBOX                     1 /* BOX in tree MAIN_DIALOG */
#define MAIN_ICON0                         2 /* BOX in tree MAIN_DIALOG */
#define MAIN_ICON1                         3 /* BOX in tree MAIN_DIALOG */
#define MAIN_ICON2                         4 /* BOX in tree MAIN_DIALOG */
#define MAIN_ICON3                         5 /* BOX in tree MAIN_DIALOG */
#define MAIN_UP                            6 /* BOXCHAR in tree MAIN_DIALOG */
#define MAIN_BACK                          7 /* BOX in tree MAIN_DIALOG */
#define MAIN_SLIDER                        8 /* BOX in tree MAIN_DIALOG */
#define MAIN_DOWN                          9 /* BOXCHAR in tree MAIN_DIALOG */
#define MAIN_OK                           10 /* BUTTON in tree MAIN_DIALOG */
#define MAIN_CANCEL                       11 /* BUTTON in tree MAIN_DIALOG */
#define MAIN_SUBBOX                       12 /* IBOX in tree MAIN_DIALOG */

#define PAGE_DIALOG                        1 /* form/dialog */
#define PAGE_DEVICE_POPUP                  2 /* BOXTEXT in tree PAGE_DIALOG */ /* max len 30 */
#define PAGE_QUAL_POPUP                    5 /* BOXTEXT in tree PAGE_DIALOG */ /* max len 24 */
#define PAGE_COLOR_POPUP                   8 /* BOXTEXT in tree PAGE_DIALOG */ /* max len 15 */
#define PAGE_ALL                          11 /* BUTTON in tree PAGE_DIALOG */
#define PAGE_SELECT                       12 /* BUTTON in tree PAGE_DIALOG */
#define PAGE_FROM                         13 /* FTEXT in tree PAGE_DIALOG */ /* max len 4 */
#define PAGE_TO                           15 /* FTEXT in tree PAGE_DIALOG */ /* max len 4 */
#define PAGE_EVEN                         16 /* BUTTON in tree PAGE_DIALOG */
#define PAGE_ODD                          17 /* BUTTON in tree PAGE_DIALOG */
#define PAGE_COPIES                       18 /* FTEXT in tree PAGE_DIALOG */ /* max len 4 */

#define PAPER_DIALOG                       2 /* form/dialog */
#define PAPER_DEVICE_POPUP                 2 /* BOXTEXT in tree PAPER_DIALOG */ /* max len 30 */
#define PAPER_SIZE_POPUP                   5 /* BOXTEXT in tree PAPER_DIALOG */ /* max len 13 */
#define PAPER_QUAL_POPUP                   7 /* BOXTEXT in tree PAPER_DIALOG */ /* max len 14 */
#define PAPER_INTRAY_POPUP                10 /* BOXTEXT in tree PAPER_DIALOG */ /* max len 13 */
#define PAPER_OUTTRAY_POPUP               13 /* BOXTEXT in tree PAPER_DIALOG */ /* max len 13 */
#define PAPER_SCALE                       15 /* FTEXT in tree PAPER_DIALOG */ /* max len 3 */
#define PAPER_PORTRAIT                    16 /* BOX in tree PAPER_DIALOG */
#define PAPER_LANDSCAPE                   17 /* BOX in tree PAPER_DIALOG */

#define COLOR_DIALOG                       3 /* form/dialog */
#define COLOR_DEVICE_POPUP                 2 /* BOXTEXT in tree COLOR_DIALOG */ /* max len 30 */
#define COLOR_DITHER_POPUP                 5 /* BOXTEXT in tree COLOR_DIALOG */ /* max len 30 */
#define COLOR_CYAN                         8 /* BUTTON in tree COLOR_DIALOG */
#define COLOR_MAGENTA                     10 /* BUTTON in tree COLOR_DIALOG */
#define COLOR_YELLOW                      12 /* BUTTON in tree COLOR_DIALOG */
#define COLOR_BLACK                       14 /* BUTTON in tree COLOR_DIALOG */
#define COLOR_BRIGHTNESS_IMAGE            15 /* IMAGE in tree COLOR_DIALOG */
#define COLOR_BRIGHTNESS_BAR              16 /* BOX in tree COLOR_DIALOG */
#define COLOR_BRIGHTNESS_SLIDER           17 /* BOX in tree COLOR_DIALOG */
#define COLOR_BRIGHTNESS_TEXT             18 /* TEXT in tree COLOR_DIALOG */ /* max len 43 */
#define COLOR_CONTRAST_IMAGE              19 /* IMAGE in tree COLOR_DIALOG */
#define COLOR_CONTRAST_BAR                20 /* BOX in tree COLOR_DIALOG */
#define COLOR_CONTRAST_SLIDER             21 /* BOX in tree COLOR_DIALOG */
#define COLOR_CONTRAST_TEXT               22 /* TEXT in tree COLOR_DIALOG */ /* max len 43 */

#define DEVICE_DIALOG                      4 /* form/dialog */
#define DEVICE_DEVICE_POPUP                2 /* BOXTEXT in tree DEVICE_DIALOG */ /* max len 30 */
#define DEVICE_NAME_POPUP                  5 /* BOXTEXT in tree DEVICE_DIALOG */ /* max len 30 */
#define DEVICE_BACKGROUND                  8 /* BUTTON in tree DEVICE_DIALOG */
#define DEVICE_FOREGROUND                  9 /* BUTTON in tree DEVICE_DIALOG */

#define DITHER_DIALOG                      5 /* form/dialog */
#define DITHER_DEVICE_POPUP                2 /* BOXTEXT in tree DITHER_DIALOG */ /* max len 30 */
#define DITHER_DITHER_POPUP                5 /* BOXTEXT in tree DITHER_DIALOG */ /* max len 16 */
#define DITHER_COLOR_POPUP                 8 /* BOXTEXT in tree DITHER_DIALOG */ /* max len 16 */
#define DITHER_BACKGROUND                 11 /* BUTTON in tree DITHER_DIALOG */
#define DITHER_FOREGROUND                 12 /* BUTTON in tree DITHER_DIALOG */

#define EMPTY_DIALOG                       6 /* unknown form */

#define SUBDLG_ICONS                       7 /* unknown form */
#define ICON_GENERAL                       1 /* ICON in tree SUBDLG_ICONS */ /* max len 12 */
#define ICON_PAPER                         2 /* ICON in tree SUBDLG_ICONS */ /* max len 12 */
#define ICON_DITHER                        3 /* ICON in tree SUBDLG_ICONS */ /* max len 12 */
#define ICON_DEVICE                        4 /* ICON in tree SUBDLG_ICONS */ /* max len 12 */
#define ICON_OPTIONS                       5 /* ICON in tree SUBDLG_ICONS */ /* max len 12 */
#define ICON_PORTRAIT                      6 /* ICON in tree SUBDLG_ICONS */ /* max len 1 */
#define ICON_LANDSCAPE                     7 /* ICON in tree SUBDLG_ICONS */ /* max len 1 */

#define CICON_DIALOG                       8 /* form/dialog */
#define CICON_PORTRAIT                     1 /* CICON in tree CICON_DIALOG */ /* max len 1 */
#define CICON_LANDSCAPE                    2 /* CICON in tree CICON_DIALOG */ /* max len 1 */

#define RADIOBUTTONS_DIALOG                9 /* unknown form */
#define RADIO_LARGE_SELECTED               1 /* IMAGE in tree RADIOBUTTONS_DIALOG */
#define RADIO_LARGE_DESELECTED             2 /* IMAGE in tree RADIOBUTTONS_DIALOG */
#define RADIO_SMALL_DESELECTED             3 /* IMAGE in tree RADIOBUTTONS_DIALOG */
#define RADIO_SMALL_SELECTED               4 /* IMAGE in tree RADIOBUTTONS_DIALOG */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD pdlg_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD pdlg_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD pdlg_rsc_free(void);
#endif
