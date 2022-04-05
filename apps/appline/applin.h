#include <stdio.h>
#include <string.h>
#ifdef __SOZOBONX__
#include <xgemfast.h>
#define _DTA DTA
#define d_fname dta_fname
#include <atari.h>
#include <osbind.h>
#else
#ifdef __PUREC__
#include <aes.h>
#include <tos.h>
#else
#include <gem.h>
#include <osbind.h>
#endif
#endif

#ifndef _WORD
#if defined(__PUREC__) || defined(__SOZOBONX__)
#define _WORD int
#else
#define _WORD short
#endif
#endif


#ifndef FALSE
#  define FALSE 0
#  define TRUE  1
#endif

/* SM_M_SPECIAL codes */
#define SMC_TIDY_UP     0           /* MagiC 2  */
#define SMC_TERMINATE   1           /* MagiC 2  */
#define SMC_SWITCH      2           /* MagiC 2  */
#define SMC_FREEZE      3           /* MagiC 2  */
#define SMC_UNFREEZE    4           /* MagiC 2  */
#define SMC_RES5        5           /* MagiC 2  */
#define SMC_UNHIDEALL   6           /* MagiC 3.1 */
#define SMC_HIDEOTHERS  7           /* MagiC 3.1 */
#define SMC_HIDEACT     8           /* MagiC 3.1 */

/*
 * These macros seems to be needed for SozobonX
 * to prevent it from calling a long multiply routine
 * every time an object address is calculated
 */
#define OB_NEXT(t, x)   (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 0))))
#define OB_HEAD(t, x)   (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 2))))
#define OB_TAIL(t, x)   (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 4))))
#define OB_TYPE(t, x)   (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 6))))
#define OB_FLAGS(t, x)  (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 8))))
#define OB_STATE(t, x)  (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 10))))
#define OB_SPEC(t, x)   (*((long  *)(((char *)(t) + (x) * sizeof(OBJECT) + 12))))
#define OB_X(t, x)      (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 16))))
#define OB_Y(t, x)      (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 18))))
#define OB_WIDTH(t, x)  (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 20))))
#define OB_HEIGHT(t, x) (*((short *)(((char *)(t) + (x) * sizeof(OBJECT) + 22))))


#ifdef __SOZOBONX__
_WORD shel_find(char *path);
_WORD wind_update(_WORD what);
_WORD wind_get(_WORD hdl, _WORD what, ...);
_WORD objc_draw(OBJECT *tree, _WORD obj, _WORD max_depth, _WORD x, _WORD y, _WORD w, _WORD h);
_WORD appl_write(_WORD app, _WORD len, _WORD *message);
_WORD wind_set(_WORD hdl, _WORD what, ...);
_WORD menu_bar(OBJECT *tree, _WORD what);
_WORD form_alert(_WORD button, const char *str);
_WORD appl_find();
void objc_offset_grect(OBJECT *tree, _WORD obj, GRECT *gr);
void evnt_timer(_WORD lo, _WORD hi);
void shel_envrn(char **val, const char *name);
_WORD winx_create(_WORD kind, GRECT gr);
_WORD winx_open(_WORD hdl, GRECT gr);
_WORD wind_close(_WORD hdl);
_WORD wind_delete(_WORD hdl);
_WORD objc_find(OBJECT *tree, _WORD start, _WORD maxdepth, _WORD x, _WORD y);
_WORD appl_init(void);
_WORD appl_exit(void);
_WORD rsrc_load(const char *filename);
_WORD rsrc_gaddr(_WORD type, _WORD index, void *addr);
_WORD rsrc_free(void);

#endif

#define PATH_MAX 128
