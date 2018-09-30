/*
 * resource set indices for magxconf
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        10
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        13
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          502
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "magxconf"
#endif
#undef RSC_ID
#ifdef magxconf
#define RSC_ID magxconf
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 10
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 13
#define NUM_TREE 1
#endif



#define MAIN                               0 /* form/dialog */
#define VERSION                            1 /* BUTTON in tree MAIN */
#define CF_FASTLOAD                        2 /* BUTTON in tree MAIN */
#define CF_TOSCOMPAT                       3 /* BUTTON in tree MAIN */
#define CF_SMARTREDRAW                     4 /* BUTTON in tree MAIN */
#define CF_GROWBOX                         5 /* BUTTON in tree MAIN */
#define CF_FLOPPY_DMA                      6 /* BUTTON in tree MAIN */
#define CF_PULLDOWN                        7 /* BUTTON in tree MAIN */
#define SAVE                              10 /* BUTTON in tree MAIN */
#define OK                                11 /* BUTTON in tree MAIN */
#define CANCEL                            12 /* BUTTON in tree MAIN */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD magxconf_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD magxconf_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD magxconf_rsc_free(void);
#endif
