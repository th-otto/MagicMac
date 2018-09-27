/*
*
* exportierte Dateiauswahl-Funktionen
*
*/

/* Sortiermodi */

#define SORTBYNAME  0
#define SORTBYDATE  1
#define SORTBYSIZE  2
#define SORTBYTYPE  3
#define SORTBYNONE  4

/* Flags für Dateiauswahl */

#define DOSMODE     1
#define NFOLLOWSLKS 2
#define GETMULTI    8

/* Globale Einstellungen (fslx_set) */

#define SHOW8P3     1

extern void * fslx_open(
               char *title,
               WORD x, WORD y,
               WORD *handle,
               char *path, WORD pathlen,
               char *fname, WORD fnamelen,
               char *patterns,
               WORD cdecl (*filter)(char *path, char *name, XATTR *xa),
               char *paths,
               WORD sort_mode,
               WORD flags);

extern WORD fslx_evnt(
               void *fsd,
               EVNT *events,
               char *path,
               char *fname,
               WORD *button,
               WORD *nfiles,
               WORD *sort_mode,
               char **pattern );

extern void * fslx_do(
               char *title,
               char *path, WORD pathlen,
               char *fname, WORD fnamelen,
               char *patterns,
               WORD cdecl (*filter)(char *path, char *name, XATTR *xa),
               char *paths,
               WORD *sort_mode,
               WORD flags,
               WORD *button,
               WORD *nfiles,
               char **pattern );

extern WORD fslx_getnxtfile(
               void *fsd,
               char *fname );

extern WORD fslx_close( void *fsd );

extern WORD fslx_set(
               WORD subfn,
               WORD flags,
               WORD *oldval );
