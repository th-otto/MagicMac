/*
* INF.C definitions
*/

extern int n_windefpos;
extern WINDEFPOS windefpos[MAXWINDEFPOS];
extern char const applicat_inf[];

#define ICON_KEY_APPS 0x4150504cL /* 'APPS' */
#define ICON_KEY_DATS 0x44415453L /* 'DATS' */
#define ICON_KEY_BTCH 0x42415448L /* 'BTCH' */
#define ICON_KEY_DEVC 0x44455643L /* 'DEVC' */
#define ICON_KEY_ALIS 0x414c4953L /* 'ALIS' */
#define ICON_KEY_FLDR 0x464c4452L /* 'FLDR' */
#define ICON_KEY_DRVS 0x44525653L /* 'DRVS' */
#define ICON_KEY_TRSH 0x54525348L /* 'TRSH' */
#define ICON_KEY_PRNT 0x50524e54L /* 'PRNT' */

void error(int id);
WINDEFPOS *def_wind_pos(const char *s);
long put_inf(void);
