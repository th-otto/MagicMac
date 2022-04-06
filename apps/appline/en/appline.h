/*
 * resource set indices for appline
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        85
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       22
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        44
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          2212
 */

#ifdef RSC_NAME
#undef RSC_NAME
#endif
#ifndef __ALCYON__
#define RSC_NAME "appline"
#endif
#ifdef RSC_ID
#undef RSC_ID
#endif
#ifdef appline
#define RSC_ID appline
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 85
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 22
#define NUM_OBS 44
#define NUM_TREE 4
#endif



#define APPLINE_TREE                       0 /* unknown form */
#define CLOSER_BUTTON                      1 /* BOXTEXT in tree APPLINE_TREE */
#define FIRST_BUTTON                       2 /* BOXTEXT in tree APPLINE_TREE */

#define APP_POPUP                          1 /* unknown form */
#define APP_KILL                           1 /* STRING in tree APP_POPUP */
#define APP_QUIT                           2 /* STRING in tree APP_POPUP */
#define APP_FREEZE                         4 /* STRING in tree APP_POPUP */
#define APP_HIDEALL                        5 /* STRING in tree APP_POPUP */
#define APP_HIDE                           6 /* STRING in tree APP_POPUP */
#define APP_BOTTOM                         8 /* STRING in tree APP_POPUP */
#define APP_TOP                            9 /* STRING in tree APP_POPUP */
#define APP_MEM                           11 /* STRING in tree APP_POPUP */

#define MAIN_POPUP                         2 /* unknown form */
#define MAINP_SHOWALL                      1 /* STRING in tree MAIN_POPUP */
#define MAINP_UNHIDEALL                    2 /* STRING in tree MAIN_POPUP */
#define MAINP_QUIT                         4 /* STRING in tree MAIN_POPUP */

#define STRINGS                            3 /* unknown form */
#define ST_UNFREEZE                        1 /* STRING in tree STRINGS */
#define ST_FREEZE                          2 /* STRING in tree STRINGS */
#define ST_SHOWSEL                         3 /* STRING in tree STRINGS */
#define ST_SHOWALL                         4 /* STRING in tree STRINGS */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD appline_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD appline_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD appline_rsc_free(void);
#endif
