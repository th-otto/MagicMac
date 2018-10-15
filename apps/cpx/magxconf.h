/*
 * resource set indices for magxconf
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        49
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       0
 * Number of Free Strings:   39
 * Number of Free Images:    0
 * Number of Objects:        13
 * Number of Trees:          1
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          1374
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
#define NUM_STRINGS 49
#define NUM_FRSTR 39
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

#define CPXTITLE_EN                        0 /* Free string */
/* MagiC-Config. */

#define CF_VERSION_EN                      1 /* Free string */
/*  MagiC 00.00‡ of 00.00.0000  */

#define CF_FASTLOAD_EN                     2 /* Free string */
/* Fastload */

#define CF_TOSCOMPAT_EN                    3 /* Free string */
/* TOS-Compatibility */

#define CF_SMARTREDRAW_EN                  4 /* Free string */
/* Smart Redraw */

#define CF_GROWBOX_EN                      5 /* Free string */
/* Grow- and Shrinkboxes */

#define CF_FLOPPY_DMA_EN                   6 /* Free string */
/* Background-DMA */

#define CF_PULLDOWN_EN                     7 /* Free string */
/* Pull-Down-Menus */

#define SAVE_EN                            8 /* Free string */
/* Save */

#define OK_EN                              9 /* Free string */
/* OK */

#define CANCEL_EN                         10 /* Free string */
/* Abort */

#define AL_NO_MAGIC_EN                    11 /* Alert string */
/* [1][   Magic is not installed!   ][Abort] */

#define AL_NOT_ACTIVE_EN                  12 /* Alert string */
/* [1][MagiC-AES is not active!][ Abort ] */

#define CPXTITLE_DE                       13 /* Free string */
/* MagiC-Konfig. */

#define CF_VERSION_DE                     14 /* Free string */
/*  MagiC 00.00‡ vom 00.00.0000  */

#define CF_FASTLOAD_DE                    15 /* Free string */
/* Fastload */

#define CF_TOSCOMPAT_DE                   16 /* Free string */
/* TOS-KompatibilitÑt */

#define CF_SMARTREDRAW_DE                 17 /* Free string */
/* Smart Redraw */

#define CF_GROWBOX_DE                     18 /* Free string */
/* Grow- und Shrinkboxen */

#define CF_FLOPPY_DMA_DE                  19 /* Free string */
/* Floppy-Hintergrund-DMA */

#define CF_PULLDOWN_DE                    20 /* Free string */
/* Pull-Down-MenÅs */

#define SAVE_DE                           21 /* Free string */
/* Sichern */

#define OK_DE                             22 /* Free string */
/* OK */

#define CANCEL_DE                         23 /* Free string */
/* Abbruch */

#define AL_NO_MAGIC_DE                    24 /* Alert string */
/* [1][MagiC ist nicht installiert!][ Abbruch ] */

#define AL_NOT_ACTIVE_DE                  25 /* Alert string */
/* [1][MagiC-AES ist nicht aktiv!][ Abbruch ] */

#define CPXTITLE_FR                       26 /* Free string */
/* MagiC-Config. */

#define CF_VERSION_FR                     27 /* Free string */
/*  MagiC 00.00‡ du 00.00.0000  */

#define CF_FASTLOAD_FR                    28 /* Free string */
/* Fastload */

#define CF_TOSCOMPAT_FR                   29 /* Free string */
/* TOS-CompatibilitÇ */

#define CF_SMARTREDRAW_FR                 30 /* Free string */
/* Smart Redraw */

#define CF_GROWBOX_FR                     31 /* Free string */
/* Boåtes Grow/Shrink */

#define CF_FLOPPY_DMA_FR                  32 /* Free string */
/* Background-DMA */

#define CF_PULLDOWN_FR                    33 /* Free string */
/* Pull-Down-Menus */

#define SAVE_FR                           34 /* Free string */
/* Sauver */

#define OK_FR                             35 /* Free string */
/* OK */

#define CANCEL_FR                         36 /* Free string */
/* Abandon */

#define AL_NO_MAGIC_FR                    37 /* Alert string */
/* [1][   Magic is not installed!   ][Abort] */

#define AL_NOT_ACTIVE_FR                  38 /* Alert string */
/* [1][MagiC-AES is not active!][ Abort ] */




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
