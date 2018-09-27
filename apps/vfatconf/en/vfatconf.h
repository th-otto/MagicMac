/*
 * resource set indices for vfatconf
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        8
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   3
 * Number of Free Images:    0
 * Number of Objects:        34
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          1118
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "vfatconf"
#endif
#undef RSC_ID
#ifdef vfatconf
#define RSC_ID vfatconf
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 8
#define NUM_FRSTR 3
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 34
#define NUM_TREE 1
#endif



#define T_SELECT           0 /* form/dialog */
#define PERMA              3 /* BUTTON in tree T_SELECT */
#define TEMPOR             4 /* BUTTON in tree T_SELECT */
#define CANCEL             5 /* BUTTON in tree T_SELECT */
#define OK                 6 /* BUTTON in tree T_SELECT */
#define LAUFWERKE          7 /* IBOX in tree T_SELECT */
#define DISKA              8 /* BOXCHAR in tree T_SELECT */
#define DISKZ             33 /* BOXCHAR in tree T_SELECT */

#define ALRT_WRTERR        0 /* Alert string */
/* [3][VFATCONF:|Save error.][Cancel] */

#define ALRT_NO_INF        1 /* Alert string */
/* [3][There is no MAGX.INF|on the boot disk.|Please first create one,|e.g. with MAGXDESK!][Cancel] */

#define ALRT_MEMERR        2 /* Alert string */
/* [3][Not enough memory for|loading MAGX.INF.][Cancel] */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD vfatconf_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD vfatconf_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD vfatconf_rsc_free(void);
#endif
