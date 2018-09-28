/*
 * resource set indices for vt52
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        112
 * Number of Bitblks:        5
 * Number of Iconblks:       0
 * Number of Color Iconblks: 0
 * Number of Color Icons:    0
 * Number of Tedinfos:       9
 * Number of Free Strings:   3
 * Number of Free Images:    0
 * Number of Objects:        116
 * Number of Trees:          12
 * Number of Userblks:       0
 * Number of Images:         5
 * Total file size:          5886
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "vt52"
#endif
#undef RSC_ID
#ifdef vt52
#define RSC_ID vt52
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 112
#define NUM_FRSTR 3
#define NUM_UD 0
#define NUM_IMAGES 5
#define NUM_BB 5
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 0
#define NUM_TI 9
#define NUM_OBS 116
#define NUM_TREE 12
#endif



#define MENU               0 /* menu */
#define MMFVIEW            3 /* TITLE in tree MENU */
#define MDATEI             4 /* TITLE in tree MENU */
#define MEDIT              5 /* TITLE in tree MENU */
#define MFENSTER           6 /* TITLE in tree MENU */
#define MOPTIONEN          7 /* TITLE in tree MENU */
#define WABOUT            10 /* STRING in tree MENU */
#define DOPEN             19 /* STRING in tree MENU */
#define DCLOSE            21 /* STRING in tree MENU */
#define DQUIT             23 /* STRING in tree MENU */
#define BPASTE            25 /* STRING in tree MENU */
#define FCHANGEW          27 /* STRING in tree MENU */
#define OCLIP             29 /* STRING in tree MENU */
#define OTERMINAL         30 /* STRING in tree MENU */
#define OTOSENDE          31 /* STRING in tree MENU */
#define OFONT             32 /* STRING in tree MENU */
#define OSAVE             34 /* STRING in tree MENU */

#define ABOUT              1 /* form/dialog */
#define VNUMMER            4 /* TEXT in tree ABOUT */ /* max len 12 */

#define TERMINAL           2 /* form/dialog */
#define TCOLUMNS           3 /* FTEXT in tree TERMINAL */ /* max len 3 */
#define TROWS              4 /* FTEXT in tree TERMINAL */ /* max len 3 */
#define TBUFFER            5 /* FTEXT in tree TERMINAL */ /* max len 3 */
#define TUPDATE            7 /* BUTTON in tree TERMINAL */
#define TREDRAW            8 /* FTEXT in tree TERMINAL */ /* max len 3 */
#define TINPUT             9 /* BUTTON in tree TERMINAL */
#define TOK               10 /* BUTTON in tree TERMINAL */
#define TCANCEL           11 /* BUTTON in tree TERMINAL */

#define CMDLINE            3 /* form/dialog */
#define CPNAME             2 /* STRING in tree CMDLINE */
#define CLINE1             3 /* FTEXT in tree CMDLINE */ /* max len 63 */
#define CLINE2             4 /* FTEXT in tree CMDLINE */ /* max len 63 */
#define COK                5 /* BUTTON in tree CMDLINE */
#define CCANCEL            6 /* BUTTON in tree CMDLINE */

#define TERMALL            4 /* form/dialog */
#define TALL               5 /* BUTTON in tree TERMALL */

#define TERMTOS            5 /* form/dialog */
#define TERMNAME           5 /* STRING in tree TERMTOS */
#define TTOS               6 /* BUTTON in tree TERMTOS */

#define CLPBRD             6 /* form/dialog */
#define CC_END             3 /* BUTTON in tree CLPBRD */
#define CC_DEL             4 /* BUTTON in tree CLPBRD */
#define CC_DONT            5 /* BUTTON in tree CLPBRD */
#define CI_CR              7 /* BUTTON in tree CLPBRD */
#define CI_LF              8 /* BUTTON in tree CLPBRD */
#define CI_DEL             9 /* BUTTON in tree CLPBRD */
#define CI_DONT           10 /* BUTTON in tree CLPBRD */
#define CLP_OK            11 /* BUTTON in tree CLPBRD */

#define SAVEINF            7 /* form/dialog */
#define SSAVE              5 /* BUTTON in tree SAVEINF */

#define CANTTERM           8 /* form/dialog */

#define TOSENDE            9 /* form/dialog */
#define TERM_CLOSE         3 /* BUTTON in tree TOSENDE */
#define TERM_FG            5 /* BUTTON in tree TOSENDE */
#define TERM_BG            6 /* BUTTON in tree TOSENDE */
#define TERM_QUIT          7 /* BUTTON in tree TOSENDE */
#define VT52_TERM_OK       8 /* BUTTON in tree TOSENDE */
#define TERM_CANCEL        9 /* BUTTON in tree TOSENDE */

#define T_ICONIFIED1      10 /* form/dialog */

#define T_ICONIFIED2      11 /* form/dialog */

#define NOWINDOWS          0 /* Alert string */
/* [1][Keine weiteren Fenster!][ Abbruch ] */

#define FSHEADL            1 /* Free string */
/* TOS-Programm starten */

#define PRG_TERM           2 /* Free string */
/* Programm beendet */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD vt52_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD vt52_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD vt52_rsc_free(void);
#endif
