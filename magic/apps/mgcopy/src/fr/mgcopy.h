/*
 * resource set indices for mgcopy
 *
 * created by ORCS 2.16
 */

/*
 * Number of Strings:        68
 * Number of Bitblks:        0
 * Number of Iconblks:       0
 * Number of Color Iconblks: 1
 * Number of Color Icons:    1
 * Number of Tedinfos:       5
 * Number of Free Strings:   27
 * Number of Free Images:    0
 * Number of Objects:        38
 * Number of Trees:          4
 * Number of Userblks:       0
 * Number of Images:         0
 * Total file size:          5284
 */

#undef RSC_NAME
#ifndef __ALCYON__
#define RSC_NAME "mgcopy"
#endif
#undef RSC_ID
#ifdef mgcopy
#define RSC_ID mgcopy
#else
#define RSC_ID 0
#endif

#ifndef RSC_STATIC_FILE
# define RSC_STATIC_FILE 0
#endif
#if !RSC_STATIC_FILE
#define NUM_STRINGS 68
#define NUM_FRSTR 27
#define NUM_UD 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_CIB 1
#define NUM_TI 5
#define NUM_OBS 38
#define NUM_TREE 4
#endif



#define T_ICONIF           0 /* form/dialog */

#define T_CPMVDL           1 /* form/dialog */
#define CPMVDL_T           1 /* STRING in tree T_CPMVDL */
#define CPMVDL_D           3 /* STRING in tree T_CPMVDL */
#define CPMVDL_O           5 /* STRING in tree T_CPMVDL */
#define CPMVDL_B           7 /* STRING in tree T_CPMVDL */
#define CPMVD_MD           8 /* BUTTON in tree T_CPMVDL */
#define CPMVD_KB           9 /* BUTTON in tree T_CPMVDL */
#define CPMVD_KA          10 /* BUTTON in tree T_CPMVDL */
#define CPMVD_KU          11 /* BUTTON in tree T_CPMVDL */
#define CPMVD_RE          12 /* BUTTON in tree T_CPMVDL */
#define CPMVD_OK          13 /* BUTTON in tree T_CPMVDL */
#define CPMVD_AB          14 /* BUTTON in tree T_CPMVDL */

#define T_DATEXI           2 /* form/dialog */
#define DATEXI_T           1 /* STRING in tree T_DATEXI */
#define DATEXI_O           3 /* FTEXT in tree T_DATEXI */ /* max len 0 */
#define DATEXI_N           5 /* FTEXT in tree T_DATEXI */ /* max len 0 */
#define EX_SKIP            6 /* BUTTON in tree T_DATEXI */
#define EX_USE             7 /* BUTTON in tree T_DATEXI */
#define EX_OK              8 /* BUTTON in tree T_DATEXI */
#define EX_AB              9 /* BUTTON in tree T_DATEXI */

#define T_WORKING          3 /* form/dialog */
#define WORK_AK            1 /* TEXT in tree T_WORKING */ /* max len 17 */
#define WORK_DT            2 /* STRING in tree T_WORKING */
#define WORK_D             4 /* STRING in tree T_WORKING */
#define WORK_O             6 /* STRING in tree T_WORKING */
#define WORK_MAXIMAL       7 /* BOX in tree T_WORKING */
#define WORK_AKTUELL       8 /* BOX in tree T_WORKING */
#define WORK_STOP          9 /* BUTTON in tree T_WORKING */
#define WORK_EXP          10 /* BOXCHAR in tree T_WORKING */

#define ALRT_TOOBUSY       0 /* Alert string */
/* [3][MGCOPY:|File d'attente pleine.][Abandon] */

#define ALRT_ERRARG        1 /* Alert string */
/* [3][MGCOPY:|Erreur Ö la transmission de|paramätre !][Abandon] */

#define ALRT_INSUFFSPACE   2 /* Alert string */
/* [2][Trop peu de place sur le|lecteur de destination!][OK|Abandon] */

#define ALRT_FILE_RDONLY   3 /* Alert string */
/* [2][Le fichier|%c:%s|est protÇgÇ en Çcriture][Sauter|OK|Abandon] */

#define ALRT_STOPPROCESS   4 /* Alert string */
/* [1][Interrompre le processus ?][OUI| NON ] */

#define ALRT_DISKFULL      5 /* Alert string */
/* [3][Lecteur de destination plein!][Abandon] */

#define ALRT_ERROPENWIND   6 /* Alert string */
/* [2][La fenàtre ne peut àtre|ouverte !][Abandon] */

#define STR_MAINTITLE      7 /* Free string */
/*  Fichiers  */

#define STR_DELETEFILES    8 /* Free string */
/* Effacer fichiers */

#define STR_COPYFILES      9 /* Free string */
/* Copier fichiers */

#define STR_ALIASFILES    10 /* Free string */
/* CrÇer alias */

#define STR_MOVEFILES     11 /* Free string */
/* DÇplacer fichiers */

#define STR_FILE          12 /* Free string */
/* Fichier */

#define STR_ALIAS         13 /* Free string */
/* Alias */

#define STR_FOLDER        14 /* Free string */
/* Dossier */

#define STR_EXISTS        15 /* Free string */
/*  existe dÇjÖ */

#define STR_GIVENAME      16 /* Free string */
/*  renommer */

#define STR_NAMECONFLICT  17 /* Free string */
/*  Conflit de nom  */

#define STR_RENAME        18 /* Free string */
/*  Renommer  */

#define STR_DEL_FILE      19 /* Free string */
/* Effacer fichier */

#define STR_DEL_FOLDER    20 /* Free string */
/* Effacer dossier */

#define STR_MOVE_FILE     21 /* Free string */
/* DÇplacer fichier */

#define STR_READ_FILE     22 /* Free string */
/* Lire fichier */

#define STR_WRITE_FILE    23 /* Free string */
/* êcrire fichier */

#define STR_CREATE_FOLDR  24 /* Free string */
/* CrÇer dossier */

#define ALRT_INVAL_COPY   25 /* Alert string */
/* [3][Instruction de copie|non valable !][Abandon] */

#define ALRT_REPL_W_ALIA  26 /* Alert string */
/* [2][Remplacer le fichier|%c:%s|par un alias?][OK|Abandon] */




#ifdef __STDC__
#ifndef _WORD
#  ifdef WORD
#    define _WORD WORD
#  else
#    define _WORD short
#  endif
#endif
extern _WORD mgcopy_rsc_load(_WORD wchar, _WORD hchar);
extern _WORD mgcopy_rsc_gaddr(_WORD type, _WORD idx, void *gaddr);
extern _WORD mgcopy_rsc_free(void);
#endif
