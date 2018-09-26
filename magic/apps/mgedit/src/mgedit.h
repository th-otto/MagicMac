/*
 * resource set indices for mgedit
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        105
 * Number of Bitblks:        1
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       23
 * Number of Free Strings:   7
 * Number of Free Images:    0
 * Number of Objects:        63
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         1
 * Total file size:          3176
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "mgedit"
#endif
#undef RSC_ID
#ifdef mgedit
#define RSC_ID mgedit
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 105
#define NUM_FRSTR 7
#define NUM_UD 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 23
#define NUM_OBS 63
#define NUM_TREE 4
#endif



#define T_ABOUT            0 /* form/dialog */
#define ABOUT_VERSION      2 /* TEXT in tree T_ABOUT */ /* max len 12 */
#define ABOUT_OK           4 /* BUTTON in tree T_ABOUT */

#define T_MENU             1 /* menu */
#define MT_DESK            3 /* TITLE in tree T_MENU */
#define MT_FILE            4 /* TITLE in tree T_MENU */
#define MT_OPTIONS         5 /* TITLE in tree T_MENU */
#define MEN_ABOUT          8 /* STRING in tree T_MENU */
#define MEN_NEW           17 /* STRING in tree T_MENU */
#define MEN_OPEN          18 /* STRING in tree T_MENU */
#define MEN_CLOSE         20 /* STRING in tree T_MENU */
#define MEN_SAVE          21 /* STRING in tree T_MENU */
#define MEN_SAVEAS        22 /* STRING in tree T_MENU */
#define MEN_QUIT          24 /* STRING in tree T_MENU */
#define MEN_PREFS         26 /* STRING in tree T_MENU */

#define T_OPTIONS          2 /* form/dialog */
#define OPTIONS_OK         1 /* BUTTON in tree T_OPTIONS */
#define OPTIONS_CANCEL     2 /* BUTTON in tree T_OPTIONS */
#define OPTIONS_BCOLOUR    6 /* BOXTEXT in tree T_OPTIONS */ /* max len 0 */
#define OPTIONS_FONTNAME   7 /* FTEXT in tree T_OPTIONS */ /* max len 30 */
#define OPTIONS_FONTSIZE   8 /* FTEXT in tree T_OPTIONS */ /* max len 3 */
#define OPTIONS_SAVE       9 /* BUTTON in tree T_OPTIONS */
#define OPTIONS_TCOLOUR   11 /* BOXTEXT in tree T_OPTIONS */ /* max len 0 */
#define OPTIONS_TABWIDTH  12 /* FTEXT in tree T_OPTIONS */ /* max len 2 */

#define T_COLOUR           3 /* form/dialog */
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

#define ALRT_ERROPENWIND   0 /* Alert string */
/* [2][Fenster kann nicht ge”ffnet werden][Abbruch] */

#define STR_OPTIONTITLE    1 /* Free string */
/* Voreinstellungen */

#define STR_LOADFILE       2 /* Free string */
/* Datei laden... */

#define STR_SAVEFILE       3 /* Free string */
/* Datei sichern... */

#define STR_SAVEBLOCK      4 /* Free string */
/* Block sichern... */

#define ALRT_SAVEFILE      5 /* Alert string */
/* [2][Datei %s|wurde ge„ndert. Sichern?][Ja|Nein|Abbruch] */

#define STR_NONAME         6 /* Free string */
/* Namenlos */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD mgedit_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD mgedit_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD mgedit_rsc_free(void);
#endif
