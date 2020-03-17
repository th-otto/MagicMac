/*
 * resource set indices for magiccfg
 *
 * created by ORCS 2.17
 */

/*
 * Number of Strings:        365
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       65
 * Number of Free Strings:   36
 * Number of Free Images:    0
 * Number of Objects:        291
 * Number of Trees:          17
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          17448
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "magiccfg"
#endif
#undef RSC_ID
#ifdef magiccfg
#define RSC_ID magiccfg
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 365
#define NUM_FRSTR 36
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 65
#define NUM_OBS 291
#define NUM_TREE 17
#endif



#define MENU               0 /* menu */
#define ME_PROGRAM         3 /* TITLE in tree MENU */
#define ME_FILE            4 /* TITLE in tree MENU */
#define ME_PROGRAM_INFO    7 /* STRING in tree MENU */
#define ME_NEW            16 /* STRING in tree MENU */
#define ME_OPEN           18 /* STRING in tree MENU */
#define ME_SAVE           19 /* STRING in tree MENU */
#define ME_SAVE_AS        20 /* STRING in tree MENU */
#define ME_QUIT           22 /* STRING in tree MENU */

#define DIAL_LIBRARY       1 /* form/dialog */
#define DI_ICON            1 /* CICON in tree DIAL_LIBRARY */
#define DI_ICONIFY_NAME    2 /* STRING in tree DIAL_LIBRARY */
#define DI_MEMORY_ERROR    3 /* STRING in tree DIAL_LIBRARY */
#define DI_WDIALOG_ERROR   4 /* STRING in tree DIAL_LIBRARY */
#define DI_HELP_ERROR      5 /* STRING in tree DIAL_LIBRARY */
#define DI_VDI_WKS_ERROR   6 /* STRING in tree DIAL_LIBRARY */

/* Author */
#define PROGRAM_INFO       2 /* form/dialog */
#define PR_OK              1 /* BUTTON in tree PROGRAM_INFO */

/* Main dialog */
#define MAIN               3 /* form/dialog */
#define MA_VERSION         1 /* STRING in tree MAIN */
#define MA_3D_EFFECT       3 /* BUTTON in tree MAIN */
#define MA_BACKDROP        4 /* BUTTON in tree MAIN */
#define MA_TITLE_LINES     5 /* BUTTON in tree MAIN */
#define MA_TITLE_3D        6 /* BUTTON in tree MAIN */
#define MA_REAL_SCROLL     7 /* BUTTON in tree MAIN */
#define MA_LOGO_LEFT       9 /* BUTTON in tree MAIN */
#define MA_LOGO_RIGHT     10 /* BUTTON in tree MAIN */
#define MA_REAL_MOVE      11 /* BUTTON in tree MAIN */
#define MA_3D_MENU        12 /* BUTTON in tree MAIN */
#define MA_PATH           13 /* BUTTON in tree MAIN */
#define MA_RESOLUTION     14 /* BUTTON in tree MAIN */
#define MA_VARIABLES      15 /* BUTTON in tree MAIN */
#define MA_FONT           16 /* BUTTON in tree MAIN */
#define MA_VFAT           17 /* BUTTON in tree MAIN */
#define MA_WINDOW         18 /* BUTTON in tree MAIN */
#define MA_BACKGROUND     19 /* BUTTON in tree MAIN */
#define MA_BOOT           20 /* BUTTON in tree MAIN */
#define MA_LIBS           21 /* BUTTON in tree MAIN */
#define MA_OTHER          22 /* BUTTON in tree MAIN */

/* Path */
#define PATH               4 /* form/dialog */
#define PA_SCRAP           1 /* FTEXT in tree PATH */
#define PA_ACC             2 /* FTEXT in tree PATH */
#define PA_START           3 /* FTEXT in tree PATH */
#define PA_SHELL           4 /* FTEXT in tree PATH */
#define PA_AUTO            5 /* FTEXT in tree PATH */
#define PA_TERMINAL        6 /* FTEXT in tree PATH */
#define PA_OK             13 /* BUTTON in tree PATH */
#define PA_CANCEL         14 /* BUTTON in tree PATH */

/* Resolution */
#define RESOLUTION         5 /* form/dialog */
#define RE_COLOR           2 /* BUTTON in tree RESOLUTION */
#define RE_BOX             3 /* IBOX in tree RESOLUTION */
#define RE_00              4 /* TEXT in tree RESOLUTION */
#define RE_01              5 /* TEXT in tree RESOLUTION */
#define RE_02              6 /* TEXT in tree RESOLUTION */
#define RE_03              7 /* TEXT in tree RESOLUTION */
#define RE_04              8 /* TEXT in tree RESOLUTION */
#define RE_05              9 /* TEXT in tree RESOLUTION */
#define RE_06             10 /* TEXT in tree RESOLUTION */
#define RE_07             11 /* TEXT in tree RESOLUTION */
#define RE_08             12 /* TEXT in tree RESOLUTION */
#define RE_09             13 /* TEXT in tree RESOLUTION */
#define RE_UP             14 /* BOXCHAR in tree RESOLUTION */
#define RE_BACK           15 /* BOX in tree RESOLUTION */
#define RE_WHITE          16 /* BOX in tree RESOLUTION */
#define RE_DOWN           17 /* BOXCHAR in tree RESOLUTION */
#define RE_NOCHANGE       18 /* BUTTON in tree RESOLUTION */
#define RE_OK             19 /* BUTTON in tree RESOLUTION */
#define RE_CANCEL         20 /* BUTTON in tree RESOLUTION */
#define RE_OWNSETTING     21 /* BUTTON in tree RESOLUTION */
#define RE_DRIVER         22 /* FTEXT in tree RESOLUTION */
#define RE_MODE           23 /* FTEXT in tree RESOLUTION */
#define RE_MODE_TXT       24 /* STRING in tree RESOLUTION */
#define RE_DRIVER_TXT     25 /* STRING in tree RESOLUTION */

/* Variables */
#define VARIABLES          6 /* form/dialog */
#define VA_BOX             1 /* IBOX in tree VARIABLES */
#define VA_0               2 /* TEXT in tree VARIABLES */
#define VA_1               3 /* TEXT in tree VARIABLES */
#define VA_2               4 /* TEXT in tree VARIABLES */
#define VA_3               5 /* TEXT in tree VARIABLES */
#define VA_4               6 /* TEXT in tree VARIABLES */
#define VA_5               7 /* TEXT in tree VARIABLES */
#define VA_6               8 /* TEXT in tree VARIABLES */
#define VA_7               9 /* TEXT in tree VARIABLES */
#define VA_UP             10 /* BOXCHAR in tree VARIABLES */
#define VA_BACK           11 /* BOX in tree VARIABLES */
#define VA_WHITE          12 /* BOX in tree VARIABLES */
#define VA_DOWN           13 /* BOXCHAR in tree VARIABLES */
#define VA_EDIT           14 /* IBOX in tree VARIABLES */
#define VA_ACTIVE         15 /* BUTTON in tree VARIABLES */
#define VA_NAME           16 /* FTEXT in tree VARIABLES */
#define VA_VARIABLE       18 /* FTEXT in tree VARIABLES */
#define VA_NEW            19 /* BUTTON in tree VARIABLES */
#define VA_SET            20 /* BUTTON in tree VARIABLES */
#define VA_REMOVE         21 /* BUTTON in tree VARIABLES */
#define VA_OK             22 /* BUTTON in tree VARIABLES */

/* Font */
#define FONT               7 /* form/dialog */
#define FO_GNAME           2 /* BUTTON in tree FONT */
#define FO_GHEIGHT         3 /* FTEXT in tree FONT */
#define FO_SNAME           5 /* BUTTON in tree FONT */
#define FO_SHEIGHT         6 /* FTEXT in tree FONT */
#define FO_OK              7 /* BUTTON in tree FONT */
#define FO_CANCEL          8 /* BUTTON in tree FONT */
#define FO_AES_OW         10 /* FTEXT in tree FONT */
#define FO_AES_OH         11 /* FTEXT in tree FONT */

/* VFAT */
#define VFAT               8 /* form/dialog */
#define VF_DRIVE_A         2 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_B         3 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_C         4 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_D         5 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_E         6 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_F         7 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_G         8 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_H         9 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_I        10 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_J        11 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_K        12 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_L        13 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_M        14 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_N        15 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_O        16 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_P        17 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_Q        18 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_R        19 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_S        20 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_T        21 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_U        22 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_V        23 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_W        24 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_X        25 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_Y        26 /* BOXCHAR in tree VFAT */
#define VF_DRIVE_Z        27 /* BOXCHAR in tree VFAT */
#define VF_OK             28 /* BUTTON in tree VFAT */
#define VF_CANCEL         29 /* BUTTON in tree VFAT */

/* Other */
#define OTHER              9 /* form/dialog */
#define OT_SYSTEM          1 /* BUTTON in tree OTHER */
#define OT_SHELL_BUFFER    3 /* FTEXT in tree OTHER */
#define OT_MTASK           4 /* BUTTON in tree OTHER */
#define OT_TSL_TIME        5 /* FTEXT in tree OTHER */
#define OT_TSL_PRIORITY    6 /* FTEXT in tree OTHER */
#define OT_PRIOR_TXT       7 /* STRING in tree OTHER */
#define OT_PROP_TXT        8 /* TEXT in tree OTHER */
#define OT_FSEL_MASK      10 /* FTEXT in tree OTHER */
#define OT_OK             11 /* BUTTON in tree OTHER */
#define OT_CANCEL         12 /* BUTTON in tree OTHER */

/* Background */
#define BACKGROUND        10 /* form/dialog */
#define BA_PATTERN         2 /* BOX in tree BACKGROUND */
#define BA_COLOR           4 /* BOX in tree BACKGROUND */
#define BA_PREVIEW         5 /* BOX in tree BACKGROUND */
#define BA_OK              7 /* BUTTON in tree BACKGROUND */
#define BA_CANCEL          8 /* BUTTON in tree BACKGROUND */

/* Boot */
#define BOOT              11 /* form/dialog */
#define BO_LOG             1 /* FTEXT in tree BOOT */
#define BO_IMAGE           2 /* FTEXT in tree BOOT */
#define BO_TILES           3 /* FTEXT in tree BOOT */
#define BO_COOKIES         4 /* FTEXT in tree BOOT */
#define BO_OK              5 /* BUTTON in tree BOOT */
#define BO_CANCEL          6 /* BUTTON in tree BOOT */

/* Window */
#define WINDOW            12 /* form/dialog */
#define WI_WIN_CNT         1 /* FTEXT in tree WINDOW */
#define WI_INF_FNAME       3 /* BUTTON in tree WINDOW */
#define WI_INF_FH          4 /* FTEXT in tree WINDOW */
#define WI_INF_HEIGHT      5 /* FTEXT in tree WINDOW */
#define WI_OK              6 /* BUTTON in tree WINDOW */
#define WI_CANCEL          7 /* BUTTON in tree WINDOW */

/* Libraries */
#define LIBRARIES         13 /* form/dialog */
#define LI_BOX             1 /* IBOX in tree LIBRARIES */
#define LI_01              2 /* TEXT in tree LIBRARIES */
#define LI_02              3 /* TEXT in tree LIBRARIES */
#define LI_03              4 /* TEXT in tree LIBRARIES */
#define LI_04              5 /* TEXT in tree LIBRARIES */
#define LI_05              6 /* TEXT in tree LIBRARIES */
#define LI_06              7 /* TEXT in tree LIBRARIES */
#define LI_07              8 /* TEXT in tree LIBRARIES */
#define LI_08              9 /* TEXT in tree LIBRARIES */
#define LI_09             10 /* TEXT in tree LIBRARIES */
#define LI_10             11 /* TEXT in tree LIBRARIES */
#define LI_UP             12 /* BOXCHAR in tree LIBRARIES */
#define LI_BACK           13 /* BOX in tree LIBRARIES */
#define LI_WHITE          14 /* BOX in tree LIBRARIES */
#define LI_DOWN           15 /* BOXCHAR in tree LIBRARIES */
#define LI_OK             16 /* BUTTON in tree LIBRARIES */
#define LI_NEW            17 /* BUTTON in tree LIBRARIES */
#define LI_SET            18 /* BUTTON in tree LIBRARIES */
#define LI_REMOVE         19 /* BUTTON in tree LIBRARIES */
#define LI_VERSION        20 /* FTEXT in tree LIBRARIES */

#define COLOR_POPUP       14 /* form/dialog */
#define CO_BPS             1 /* TEXT in tree COLOR_POPUP */

#define BACKCOL_POPUP     15 /* form/dialog */
#define BA_COL1           17 /* STRING in tree BACKCOL_POPUP */
#define BA_COL2           18 /* STRING in tree BACKCOL_POPUP */
#define BA_COL3           19 /* STRING in tree BACKCOL_POPUP */
#define BA_COL4           20 /* STRING in tree BACKCOL_POPUP */
#define BA_COL5           21 /* STRING in tree BACKCOL_POPUP */
#define BA_COL6           22 /* STRING in tree BACKCOL_POPUP */
#define BA_COL7           23 /* STRING in tree BACKCOL_POPUP */
#define BA_COL8           24 /* STRING in tree BACKCOL_POPUP */
#define BA_COL9           25 /* STRING in tree BACKCOL_POPUP */
#define BA_COL10          26 /* STRING in tree BACKCOL_POPUP */
#define BA_COL11          27 /* STRING in tree BACKCOL_POPUP */
#define BA_COL12          28 /* STRING in tree BACKCOL_POPUP */
#define BA_COL13          29 /* STRING in tree BACKCOL_POPUP */
#define BA_COL14          30 /* STRING in tree BACKCOL_POPUP */
#define BA_COL15          31 /* STRING in tree BACKCOL_POPUP */
#define BA_COL16          32 /* STRING in tree BACKCOL_POPUP */

#define BACKPAT_POPUP     16 /* form/dialog */
#define BA_P1              1 /* BOX in tree BACKPAT_POPUP */
#define BA_P2              2 /* BOX in tree BACKPAT_POPUP */
#define BA_P3              3 /* BOX in tree BACKPAT_POPUP */
#define BA_P4              4 /* BOX in tree BACKPAT_POPUP */
#define BA_P5              5 /* BOX in tree BACKPAT_POPUP */
#define BA_P6              6 /* BOX in tree BACKPAT_POPUP */
#define BA_P7              7 /* BOX in tree BACKPAT_POPUP */
#define BA_P8              8 /* BOX in tree BACKPAT_POPUP */

#define F_NOT_EXIST        0 /* Alert string */

#define F_EXISTS           1 /* Alert string */

#define F_CHANGED          2 /* Alert string */

#define F_NOT_MAGXINF      3 /* Alert string */

#define NO_MAGIC_FOUND     4 /* Alert string */

#define NO_MAGIC_VARS      5 /* Alert string */

#define NO_FNT_DIALOG      6 /* Alert string */

#define SYSTEM_RESTART     7 /* Alert string */

#define WDLG_PRG           8 /* Free string */

#define WDLG_PATH          9 /* Free string */

#define WDLG_RES          10 /* Free string */

#define WDLG_ENV          11 /* Free string */

#define WDLG_FONT         12 /* Free string */

#define WDLG_VFAT         13 /* Free string */

#define WDLG_OTHER        14 /* Free string */

#define WDLG_BACKGROUND   15 /* Free string */

#define WDLG_BOOT         16 /* Free string */

#define WDLG_WINDOW       17 /* Free string */

#define WDLG_LIBRARIES    18 /* Free string */

#define FSEL_GETFOLDER    19 /* Free string */

#define FSEL_GETAPPL      20 /* Free string */

#define FSEL_MAG_OPEN     21 /* Free string */

#define FSEL_MAG_SAVE     22 /* Free string */

#define FSEL_GETLOGFILE   23 /* Free string */

#define FSEL_GETPIC       24 /* Free string */

#define FSEL_GETPATTERN   25 /* Free string */

#define FSEL_SHAREDLIB    26 /* Free string */

#define FNTS_SAMPLE       27 /* Free string */

#define NEW_FILE          28 /* Free string */

#define NO_RESOLUTION     29 /* Free string */

#define FS_ST_HIGH        30 /* Free string */

#define FS_TT_HIGH        31 /* Free string */

#define FS_ST_MED         32 /* Free string */

#define FS_ST_LOW         33 /* Free string */

#define FS_TT_MED         34 /* Free string */

#define FS_TT_LOW         35 /* Free string */

#define TITLE              0 /* BubbleUser */

#define MORE               0 /* BubbleMore */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD magiccfg_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD magiccfg_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD magiccfg_rsc_free(void);
#endif
