/*
 * resource set indices for pdsmprsc
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        40
 * Number of Bitblks:        0
 * Number of Iconblks:       3
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   4
 * Number of Free Images:    0
 * Number of Objects:        45
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         6
 * Total file size:          2890
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "pdsmprsc"
#endif
#undef RSC_ID
#ifdef pdsmprsc
#define RSC_ID pdsmprsc
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 40
#define NUM_FRSTR 4
#define NUM_UD 0
#define NUM_IMAGES 6
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 3
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 45
#define NUM_TREE 4
#endif



#define MENU               0 /* menu */
#define MFILE              4 /* TITLE in tree MENU */
#define DCLOSE            18 /* STRING in tree MENU */
#define DLAYOUT           20 /* STRING in tree MENU */
#define DPAPER            21 /* STRING in tree MENU */
#define DPRINT            22 /* STRING in tree MENU */
#define DQUIT             24 /* STRING in tree MENU */

#define MY_SPECIAL_DLG1    1 /* form/dialog */
#define PO_BG_PRINTING     1 /* BUTTON in tree MY_SPECIAL_DLG1 */
#define MYSP_FARBKEIL1     3 /* BUTTON in tree MY_SPECIAL_DLG1 */
#define MYSP_PUSH_ME1      8 /* BUTTON in tree MY_SPECIAL_DLG1 */
#define PUSH_ME_ICON1      9 /* ICON in tree MY_SPECIAL_DLG1 */ /* max len 1 */

#define MY_SPECIAL_DLG2    2 /* form/dialog */

#define ICON_DIALOG        3 /* form/dialog */
#define PI_MY_SPECIAL1     1 /* ICON in tree ICON_DIALOG */ /* max len 12 */
#define PI_MY_SPECIAL2     2 /* ICON in tree ICON_DIALOG */ /* max len 12 */

#define LAYOUT_ALERT       0 /* Alert string */
/* [3][Here the program should offer|a layout dialog for the document.][ OK ] */

#define PRINT_ALERT        1 /* Alert string */
/* [3][Now the printer would be opened|and the document printed.][ OK ] */

#define S_NONAME           2 /* Free string */
/* no name */

#define AL_WDIALOG         3 /* Alert string */
/* [1][Please run the system extension|WDIALOG.PRG][Quit] */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD pdsmprsc_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD pdsmprsc_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD pdsmprsc_rsc_free(void);
#endif
