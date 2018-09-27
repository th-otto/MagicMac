/*
 * resource set indices for mgnotice
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        94
 * Number of Bitblks:        1
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       21
 * Number of Free Strings:   4
 * Number of Free Images:    0
 * Number of Objects:        59
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         1
 * Total file size:          2826
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "mgnotice"
#endif
#undef RSC_ID
#ifdef mgnotice
#define RSC_ID mgnotice
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 94
#define NUM_FRSTR 4
#define NUM_UD 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 21
#define NUM_OBS 59
#define NUM_TREE 4
#endif



#define T_ABOUT            0 /* form/dialog */
#define ABOUT_VERSION      2 /* TEXT in tree T_ABOUT */ /* max len 12 */
#define ABOUT_OK           4 /* BUTTON in tree T_ABOUT */

#define T_MENU             1 /* menu */
#define MT_DESK            3 /* TITLE in tree T_MENU */
#define MT_FILE            4 /* TITLE in tree T_MENU */
#define MT_OPTIONS         5 /* TITLE in tree T_MENU */
#define M_ABOUT            8 /* STRING in tree T_MENU */
#define M_NEW             17 /* STRING in tree T_MENU */
#define M_DELETE          18 /* STRING in tree T_MENU */
#define M_QUIT            20 /* STRING in tree T_MENU */
#define M_FONT            22 /* STRING in tree T_MENU */
#define M_COLOUR          23 /* STRING in tree T_MENU */
#define M_PREFS           25 /* STRING in tree T_MENU */

#define T_COLOUR           2 /* form/dialog */
#define COL_0              1 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_1              2 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_2              3 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_3              4 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_4              5 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_5              6 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_6              7 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_7              8 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_8              9 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_9             10 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_10            11 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_11            12 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_12            13 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_13            14 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_14            15 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */
#define COL_15            16 /* BOXTEXT in tree T_COLOUR */ /* max len 0 */

#define T_OPTIONS          3 /* form/dialog */
#define OPTIONS_OK         1 /* BUTTON in tree T_OPTIONS */
#define OPTIONS_CANCEL     2 /* BUTTON in tree T_OPTIONS */
#define OPTIONS_COLOUR     6 /* BOXTEXT in tree T_OPTIONS */ /* max len 0 */
#define OPTIONS_FONTNAME   7 /* FTEXT in tree T_OPTIONS */ /* max len 30 */
#define OPTIONS_FONTSIZE   8 /* FTEXT in tree T_OPTIONS */ /* max len 3 */
#define OPTIONS_SAVE       9 /* BUTTON in tree T_OPTIONS */

#define ALRT_ERROPENWIND   0 /* Alert string */
/* [2][Impossible d'ouvrir la fenˆtre!][Abandon] */

#define STR_CREATENOTICE   1 /* Free string */
/* Entrer notice */

#define STR_OPTIONTITLE    2 /* Free string */
/* R‚glages */

#define STR_CHANGENOTICE   3 /* Free string */
/* Modifier notice */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD mgnotice_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD mgnotice_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD mgnotice_rsc_free(void);
#endif
