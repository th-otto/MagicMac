/*
 * resource set indices for chgres
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        37
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       10
 * Number of Free Strings:   1
 * Number of Free Images:    0
 * Number of Objects:        22
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          4318
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "chgres"
#endif
#undef RSC_ID
#ifdef chgres
#define RSC_ID chgres
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 37
#define NUM_FRSTR 1
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 10
#define NUM_OBS 22
#define NUM_TREE 1
#endif



#define MAIN_DIALOG                        0 /* form/dialog */
#define CHGRES_ICON                        1 /* CICON in tree MAIN_DIALOG */ /* max len 1 */
#define CHGRES_COLORS                      3 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_BOX                         4 /* IBOX in tree MAIN_DIALOG */
#define CHGRES_BOX_FIRST                   5 /* TEXT in tree MAIN_DIALOG */ /* max len 34 */
#define CHGRES_BOX_LAST                   14 /* TEXT in tree MAIN_DIALOG */ /* max len 34 */
#define CHGRES_UP                         15 /* BOXCHAR in tree MAIN_DIALOG */
#define CHGRES_BACK                       16 /* BOX in tree MAIN_DIALOG */
#define CHGRES_SLIDER                     17 /* BOX in tree MAIN_DIALOG */
#define CHGRES_DOWN                       18 /* BOXCHAR in tree MAIN_DIALOG */
#define CHGRES_SAVE                       19 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_OK                         20 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_CANCEL                     21 /* BUTTON in tree MAIN_DIALOG */

#define FS_CHANGE_RES                      0 /* Free string */
/*  Aufl”sung „ndern  */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD chgres_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD chgres_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD chgres_rsc_free(void);
#endif
