/*
 * resource set indices for fontslct
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        77
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       23
 * Number of Free Strings:   1
 * Number of Free Images:    0
 * Number of Objects:        51
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          2338
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "fontslct"
#endif
#undef RSC_ID
#ifdef fontslct
#define RSC_ID fontslct
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 77
#define NUM_FRSTR 1
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 23
#define NUM_OBS 51
#define NUM_TREE 1
#endif



#define FONTSL             0 /* form/dialog */
#define FSAMPLE            1 /* BOX in tree FONTSL */
#define FNAME_UP           2 /* BOXCHAR in tree FONTSL */
#define FSTL_UP            3 /* BOXCHAR in tree FONTSL */
#define FNAME_BOX          4 /* IBOX in tree FONTSL */
#define FNAME_0            5 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_1            6 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_2            7 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_3            8 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_4            9 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_5           10 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_6           11 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_7           12 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_8           13 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_9           14 /* TEXT in tree FONTSL */ /* max len 20 */
#define FNAME_10          15 /* TEXT in tree FONTSL */ /* max len 20 */
#define FSTL_BOX          16 /* IBOX in tree FONTSL */
#define FSTL_1            17 /* TEXT in tree FONTSL */ /* max len 10 */
#define FSTL_2            18 /* TEXT in tree FONTSL */ /* max len 10 */
#define FSTL_0            19 /* TEXT in tree FONTSL */ /* max len 10 */
#define FSTL_3            20 /* TEXT in tree FONTSL */ /* max len 10 */
#define FNAME_BACK        21 /* BOX in tree FONTSL */
#define FNAME_WHITE       22 /* BOX in tree FONTSL */
#define CHECK_STYLE       23 /* BOX in tree FONTSL */
#define FSTL_BACK         24 /* BOX in tree FONTSL */
#define FSTL_WHITE        25 /* BOX in tree FONTSL */
#define FSTL_DOWN         26 /* BOXCHAR in tree FONTSL */
#define FPT_UP            27 /* BOXCHAR in tree FONTSL */
#define CHECK_NAME        28 /* BOX in tree FONTSL */
#define FPT_BOX           29 /* IBOX in tree FONTSL */
#define FPT_0             30 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_1             31 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_2             32 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_3             33 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_4             34 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_5             35 /* TEXT in tree FONTSL */ /* max len 4 */
#define FPT_BACK          37 /* BOX in tree FONTSL */
#define FPT_WHITE         38 /* BOX in tree FONTSL */
#define FPT_USER          39 /* FTEXT in tree FONTSL */ /* max len 5 */
#define CHECK_SIZE        40 /* BOX in tree FONTSL */
#define F_BH_STRING       41 /* STRING in tree FONTSL */
#define CHECK_RATIO       42 /* BOX in tree FONTSL */
#define F_BH              43 /* FTEXT in tree FONTSL */ /* max len 4 */
#define FNAME_DOWN        44 /* BOXCHAR in tree FONTSL */
#define FPT_DOWN          45 /* BOXCHAR in tree FONTSL */
#define FSET              46 /* BUTTON in tree FONTSL */
#define FMARK             47 /* BUTTON in tree FONTSL */
#define FOPTIONS          48 /* BUTTON in tree FONTSL */
#define FOK               49 /* BUTTON in tree FONTSL */
#define FCANCEL           50 /* BUTTON in tree FONTSL */

#define FONTSL_NAME        0 /* Free string */
/*  Select Font  */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD fontslct_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD fontslct_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD fontslct_rsc_free(void);
#endif
