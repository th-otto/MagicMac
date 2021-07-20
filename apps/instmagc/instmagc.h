/*
 * resource set indices for instmagc
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        38
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   17
 * Number of Free Images:    0
 * Number of Objects:        25
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          1746
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "instmagc"
#endif
#undef RSC_ID
#ifdef instmagc
#define RSC_ID instmagc
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 38
#define NUM_FRSTR 17
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 0
#define NUM_OBS 25
#define NUM_TREE 1
#endif



#define TREE_PERSONALIZE   0 /* form/dialog */
#define O_PERS_LWA         5 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWB         6 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWC         7 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWD         8 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWE         9 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWF        10 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWG        11 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWH        12 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWI        13 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWJ        14 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWK        15 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_LWL        16 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_INSTALL    17 /* BUTTON in tree TREE_PERSONALIZE */
#define O_PERS_ABBRUCH    18 /* BUTTON in tree TREE_PERSONALIZE */
#define O_ACTION          19 /* STRING in tree TREE_PERSONALIZE */
#define O_PATH            20 /* STRING in tree TREE_PERSONALIZE */
#define EXTRAS_Y          23 /* BUTTON in tree TREE_PERSONALIZE */
#define EXTRAS_N          24 /* BUTTON in tree TREE_PERSONALIZE */

#define FERTIG             0 /* Alert string */

#define ERR_EXTRAS         1 /* Alert string */

#define ERR_CPX            2 /* Alert string */

#define WAS_EWRITF         3 /* Alert string */

#define ERR_RSC            4 /* Alert string */

#define ERR_RAM            5 /* Alert string */

#define ERR_INF            6 /* Alert string */

#define DISK_2             7 /* Alert string */

#define ERR_COPY           8 /* Alert string */

#define INF_REN            9 /* Alert string */

#define ERR_CREATING      10 /* Alert string */

#define DISKFULL          11 /* Alert string */

#define WCOLOR            12 /* Alert string */

#define CPX_FOLDER        13 /* Alert string */

#define CRFOLDER          14 /* Free string */

#define WRITING           15 /* Free string */

#define READING           16 /* Free string */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD instmagc_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD instmagc_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD instmagc_rsc_free(void);
#endif
