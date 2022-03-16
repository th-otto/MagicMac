/*
 * resource set indices for chgres
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        84
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       14
 * Number of Free Strings:   2
 * Number of Free Images:    0
 * Number of Objects:        64
 * Number of Trees:          5
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          6208
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
#define NUM_STRINGS 84
#define NUM_FRSTR 2
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 14
#define NUM_OBS 64
#define NUM_TREE 5
#endif



#define MAIN_DIALOG                        0 /* form/dialog */
#define CHGRES_ICON                        1 /* CICON in tree MAIN_DIALOG */
#define CHGRES_COLORS                      3 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_BOX                         4 /* IBOX in tree MAIN_DIALOG */
#define CHGRES_BOX_FIRST                   5 /* TEXT in tree MAIN_DIALOG */
#define CHGRES_BOX_LAST                   14 /* TEXT in tree MAIN_DIALOG */
#define CHGRES_UP                         15 /* BOXCHAR in tree MAIN_DIALOG */
#define CHGRES_BACK                       16 /* BOX in tree MAIN_DIALOG */
#define CHGRES_SLIDER                     17 /* BOX in tree MAIN_DIALOG */
#define CHGRES_DOWN                       18 /* BOXCHAR in tree MAIN_DIALOG */
#define CHGRES_OK                         19 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_CANCEL                     20 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_INFO                       21 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_SAVE                       22 /* BUTTON in tree MAIN_DIALOG */

#define INFO_DIALOG                        1 /* form/dialog */
#define INFO_VIRT_BOX                      1 /* BUTTON in tree INFO_DIALOG */
#define INFO_VIRT_HRES                     2 /* FTEXT in tree INFO_DIALOG */
#define INFO_VIRT_VRES                     3 /* FTEXT in tree INFO_DIALOG */
#define INFO_OK                            6 /* BUTTON in tree INFO_DIALOG */
#define INFO_CANCEL                        7 /* BUTTON in tree INFO_DIALOG */
#define INFO_HRES                         12 /* STRING in tree INFO_DIALOG */
#define INFO_VRES                         13 /* STRING in tree INFO_DIALOG */
#define INFO_STR_PULSE                    14 /* STRING in tree INFO_DIALOG */
#define INFO_FREQ                         15 /* STRING in tree INFO_DIALOG */
#define INFO_STR_MHZ                      16 /* STRING in tree INFO_DIALOG */
#define INFO_STR_FREQ                     19 /* STRING in tree INFO_DIALOG */
#define INFO_STR_HZ                       20 /* STRING in tree INFO_DIALOG */

#define ERR_RESCHG                         2 /* form/dialog */

#define ERR_VIRTUAL_RES                    3 /* form/dialog */

#define ERR_RES_TOO_LARGE                  4 /* form/dialog */

#define FS_CHANGE_RES                      0 /* Free string */

#define FS_VIRTUAL                         1 /* Free string */




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
