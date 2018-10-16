/*
 * resource set indices for tslice
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        9
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        19
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          612
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "tslice"
#endif
#undef RSC_ID
#ifdef tslice
#define RSC_ID tslice
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 9
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 19
#define NUM_TREE 1
#endif



#define MAIN                               0 /* form/dialog */
#define SAVE                               3 /* BUTTON in tree MAIN */
#define OK                                 4 /* BUTTON in tree MAIN */
#define CANCEL                             5 /* BUTTON in tree MAIN */
#define TITLE                              6 /* BUTTON in tree MAIN */
#define PREEMPTIVE                         7 /* BUTTON in tree MAIN */
#define CONFIG_BOX                         8 /* IBOX in tree MAIN */
#define LF_1                              10 /* BOXCHAR in tree MAIN */
#define BG_1                              11 /* BOX in tree MAIN */
#define SLIDER_1                          12 /* BUTTON in tree MAIN */
#define RT_1                              13 /* BOXCHAR in tree MAIN */
#define LF_2                              15 /* BOXCHAR in tree MAIN */
#define BG_2                              16 /* BOX in tree MAIN */
#define SLIDER_2                          17 /* BUTTON in tree MAIN */
#define RT_2                              18 /* BOXCHAR in tree MAIN */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD tslice_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD tslice_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD tslice_rsc_free(void);
#endif
