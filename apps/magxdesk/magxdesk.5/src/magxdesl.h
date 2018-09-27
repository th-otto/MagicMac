/*
 * resource set indices for magxdesl
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        69
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   0
 * Number of Free Images:    0
 * Number of Objects:        78
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          3302
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "magxdesl"
#endif
#undef RSC_ID
#ifdef magxdesl
#define RSC_ID magxdesl
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 69
#define NUM_FRSTR 0
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 78
#define NUM_TREE 1
#endif



#define TREE1      0 /* menu */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD magxdesl_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD magxdesl_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD magxdesl_rsc_free(void);
#endif
