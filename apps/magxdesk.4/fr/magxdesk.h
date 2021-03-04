/*
 * resource set indices for magxdesk
 *
 * created by ORCS 2.18
 */

/*
 * Number of Strings:        291
 * Number of Bitblks:        7
 * Number of Iconblks:       8
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       17
 * Number of Free Strings:   42
 * Number of Free Images:    0
 * Number of Objects:        264
 * Number of Trees:          11
 * Number of Userblks:       0
 * Number of Images:         23
 * Total file size:          16284
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "magxdesk"
#endif
#undef RSC_ID
#ifdef magxdesk
#define RSC_ID magxdesk
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 291
#define NUM_FRSTR 42
#define NUM_UD 0
#define NUM_IMAGES 23
#define NUM_BB 7
#define NUM_FRIMG 0
#define NUM_IB 8
#define NUM_CIB 0
#define NUM_TI 17
#define NUM_OBS 264
#define NUM_TREE 11
#endif



#define HAUPTMEN                           0 /* menu */
#define MM_DESK                            3 /* TITLE in tree HAUPTMEN */
#define MM_DATEI                           4 /* TITLE in tree HAUPTMEN */
#define MM_ANZEI                           5 /* TITLE in tree HAUPTMEN */
#define MM_OPTIO                           6 /* TITLE in tree HAUPTMEN */
#define MM_OBJS                            7 /* TITLE in tree HAUPTMEN */
#define MM_SMODE                           8 /* STRING in tree HAUPTMEN */
#define M_ABOUT                           11 /* STRING in tree HAUPTMEN */
#define M_FILE_BOX                        19 /* BOX in tree HAUPTMEN */
#define M_OPEN                            20 /* STRING in tree HAUPTMEN */
#define M_INFO                            21 /* STRING in tree HAUPTMEN */
#define M_LOESCH                          22 /* STRING in tree HAUPTMEN */
#define M_NEUORD                          24 /* STRING in tree HAUPTMEN */
#define M_SEARCH                          25 /* STRING in tree HAUPTMEN */
#define M_SCHL                            26 /* STRING in tree HAUPTMEN */
#define M_SCHLFN                          27 /* STRING in tree HAUPTMEN */
#define M_SELALL                          28 /* STRING in tree HAUPTMEN */
#define M_FORMAT                          30 /* STRING in tree HAUPTMEN */
#define M_EJECT                           31 /* STRING in tree HAUPTMEN */
#define M_DCOPY                           32 /* STRING in tree HAUPTMEN */
#define M_DISPLAY_BOX                     33 /* BOX in tree HAUPTMEN */
#define M_ABILDR                          34 /* STRING in tree HAUPTMEN */
#define M_ATEXT                           35 /* STRING in tree HAUPTMEN */
#define M_FONT                            37 /* STRING in tree HAUPTMEN */
#define M_SPALTN                          38 /* STRING in tree HAUPTMEN */
#define M_ZGROES                          39 /* STRING in tree HAUPTMEN */
#define M_ZDATUM                          40 /* STRING in tree HAUPTMEN */
#define M_ZZEIT                           41 /* STRING in tree HAUPTMEN */
#define M_SNAME                           43 /* STRING in tree HAUPTMEN */
#define M_SDATUM                          44 /* STRING in tree HAUPTMEN */
#define M_SGROES                          45 /* STRING in tree HAUPTMEN */
#define M_STYP                            46 /* STRING in tree HAUPTMEN */
#define M_SNICHT                          47 /* STRING in tree HAUPTMEN */
#define M_MASKE                           49 /* STRING in tree HAUPTMEN */
#define M_OPTION_BOX                      50 /* BOX in tree HAUPTMEN */
#define M_LAUFWE                          51 /* STRING in tree HAUPTMEN */
#define M_ANWNDG                          52 /* STRING in tree HAUPTMEN */
#define M_ICASGN                          53 /* STRING in tree HAUPTMEN */
#define M_EINSTE                          55 /* STRING in tree HAUPTMEN */
#define M_CHGRES                          56 /* STRING in tree HAUPTMEN */
#define M_ARBSIC                          57 /* STRING in tree HAUPTMEN */
#define M_ENDE                            59 /* STRING in tree HAUPTMEN */
#define M_OBJ_BOX                         60 /* BOX in tree HAUPTMEN */
#define M_WIND1                           61 /* STRING in tree HAUPTMEN */
#define M_WIND2                           62 /* STRING in tree HAUPTMEN */
#define M_WIND3                           63 /* STRING in tree HAUPTMEN */
#define M_WIND4                           64 /* STRING in tree HAUPTMEN */
#define M_WIND5                           65 /* STRING in tree HAUPTMEN */
#define M_WIND6                           66 /* STRING in tree HAUPTMEN */
#define M_TRENN                           67 /* STRING in tree HAUPTMEN */
#define M_PGM1                            68 /* STRING in tree HAUPTMEN */
#define M_PGM2                            69 /* STRING in tree HAUPTMEN */
#define M_PGM3                            70 /* STRING in tree HAUPTMEN */
#define M_PGM4                            71 /* STRING in tree HAUPTMEN */
#define M_PGM5                            72 /* STRING in tree HAUPTMEN */
#define M_PGM6                            73 /* STRING in tree HAUPTMEN */
#define M_PGM7                            74 /* STRING in tree HAUPTMEN */
#define M_PGM8                            75 /* STRING in tree HAUPTMEN */
#define M_PGM9                            76 /* STRING in tree HAUPTMEN */
#define M_PGM10                           77 /* STRING in tree HAUPTMEN */

#define T_ICONS                            1 /* form/dialog */
#define I_DSK                              1 /* ICON in tree T_ICONS */
#define I_DRK                              2 /* ICON in tree T_ICONS */
#define I_PAP                              3 /* ICON in tree T_ICONS */
#define I_ORD                              4 /* ICON in tree T_ICONS */
#define I_PRO                              5 /* ICON in tree T_ICONS */
#define I_DAT                              6 /* ICON in tree T_ICONS */
#define I_BAT                              7 /* ICON in tree T_ICONS */
#define I_ORD16                            8 /* IMAGE in tree T_ICONS */
#define I_ORD08                            9 /* IMAGE in tree T_ICONS */
#define I_ORD24                           10 /* IMAGE in tree T_ICONS */
#define I_PAR                             11 /* ICON in tree T_ICONS */
#define I_PAR24                           12 /* IMAGE in tree T_ICONS */
#define I_PAR16                           13 /* IMAGE in tree T_ICONS */
#define I_PAR08                           14 /* IMAGE in tree T_ICONS */

#define T_MASKE                            2 /* form/dialog */
#define MASKE_TX                           1 /* FTEXT in tree T_MASKE */
#define MASKE_OK                           2 /* BUTTON in tree T_MASKE */
#define MASKE_AL                           3 /* BUTTON in tree T_MASKE */

#define T_TTPPAR                           3 /* form/dialog */
#define TTPPAR_T                           2 /* STRING in tree T_TTPPAR */
#define TTPPAR_1                           3 /* FTEXT in tree T_TTPPAR */
#define TTPPAR_2                           4 /* FTEXT in tree T_TTPPAR */
#define TTPPA_OK                           5 /* BUTTON in tree T_TTPPAR */

#define T_NEUORD                           4 /* form/dialog */
#define NEUORD_T                           3 /* FTEXT in tree T_NEUORD */
#define NEORD_OK                           4 /* BUTTON in tree T_NEUORD */

#define T_DATINF                           5 /* form/dialog */
#define FI_ICON                            2 /* BOXCHAR in tree T_DATINF */
#define DATINF_T                           4 /* FTEXT in tree T_DATINF */
#define FI_SIZE                            6 /* STRING in tree T_DATINF */
#define FI_DATUM                           8 /* STRING in tree T_DATINF */
#define FI_ZEIT                           10 /* STRING in tree T_DATINF */
#define FI_SETDA                          11 /* BUTTON in tree T_DATINF */
#define FI_RDONL                          13 /* BUTTON in tree T_DATINF */
#define FI_HIDDE                          14 /* BUTTON in tree T_DATINF */
#define FI_ARCHI                          15 /* BUTTON in tree T_DATINF */
#define FI_SYSTE                          16 /* BUTTON in tree T_DATINF */
#define FI_ISALI                          17 /* STRING in tree T_DATINF */
#define FI_ALIAS                          18 /* FTEXT in tree T_DATINF */
#define FI_CONT                           19 /* BUTTON in tree T_DATINF */
#define FI_OK                             20 /* BUTTON in tree T_DATINF */
#define FI_CAN                            21 /* BUTTON in tree T_DATINF */

#define T_ORDINF                           6 /* form/dialog */
#define OI_ICON                            2 /* BOXCHAR in tree T_ORDINF */
#define ORDINF_T                           4 /* FTEXT in tree T_ORDINF */
#define OI_DATUM                           6 /* STRING in tree T_ORDINF */
#define OI_ZEIT                            8 /* STRING in tree T_ORDINF */
#define OI_BYTES                          10 /* STRING in tree T_ORDINF */
#define OI_N_DAT                          12 /* STRING in tree T_ORDINF */
#define OI_N_ORD                          14 /* STRING in tree T_ORDINF */
#define OI_N_VDA                          16 /* STRING in tree T_ORDINF */
#define OI_B_VDA                          18 /* STRING in tree T_ORDINF */
#define OI_ISALI                          20 /* STRING in tree T_ORDINF */
#define OI_ALIAS                          21 /* FTEXT in tree T_ORDINF */
#define OI_CONT                           22 /* BUTTON in tree T_ORDINF */
#define OI_OK                             23 /* BUTTON in tree T_ORDINF */
#define OI_CAN                            24 /* BUTTON in tree T_ORDINF */

#define T_DSKINF                           7 /* form/dialog */
#define DI_ICON                            2 /* BOXCHAR in tree T_DSKINF */
#define DI_NAMT                            3 /* STRING in tree T_DSKINF */
#define DI_NAME                            4 /* FTEXT in tree T_DSKINF */
#define DI_EXEC                            5 /* STRING in tree T_DSKINF */
#define DI_N_ORD                           7 /* STRING in tree T_DSKINF */
#define DI_N_DAT                           9 /* STRING in tree T_DSKINF */
#define DI_N_VDA                          11 /* STRING in tree T_DSKINF */
#define DI_BTOTL                          13 /* STRING in tree T_DSKINF */
#define DI_BUSED                          15 /* STRING in tree T_DSKINF */
#define DI_BFREE                          17 /* STRING in tree T_DSKINF */
#define DI_CLUST                          19 /* STRING in tree T_DSKINF */
#define DI_SECCL                          21 /* STRING in tree T_DSKINF */
#define DI_BYSEC                          23 /* STRING in tree T_DSKINF */
#define DI_FLOP                           24 /* STRING in tree T_DSKINF */
#define DI_CONT                           25 /* BUTTON in tree T_DSKINF */
#define DI_OK                             26 /* BUTTON in tree T_DSKINF */
#define DI_CAN                            27 /* BUTTON in tree T_DSKINF */

#define T_EINST                            8 /* form/dialog */
#define EINST_LD                           2 /* BUTTON in tree T_EINST */
#define EIN_OK                             3 /* BUTTON in tree T_EINST */
#define EIN_ABB                            4 /* BUTTON in tree T_EINST */
#define EIN_KAT                            6 /* BUTTON in tree T_EINST */
#define EIN_GRP1                           8 /* IBOX in tree T_EINST */
#define EINST_RS                           9 /* BUTTON in tree T_EINST */
#define EINS_ERD                          10 /* BUTTON in tree T_EINST */
#define EINS_DCLICK                       11 /* BUTTON in tree T_EINST */
#define EIN_GRP2                          12 /* IBOX in tree T_EINST */
#define EINST_BL                          14 /* BUTTON in tree T_EINST */
#define EINST_BK                          15 /* BUTTON in tree T_EINST */
#define EINST_KB                          17 /* BUTTON in tree T_EINST */
#define EINST_KF                          18 /* BUTTON in tree T_EINST */
#define EINST_KA                          19 /* BUTTON in tree T_EINST */
#define EINST_KU                          20 /* BUTTON in tree T_EINST */
#define EIN_KOBO                          21 /* BUTTON in tree T_EINST */
#define EIN_CPRS                          22 /* BUTTON in tree T_EINST */
#define EIN_GRP3                          23 /* IBOX in tree T_EINST */
#define EIN_EDIT                          25 /* FTEXT in tree T_EINST */
#define EIN_SHOW                          27 /* FTEXT in tree T_EINST */
#define EIN_PRNT                          29 /* FTEXT in tree T_EINST */
#define EIN_CMD                           31 /* FTEXT in tree T_EINST */
#define EIN_BAT                           33 /* FTEXT in tree T_EINST */
#define EIN_BTP                           35 /* FTEXT in tree T_EINST */
#define EIN_GRP4                          36 /* IBOX in tree T_EINST */
#define EINST_VE                          37 /* BUTTON in tree T_EINST */
#define EIN_8PL3                          38 /* BUTTON in tree T_EINST */
#define EIN_DSH0                          40 /* BOXCHAR in tree T_EINST */
#define EIN_DSH                           41 /* BOXCHAR in tree T_EINST */
#define EIN_DSH1                          42 /* BOXCHAR in tree T_EINST */
#define EIN_DSV0                          44 /* BOXCHAR in tree T_EINST */
#define EIN_DSV                           45 /* BOXCHAR in tree T_EINST */
#define EIN_DSV1                          46 /* BOXCHAR in tree T_EINST */
#define EIN_PP                            48 /* BUTTON in tree T_EINST */
#define EIN_GRP5                          49 /* IBOX in tree T_EINST */
#define EIN_COL0                          51 /* BOXCHAR in tree T_EINST */
#define EIN_COL                           52 /* BOX in tree T_EINST */
#define EIN_COL1                          53 /* BOXCHAR in tree T_EINST */
#define EIN_PAT0                          54 /* BOXCHAR in tree T_EINST */
#define EIN_PAT                           55 /* BOX in tree T_EINST */
#define EIN_PAT1                          56 /* BOXCHAR in tree T_EINST */
#define EIN_RAS0                          58 /* BOXCHAR in tree T_EINST */
#define EIN_RAS                           59 /* BOXCHAR in tree T_EINST */
#define EIN_RAS1                          60 /* BOXCHAR in tree T_EINST */
#define EIN_KACH                          61 /* FTEXT in tree T_EINST */
#define EINS_DRK                          63 /* BUTTON in tree T_EINST */
#define EINST_DN                          64 /* BUTTON in tree T_EINST */

#define T_ABOUT                            9 /* form/dialog */
#define ABOU_IMG                           1 /* IMAGE in tree T_ABOUT */
#define ABOU_OS                            2 /* STRING in tree T_ABOUT */
#define ABOU_VER                           3 /* TEXT in tree T_ABOUT */

#define T_POPKAT                          10 /* form/dialog */

#define STR_INST_NEW_PGM                   0 /* Free string */

#define STR_CHOOSE_PATTN                   1 /* Free string */

#define STR_STOP                           2 /* Free string */

#define STR_SIDES                          3 /* Free string */

#define STR_TRACKS                         4 /* Free string */

#define STR_SECTORS                        5 /* Free string */

#define STR_READ_INF                       6 /* Free string */

#define STR_SRT_NAMES                      7 /* Free string */

#define STR_SRT_DATE                       8 /* Free string */

#define STR_SRT_SIZE                       9 /* Free string */

#define STR_SRT_TYPE                      10 /* Free string */

#define STR_SRT_UNSORTED                  11 /* Free string */

#define STR_NEW                           12 /* Free string */

#define STR_PATH_2_DEEP                   13 /* Free string */

#define STR_MORE_THAN                     14 /* Free string */

#define STR_OBJECTS                       15 /* Free string */

#define STR_BYTES_IN                      16 /* Free string */

#define STR_OBJECT                        17 /* Free string */

#define STR_OBJCTS_DATIV                  18 /* Free string */

#define STR_SELECTED                      19 /* Free string */

#define STR_BYTES                         20 /* Free string */

#define STR_FREE                          21 /* Free string */

#define STR_FULL                          22 /* Free string */

#define ALRT_PRINT                        23 /* Alert string */

#define ALRT_NO_KOBOLD                    24 /* Alert string */

#define ALRT_STOP_PROC                    25 /* Alert string */

#define ALRT_CONT_LNAMES                  26 /* Alert string */

#define ALRT_APPISACTIVE                  27 /* Alert string */

#define ALRT_NO_MORE_WND                  28 /* Alert string */

#define ALRT_CANT_OPEN                    29 /* Alert string */

#define ALRT_NO_PGM_ASNG                  30 /* Alert string */

#define ALRT_DD_NO_CMDLN                  31 /* Alert string */

#define ALRT_DD_FAILURE                   32 /* Alert string */

#define ALRT_PRINTR_INFO                  33 /* Alert string */

#define ALRT_NO_INF_AT_X                  34 /* Alert string */

#define ALRT_OVL_AES_BUF                  35 /* Alert string */

#define ALRT_ERR_AT_INF                   36 /* Alert string */

#define ALRT_SAVE_WORK                    37 /* Alert string */

#define ALRT_TRASH_INFO                   38 /* Alert string */

#define ALRT_OVL_CMDLINE                  39 /* Alert string */

#define ALRT_FREE_AT_DRV                  40 /* Alert string */

#define STR_SHORT_VIEW                    41 /* Free string */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD magxdesk_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD magxdesk_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD magxdesk_rsc_free(void);
#endif
