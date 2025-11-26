/*
 * resource set indices for chgres
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        99
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       14
 * Number of Free Strings:   5
 * Number of Free Images:    0
 * Number of Objects:        79
 * Number of Trees:          8
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          6878
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
#define NUM_STRINGS 99
#define NUM_FRSTR 5
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 14
#define NUM_OBS 79
#define NUM_TREE 8
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
#define CHGRES_INFO                       19 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_NEW                        20 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_OK                         21 /* BUTTON in tree MAIN_DIALOG */
#define CHGRES_CANCEL                     22 /* BUTTON in tree MAIN_DIALOG */

#define INFO_DIALOG                        1 /* form/dialog */
#define INFO_HRES                          4 /* STRING in tree INFO_DIALOG */
#define INFO_VRES                          7 /* STRING in tree INFO_DIALOG */
#define INFO_FREQ                         10 /* STRING in tree INFO_DIALOG */
#define INFO_STR_HZ                       11 /* STRING in tree INFO_DIALOG */
#define INFO_VIRT_BOX                     12 /* BUTTON in tree INFO_DIALOG */
#define INFO_VIRT_HRES                    13 /* FTEXT in tree INFO_DIALOG */
#define INFO_VIRT_VRES                    14 /* FTEXT in tree INFO_DIALOG */
#define INFO_OK                           15 /* BUTTON in tree INFO_DIALOG */

#define ERR_VIRTUAL_RES                    2 /* form/dialog */

#define ERR_RES_TOO_LARGE                  3 /* form/dialog */

#define NEW_RES                            4 /* form/dialog */
#define NEW_HRES                           2 /* FTEXT in tree NEW_RES */
#define NEW_VRES                           3 /* FTEXT in tree NEW_RES */
#define NEWRES_OK                          4 /* BUTTON in tree NEW_RES */
#define NEWRES_CANCEL                      5 /* BUTTON in tree NEW_RES */

#define ERR_RES                            5 /* form/dialog */

#define RES_DELETE                         6 /* form/dialog */
#define RES_DELETE_OK                      4 /* BUTTON in tree RES_DELETE */
#define RES_DELETE_CANCEL                  5 /* BUTTON in tree RES_DELETE */

#define ERR_RESCHG                         7 /* form/dialog */

#define FS_CHANGE_RES                      0 /* Free string */

#define FS_VIRTUAL                         1 /* Free string */

#define FS_LOW                             2 /* Free string */

#define FS_MED                             3 /* Free string */

#define FS_HIGH                            4 /* Free string */




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
