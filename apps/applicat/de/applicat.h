/*
 * resource set indices for applicat
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        175
 * Number of Bitblks:        0
 * Number of Iconblks:       8
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       31
 * Number of Free Strings:   36
 * Number of Free Images:    0
 * Number of Objects:        126
 * Number of Trees:          7
 * Number of Userblks:       0
 * Number of Images:         16
 * Total file size:          8940
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "applicat"
#endif
#undef RSC_ID
#ifdef applicat
#define RSC_ID applicat
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 175
#define NUM_FRSTR 36
#define NUM_UD 0
#define NUM_IMAGES 16
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 8
#define NUM_CIB 0
#define NUM_TI 31
#define NUM_OBS 126
#define NUM_TREE 7
#endif



#define T_APPS             0 /* form/dialog */
#define PN_BK              2 /* IBOX in tree T_APPS */
#define PRG1               3 /* BOXTEXT in tree T_APPS */ /* max len 20 */
#define PICON1             4 /* BOX in tree T_APPS */
#define PRG2               5 /* BOXTEXT in tree T_APPS */ /* max len 20 */
#define PICON2             6 /* BOX in tree T_APPS */
#define PRG3               7 /* BOXTEXT in tree T_APPS */ /* max len 20 */
#define PICON3             8 /* BOX in tree T_APPS */
#define PRG4               9 /* BOXTEXT in tree T_APPS */ /* max len 20 */
#define PICON4            10 /* BOX in tree T_APPS */
#define PRG5              11 /* BOXTEXT in tree T_APPS */ /* max len 20 */
#define PICON5            12 /* BOX in tree T_APPS */
#define PN_UP             13 /* BOXCHAR in tree T_APPS */
#define PN_BSL            14 /* BOX in tree T_APPS */
#define PN_SLID           15 /* BOX in tree T_APPS */
#define PN_DOWN           16 /* BOXCHAR in tree T_APPS */
#define DN_BK             18 /* IBOX in tree T_APPS */
#define DAT1              19 /* BOXTEXT in tree T_APPS */ /* max len 14 */
#define DICON1            20 /* BOX in tree T_APPS */
#define DAT2              21 /* BOXTEXT in tree T_APPS */ /* max len 14 */
#define DICON2            22 /* BOX in tree T_APPS */
#define DAT3              23 /* BOXTEXT in tree T_APPS */ /* max len 14 */
#define DICON3            24 /* BOX in tree T_APPS */
#define DAT4              25 /* BOXTEXT in tree T_APPS */ /* max len 14 */
#define DICON4            26 /* BOX in tree T_APPS */
#define DAT5              27 /* BOXTEXT in tree T_APPS */ /* max len 14 */
#define DICON5            28 /* BOX in tree T_APPS */
#define DN_UP             29 /* BOXCHAR in tree T_APPS */
#define DN_BSL            30 /* BOX in tree T_APPS */
#define DN_SLID           31 /* BOX in tree T_APPS */
#define DN_DOWN           32 /* BOXCHAR in tree T_APPS */
#define ICONS_OK          33 /* BUTTON in tree T_APPS */
#define ICONS_CN          34 /* BUTTON in tree T_APPS */
#define NEU_PGM           35 /* BUTTON in tree T_APPS */
#define DEL_PGM           36 /* BUTTON in tree T_APPS */
#define NEU_DAT           37 /* BUTTON in tree T_APPS */
#define DEL_DAT           38 /* BUTTON in tree T_APPS */

#define T_ANWNDG           1 /* form/dialog */
#define ANWNDG_T           2 /* FTEXT in tree T_ANWNDG */ /* max len 63 */
#define ANWND_OK           4 /* BUTTON in tree T_ANWNDG */
#define ANWND_CN           5 /* BUTTON in tree T_ANWNDG */
#define ANWND_SI           6 /* BUTTON in tree T_ANWNDG */
#define ANWND_FS           8 /* BUTTON in tree T_ANWNDG */
#define ANW_XTYP          10 /* IBOX in tree T_ANWNDG */
#define ANWND_PR          11 /* BUTTON in tree T_ANWNDG */
#define ANWND_TO          12 /* BUTTON in tree T_ANWNDG */
#define ANWND_TP          13 /* BUTTON in tree T_ANWNDG */
#define ANW_PTYP          14 /* IBOX in tree T_ANWNDG */
#define ANW_OPTH          15 /* BUTTON in tree T_ANWNDG */
#define ANW_WPTH          16 /* BUTTON in tree T_ANWNDG */
#define ANWND_VA          17 /* BUTTON in tree T_ANWNDG */
#define LIMITMEM          18 /* FTEXT in tree T_ANWNDG */ /* max len 4 */
#define DO_LIMIT          20 /* BUTTON in tree T_ANWNDG */
#define ANWND_PROP_FNT    21 /* BUTTON in tree T_ANWNDG */

#define T_FTYPES           2 /* form/dialog */
#define FTYPE_ANW          2 /* STRING in tree T_FTYPES */
#define FTYPE_1            3 /* FTEXT in tree T_FTYPES */ /* max len 30 */
#define FTYPE_2            4 /* FTEXT in tree T_FTYPES */ /* max len 30 */
#define FTYPE_3            5 /* FTEXT in tree T_FTYPES */ /* max len 30 */
#define FTYPE_4            6 /* FTEXT in tree T_FTYPES */ /* max len 30 */
#define FTYPE_OK           7 /* BUTTON in tree T_FTYPES */
#define FTYPE_CN           8 /* BUTTON in tree T_FTYPES */

#define T_DEFICN           3 /* form/dialog */
#define I_FLPDSK           1 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_DRUCKR           2 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_PAPIER           3 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_ORDNER           4 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_PROGRA           5 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_DATEI            6 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_BTCHDA           7 /* ICON in tree T_DEFICN */ /* max len 12 */
#define I_PAR              8 /* ICON in tree T_DEFICN */ /* max len 12 */

#define T_FOLDRS           4 /* form/dialog */
#define FL_BK              2 /* IBOX in tree T_FOLDRS */
#define FLD1               3 /* BOXTEXT in tree T_FOLDRS */ /* max len 38 */
#define FLICON1            4 /* BOX in tree T_FOLDRS */
#define FLD2               5 /* BOXTEXT in tree T_FOLDRS */ /* max len 38 */
#define FLICON2            6 /* BOX in tree T_FOLDRS */
#define FLD3               7 /* BOXTEXT in tree T_FOLDRS */ /* max len 38 */
#define FLICON3            8 /* BOX in tree T_FOLDRS */
#define FLD4               9 /* BOXTEXT in tree T_FOLDRS */ /* max len 38 */
#define FLICON4           10 /* BOX in tree T_FOLDRS */
#define FLD5              11 /* BOXTEXT in tree T_FOLDRS */ /* max len 38 */
#define FLICON5           12 /* BOX in tree T_FOLDRS */
#define FL_UP             13 /* BOXCHAR in tree T_FOLDRS */
#define FL_BSL            14 /* BOX in tree T_FOLDRS */
#define FL_SLID           15 /* BOX in tree T_FOLDRS */
#define FL_DOWN           16 /* BOXCHAR in tree T_FOLDRS */
#define FL_OK             17 /* BUTTON in tree T_FOLDRS */
#define FL_CN             18 /* BUTTON in tree T_FOLDRS */
#define NEU_FLD           19 /* BUTTON in tree T_FOLDRS */
#define DEL_FLD           20 /* BUTTON in tree T_FOLDRS */

#define T_SPECIA           5 /* form/dialog */
#define DF_BK              2 /* IBOX in tree T_SPECIA */
#define SPC1               3 /* BOXTEXT in tree T_SPECIA */ /* max len 20 */
#define SPCICON1           4 /* BOX in tree T_SPECIA */
#define SPC2               5 /* BOXTEXT in tree T_SPECIA */ /* max len 20 */
#define SPCICON2           6 /* BOX in tree T_SPECIA */
#define SPC3               7 /* BOXTEXT in tree T_SPECIA */ /* max len 20 */
#define SPCICON3           8 /* BOX in tree T_SPECIA */
#define SPC4               9 /* BOXTEXT in tree T_SPECIA */ /* max len 20 */
#define SPCICON4          10 /* BOX in tree T_SPECIA */
#define SPC5              11 /* BOXTEXT in tree T_SPECIA */ /* max len 20 */
#define SPCICON5          12 /* BOX in tree T_SPECIA */
#define DF_UP             13 /* BOXCHAR in tree T_SPECIA */
#define DF_BSL            14 /* BOX in tree T_SPECIA */
#define DF_SLID           15 /* BOX in tree T_SPECIA */
#define DF_DOWN           16 /* BOXCHAR in tree T_SPECIA */
#define DF_OK             17 /* BUTTON in tree T_SPECIA */
#define DF_CN             18 /* BUTTON in tree T_SPECIA */

#define T_NEWFLD           6 /* form/dialog */
#define FLDN_PTH           2 /* FTEXT in tree T_NEWFLD */ /* max len 63 */
#define FLDN_OK            3 /* BUTTON in tree T_NEWFLD */
#define FLDN_CN            4 /* BUTTON in tree T_NEWFLD */
#define FLDN_SEL           5 /* BUTTON in tree T_NEWFLD */
#define FLDN_REL           6 /* BUTTON in tree T_NEWFLD */

#define ALRT_PATH_NOTABS   0 /* Alert string */
/* [3][Pfad ist nicht absolut.][Abbruch] */

#define ALRT_ERRARG        1 /* Alert string */
/* [3][APPLICAT:|Fehler bei ParameterÅbergabe!][Abbruch] */

#define STR_SEARCH_PGM     2 /* Free string */
/* Programm suchen */

#define STR_WINTITLE_APP   3 /* Free string */
/*  Anwendungen anmelden  */

#define STR_WINTITLE_PTH   4 /* Free string */
/*  Pfade anmelden  */

#define STR_WINTITLE_SPC   5 /* Free string */
/*  Defaulticons anmelden  */

#define ALRT_APP_INVALID   6 /* Alert string */
/* [3][Applikation ungÅltig.][Abbruch] */

#define ALRT_FTYPE_INUSE   7 /* Alert string */
/* [3][Dateityp %s|schon angemeldet fÅr:|%s][Abbruch] */

#define ALRT_FNAME_INVAL   8 /* Alert string */
/* [3][Dateiname enthÑlt|nicht erlaubte Zeichen.][Abbruch] */

#define ALRT_FNAME_2LONG   9 /* Alert string */
/* [3][Dateiname leer oder zu lang.][Abbruch] */

#define ALRT_OVERFLOW     10 /* Alert string */
/* [3][öberlauf. Zuviele EintrÑge.][Abbruch] */

#define ALRT_APPNAMECHGD  11 /* Alert string */
/* [2][Applikationsname geÑndert.|Neue Applikation eintragen?][OK|Abbruch] */

#define ALRT_DAT_INVALID  12 /* Alert string */
/* [3][Dateityp ungÅltig.][Abbruch] */

#define ALRT_PATH_INVAL   13 /* Alert string */
/* [3][Pfad ist ungÅltig. GÅltig ist:| |   <Ordnername>\|      oder|   X:\<pfad>\][Abbruch] */

#define ALRT_TOOMANY_RSC  14 /* Alert string */
/* [3][Zuviele Resourcedateien][Abbruch] */

#define ALRT_FORMATICERR  15 /* Alert string */
/* [3][Formatfehler auf Icondatei.][Abbruch] */

#define ALRT_2MANY_ICONS  16 /* Alert string */
/* [3][Zuviele Icons.][Abbruch] */

#define ALRT_ERR_IN_INF   17 /* Alert string */
/* [3][Fehler auf APPLICAT.INF:|%s][Abbruch] */

#define ALRT_APPMUSTPATH  18 /* Alert string */
/* [3][Applikationen mit angemeldeten|Dateien mÅssen einen Pfad haben.][Abbruch] */

#define ALRT_ERRWINDOPEN  19 /* Alert string */
/* [3][Fenster kann nicht geîffnet werden.][Abbruch] */

#define ALRT_IS_PSEUDO    20 /* Alert string */
/* [3][Die Kennung fÅr nicht angemeldete|Dateien kann nicht verÑndert werden!][Abbruch] */

#define STR_WINTITLE_1AP  21 /* Free string */
/*  Anwendung anmelden  */

#define STR_WINTITLE_TYP  22 /* Free string */
/*  Dateityp editieren  */

#define STR_WINTITLE_MTY  23 /* Free string */
/*  Dateitypen anmelden  */

#define STR_WTIT_ICONS    24 /* Free string */
/*  Icons  */

#define STR_WTIT_DEFPATH  25 /* Free string */
/*  Pfad anmelden  */

#define STR_ERR_WR_INF    26 /* Free string */
/* Schreibfehler */

#define STR_ERR_FULL_INF  27 /* Free string */
/* Festplatte voll. */

#define STR_ERR_EOF_INF   28 /* Free string */
/* Dateiende */

#define STR_ERR_LEN_INF   29 /* Free string */
/* ZeilenÅberlauf */

#define STR_ERR_HEAD_INF  30 /* Free string */
/* Fehler im Header */

#define STR_LINE          31 /* Free string */
/* Zeile: | */

#define STR_ERR_VERSION   32 /* Free string */
/* Versionsfehler */

#define STR_ERR_FORMAT    33 /* Free string */
/* Formatfehler */

#define STR_ERR_MULTITYP  34 /* Free string */
/* Dateityp mehrfach verwendet */

#define STR_CHOOSE_PATH   35 /* Free string */
/* Pfad auswÑhlen */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD applicat_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD applicat_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD applicat_rsc_free(void);
#endif
