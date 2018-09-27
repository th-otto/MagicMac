/*
 * resource set indices for mgformat
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        76
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       2
 * Number of Free Strings:   20
 * Number of Free Images:    0
 * Number of Objects:        69
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          6156
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "mgformat"
#endif
#undef RSC_ID
#ifdef mgformat
#define RSC_ID mgformat
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 76
#define NUM_FRSTR 20
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 2
#define NUM_OBS 69
#define NUM_TREE 4
#endif



#define T_FORMAT           0 /* form/dialog */
#define FORMAT_T           2 /* FTEXT in tree T_FORMAT */ /* max len 11 */
#define FORMT_R1           3 /* BUTTON in tree T_FORMAT */
#define FORMT_T1           4 /* STRING in tree T_FORMAT */
#define FORMT_S1           6 /* BUTTON in tree T_FORMAT */
#define FORMT_S2           7 /* BUTTON in tree T_FORMAT */
#define FORMT_T2           8 /* STRING in tree T_FORMAT */
#define TRK_MINU           9 /* BOXCHAR in tree T_FORMAT */
#define TRK_NUM           10 /* BUTTON in tree T_FORMAT */
#define TRK_PLUS          11 /* BOXCHAR in tree T_FORMAT */
#define FORMT_T3          12 /* STRING in tree T_FORMAT */
#define SEC_MINU          13 /* BOXCHAR in tree T_FORMAT */
#define SEC_NUM           14 /* BUTTON in tree T_FORMAT */
#define SEC_PLUS          15 /* BOXCHAR in tree T_FORMAT */
#define FORMT_DD          16 /* BUTTON in tree T_FORMAT */
#define FORMT_HD          17 /* BUTTON in tree T_FORMAT */
#define FORMT_EX          18 /* BUTTON in tree T_FORMAT */
#define FORMT_H1          19 /* STRING in tree T_FORMAT */
#define FORMT_DT          20 /* STRING in tree T_FORMAT */
#define FORMT_OK          21 /* BUTTON in tree T_FORMAT */
#define FORMT_IN          22 /* BUTTON in tree T_FORMAT */
#define FORMT_AB          23 /* BUTTON in tree T_FORMAT */

#define T_FMTOPT           1 /* form/dialog */
#define INT_MINU           3 /* BOXCHAR in tree T_FMTOPT */
#define INT_NUM            4 /* BUTTON in tree T_FMTOPT */
#define INT_PLUS           5 /* BOXCHAR in tree T_FMTOPT */
#define SPV_MINU           7 /* BOXCHAR in tree T_FMTOPT */
#define SPV_NUM            8 /* BUTTON in tree T_FMTOPT */
#define SPV_PLUS           9 /* BOXCHAR in tree T_FMTOPT */
#define SEV_MINU          11 /* BOXCHAR in tree T_FMTOPT */
#define SEV_NUM           12 /* BUTTON in tree T_FMTOPT */
#define SEV_PLUS          13 /* BOXCHAR in tree T_FMTOPT */
#define CLU_MINU          15 /* BOXCHAR in tree T_FMTOPT */
#define CLU_NUM           16 /* BUTTON in tree T_FMTOPT */
#define CLU_PLUS          17 /* BOXCHAR in tree T_FMTOPT */
#define FMOPT_TM          18 /* FTEXT in tree T_FMTOPT */ /* max len 1 */
#define FMOPT_SV          19 /* BUTTON in tree T_FMTOPT */
#define FMOPT_OK          20 /* BUTTON in tree T_FMTOPT */
#define FMOPT_AB          21 /* BUTTON in tree T_FMTOPT */

#define T_CPYDSK           2 /* form/dialog */
#define CPYDS_QU           3 /* BUTTON in tree T_CPYDSK */
#define CPYDS_ZI           5 /* BUTTON in tree T_CPYDSK */
#define CPYDS_R1           6 /* BUTTON in tree T_CPYDSK */
#define CPYDS_FM           7 /* BUTTON in tree T_CPYDSK */
#define CPYDS_OH           8 /* BUTTON in tree T_CPYDSK */
#define CPYDS_H1           9 /* STRING in tree T_CPYDSK */
#define CPYDS_SI          10 /* STRING in tree T_CPYDSK */
#define CPYDS_H2          11 /* STRING in tree T_CPYDSK */
#define CPYDS_TR          12 /* STRING in tree T_CPYDSK */
#define CPYDS_H3          13 /* STRING in tree T_CPYDSK */
#define CPYDS_SC          14 /* STRING in tree T_CPYDSK */
#define CPYDS_DO          15 /* STRING in tree T_CPYDSK */
#define CPYDS_H4          16 /* STRING in tree T_CPYDSK */
#define CPYDS_DT          17 /* STRING in tree T_CPYDSK */
#define CPYDS_OK          18 /* BUTTON in tree T_CPYDSK */
#define CPYDS_AB          19 /* BUTTON in tree T_CPYDSK */
#define CPYDS_EX          20 /* BUTTON in tree T_CPYDSK */

#define T_ICONIF           3 /* form/dialog */

#define AL_TMPINV          0 /* Alert string */
/* [1][Lecteur temporaire invalide !][Abandon] */

#define AL_DEL_ALL         1 /* Alert string */
/* [2][Toutes les donnÇes du lecteur %c:|seront effacÇes!][OK|Abandon] */

#define AL_COMPLETE        2 /* Alert string */
/* [1][FORMAT:|Formatage terminÇ.][ OK ] */

#define AL_BREAK           3 /* Alert string */
/* [3][FORMAT:|Formatage abandonnÇ.][ OK ] */

#define AL_DISKCP_COMPL    4 /* Alert string */
/* [1][DISKCOPY:|Copie des disquettes terminÇe.][ OK ] */

#define AL_DISKCP_BREAK    5 /* Alert string */
/* [3][DISKCOPY:|Copie des disquettes abandonnÇe.][ OK ] */

#define AL_OPENWIND        6 /* Alert string */
/* [3][Ouverture de fenàtre impossible !][Abandon] */

#define AL_ASK_BREAK       7 /* Alert string */
/* [1][FORMAT:|Abandonner ?][ OUI | NON ] */

#define AL_OLD_OSVERSION   8 /* Alert string */
/* [3][FORMAT:|Ancienne version d'OS !][Abandon] */

#define AL_DISK_IN_USE     9 /* Alert string */
/* [3][FORMAT:|Lecteur dÇjÖ en utilisation!][Abandon] */

#define AL_DSKNOTLOCKABL  10 /* Alert string */
/* [3][FORMAT:|Le lecteur ne peut àtre verrouillÇ!][Abandon] */

#define AL_DSK_LOCKED_BY  11 /* Alert string */
/* [3][FORMAT:|Lecteur dÇjÖ bloquÇ par %s.][Abandon] */

#define AL_CAN_RETR_CONT  12 /* Alert string */
/* [2][FORMAT:|%s dans lecteur %c:][Abandon|RÇpeter|Suite] */

#define AL_INSERT_DISK    13 /* Alert string */
/* [2][DISKCOPY:|insÇrez la disquette %s|dans %c: !][OK|Abandon] */

#define AL_ASK_FORMAT     14 /* Alert string */
/* [2][DISKCOPY:|Formater ?][OK|Abandon] */

#define STR_WRITE         15 /* Free string */
/* êcrire */

#define STR_FORMAT        16 /* Free string */
/* Formater */

#define STR_READ          17 /* Free string */
/* Lire */

#define STR_SOURCE        18 /* Free string */
/* source */

#define STR_DEST          19 /* Free string */
/* cible */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD mgformat_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD mgformat_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD mgformat_rsc_free(void);
#endif
