/*
 * resource set indices for tslice
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        39
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   30
 * Number of Free Images:    0
 * Number of Objects:        19
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          1310
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
#define NUM_STRINGS 39
#define NUM_FRSTR 30
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
#define SLICE                              9 /* STRING in tree MAIN */
#define LF_1                              10 /* BOXCHAR in tree MAIN */
#define BG_1                              11 /* BOX in tree MAIN */
#define SLIDER_1                          12 /* BUTTON in tree MAIN */
#define RT_1                              13 /* BOXCHAR in tree MAIN */
#define PRIO                              14 /* STRING in tree MAIN */
#define LF_2                              15 /* BOXCHAR in tree MAIN */
#define BG_2                              16 /* BOX in tree MAIN */
#define SLIDER_2                          17 /* BUTTON in tree MAIN */
#define RT_2                              18 /* BOXCHAR in tree MAIN */

#define CPXTITLE_EN                        0 /* Free string */
/* MagiC Timeslice */

#define CPXNAME_EN                         1 /* Free string */
/* Timeslice */

#define FS_SLICE_EN                        2 /* Free string */
/* Time slice [ms]: */

#define FS_PRIO_EN                         3 /* Free string */
/* Background Priority: */

#define FS_PREEMPTIVE_EN                   4 /* Free string */
/* Pre-emptive Multitasking */

#define OK_EN                              5 /* Free string */
/* OK */

#define SAVE_EN                            6 /* Free string */
/* Save */

#define CANCEL_EN                          7 /* Free string */
/* Abort */

#define AL_NO_MAGIC_EN                     8 /* Alert string */
/* [1][   Magic is not installed!   ][Abort] */

#define AL_NOT_ACTIVE_EN                   9 /* Alert string */
/* [1][MagiC-AES is not active!][ Abort ] */

#define CPXTITLE_DE                       10 /* Free string */
/* MagiC Timeslice */

#define CPXNAME_DE                        11 /* Free string */
/* Timeslice */

#define FS_SLICE_DE                       12 /* Free string */
/* Zeitscheibendauer [ms]: */

#define FS_PRIO_DE                        13 /* Free string */
/* Hintergrundpriorit„t: */

#define FS_PREEMPTIVE_DE                  14 /* Free string */
/* Pr„emptives Multitasking */

#define SAVE_DE                           15 /* Free string */
/* Sichern */

#define OK_DE                             16 /* Free string */
/* OK */

#define CANCEL_DE                         17 /* Free string */
/* Abbruch */

#define AL_NO_MAGIC_DE                    18 /* Alert string */
/* [1][MagiC ist nicht installiert!][ Abbruch ] */

#define AL_NOT_ACTIVE_DE                  19 /* Alert string */
/* [1][MagiC-AES ist nicht aktiv!][ Abbruch ] */

#define CPXTITLE_FR                       20 /* Free string */
/* MagiC Timeslice */

#define CPXNAME_FR                        21 /* Free string */
/* Timeslice */

#define FS_SLICE_FR                       22 /* Free string */
/* Time slice [ms]: */

#define FS_PRIO_FR                        23 /* Free string */
/* Background Priority: */

#define FS_PREEMPTIVE_FR                  24 /* Free string */
/* Pre-emptive Multitasking */

#define SAVE_FR                           25 /* Free string */
/* Sauver */

#define OK_FR                             26 /* Free string */
/* OK */

#define CANCEL_FR                         27 /* Free string */
/* Abandon */

#define AL_NO_MAGIC_FR                    28 /* Alert string */
/* [1][   Magic is not installed!   ][Abort] */

#define AL_NOT_ACTIVE_FR                  29 /* Alert string */
/* [1][MagiC-AES is not active!][ Abort ] */




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
