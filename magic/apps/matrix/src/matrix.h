/*
 * resource set indices for matrix
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        107
 * Number of Bitblks:        0
 * Number of Iconblks:       13
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       12
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        101
 * Number of Trees:          8
 * Number of Userblks:       0
 * Number of Images:         26
 * Total file size:          9340
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "matrix"
#endif
#undef RSC_ID
#ifdef matrix
#define RSC_ID matrix
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 107
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 26
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 13
#define NUM_CIB 0
#define NUM_TI 12
#define NUM_OBS 101
#define NUM_TREE 8
#endif



#define HAUPTMEN   0 /* menu */
#define DATEIMEN   4 /* TITLE in tree HAUPTMEN */
#define EDITMEN    5 /* TITLE in tree HAUPTMEN */
#define VERSCMEN   6 /* TITLE in tree HAUPTMEN */
#define UMWANMEN   7 /* TITLE in tree HAUPTMEN */
#define OEFFNEN   19 /* STRING in tree HAUPTMEN */
#define SCHLIESS  20 /* STRING in tree HAUPTMEN */
#define SPEI_ALS  21 /* STRING in tree HAUPTMEN */
#define ABBRUCH   22 /* STRING in tree HAUPTMEN */
#define DIMENSIO  24 /* STRING in tree HAUPTMEN */
#define NACHKOMM  25 /* STRING in tree HAUPTMEN */
#define MNORMEN   26 /* STRING in tree HAUPTMEN */
#define DETERMIN  28 /* STRING in tree HAUPTMEN */
#define CHARPOL   29 /* STRING in tree HAUPTMEN */
#define MNORM     30 /* STRING in tree HAUPTMEN */
#define KONDZAHL  31 /* STRING in tree HAUPTMEN */
#define OBDIAGON  33 /* STRING in tree HAUPTMEN */
#define HESSFORM  34 /* STRING in tree HAUPTMEN */
#define LGSLOES   35 /* STRING in tree HAUPTMEN */
#define TRANSPON  36 /* STRING in tree HAUPTMEN */
#define INVERT    37 /* STRING in tree HAUPTMEN */
#define NEG       38 /* STRING in tree HAUPTMEN */
#define ZEI_VERT  40 /* STRING in tree HAUPTMEN */
#define SPA_VERT  41 /* STRING in tree HAUPTMEN */
#define RUNDEN    42 /* STRING in tree HAUPTMEN */
#define ARITHMET  43 /* STRING in tree HAUPTMEN */

#define BILDER     1 /* form/dialog */
#define A_MATRIX   1 /* ICON in tree BILDER */ /* max len 7 */
#define B_MATRIX   2 /* ICON in tree BILDER */ /* max len 7 */
#define C_MATRIX   3 /* ICON in tree BILDER */ /* max len 7 */
#define D_MATRIX   4 /* ICON in tree BILDER */ /* max len 7 */
#define E_MATRIX   5 /* ICON in tree BILDER */ /* max len 8 */
#define F_MATRIX   6 /* ICON in tree BILDER */ /* max len 7 */
#define G_MATRIX   7 /* ICON in tree BILDER */ /* max len 7 */
#define H_MATRIX   8 /* ICON in tree BILDER */ /* max len 7 */
#define I_MATRIX   9 /* ICON in tree BILDER */ /* max len 7 */
#define J_MATRIX  10 /* ICON in tree BILDER */ /* max len 7 */
#define DRUCKER   11 /* ICON in tree BILDER */ /* max len 8 */
#define MIST      12 /* ICON in tree BILDER */ /* max len 8 */

#define NACHBOX    2 /* form/dialog */
#define NACH_OK    1 /* BUTTON in tree NACHBOX */
#define NACH_AB    2 /* BUTTON in tree NACHBOX */
#define NSTELLEN   3 /* FBOXTEXT in tree NACHBOX */ /* max len 0 */
#define NACHNAME   5 /* STRING in tree NACHBOX */

#define DIMBOX     3 /* form/dialog */
#define DIMNAME    1 /* STRING in tree DIMBOX */
#define DIM_VERT   2 /* FBOXTEXT in tree DIMBOX */ /* max len 0 */
#define DIM_HORI   3 /* FBOXTEXT in tree DIMBOX */ /* max len 0 */
#define DIM_OK     4 /* BUTTON in tree DIMBOX */
#define DIM_AB     5 /* BUTTON in tree DIMBOX */
#define SYMM       6 /* BUTTON in tree DIMBOX */

#define INFOBOX    4 /* form/dialog */
#define INFO_OK    5 /* BUTTON in tree INFOBOX */

#define ARITHBOX   5 /* form/dialog */
#define ARITH_OK   3 /* BUTTON in tree ARITHBOX */
#define ARITH_AB   4 /* BUTTON in tree ARITHBOX */
#define FORMEL1    6 /* FTEXT in tree ARITHBOX */ /* max len 0 */

#define VERTBOX    6 /* form/dialog */
#define VERTZAHL   1 /* FBOXTEXT in tree VERTBOX */ /* max len 4 */
#define VERT_OK    2 /* BUTTON in tree VERTBOX */
#define VERT_AB    3 /* BUTTON in tree VERTBOX */
#define VERTNAME   4 /* STRING in tree VERTBOX */

#define NORMBOX    7 /* form/dialog */
#define NORM_ZS    1 /* BUTTON in tree NORMBOX */
#define NORM_SS    2 /* BUTTON in tree NORMBOX */
#define NORM_ES    3 /* BUTTON in tree NORMBOX */
#define NORM_OK    4 /* BUTTON in tree NORMBOX */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD matrix_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD matrix_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD matrix_rsc_free(void);
#endif
