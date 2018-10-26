/*
*
* Bindings zum Aufruf des MagiC-Kernels
*
*/

#include "pd.h"

typedef struct {
     WORD      fontID;        /* Font-ID */
     WORD      fontH;         /* Netto-Zeichenhoehe fuer vst_height */
     WORD      fontmono;      /* Flag fuer "monospaced" */
     WORD      fontcharW;     /* Zeichenbreite bei mono */
     WORD      fontcharH;     /* Zeichenhoehe (brutto) */
     WORD      fontUpos;      /* Position des Unterstrichs */
     } FONTINFO;

#ifndef _SCANX
#define _SCANX
typedef struct {
     unsigned char scancode;
     unsigned char nclicks;
     WORD  objnr;
     } SCANX;
#endif

#ifndef _XDO_INF
#define _XDO_INF
typedef struct {
     SCANX *unsh;
     SCANX *shift;
     SCANX *ctrl;
     SCANX *alt;
     void  *resvd;
     } XDO_INF;
#endif

typedef struct
{
	WORD	flag;
	GRECT	g;
} MGRECT;

extern void putch(char c);
extern void putstr( char *s);
extern PD *act_pd;
extern FONTINFO finfo_big;
extern APPL *act_appl;
extern WORD fslx_sortmode;
extern WORD fslx_flags;
extern WORD grects_intersect( const GRECT *srcg, GRECT *dstg);
extern WORD _wind_get(WORD whdl, WORD code, WORD *g );
extern void _rsrc_rcfix(void *global, RSHDR *rsc);
extern LONG drvmap( void );
extern LONG smalloc(ULONG size);
extern void smfree( void *memblk );
extern LONG smshrink( void *memblk, ULONG size);
extern WORD dgetdrv( void );
extern LONG dpathconf(char *path, WORD which);
extern LONG dopendir( char *path, WORD tosflag );
extern LONG dclosedir( LONG dirhandle );
extern LONG dxreaddir( WORD len, LONG dirhandle, char *buf,
               XATTR *xattr, LONG *xr );
extern LONG fxattr( WORD mode, char *path, XATTR *xattr );
extern LONG dgetpath( char *buf, WORD drv );
extern char *_ltoa( LONG l, char *s);
extern void set_clip_grect(GRECT *g);
extern WORD _objc_edit(OBJECT *tree, WORD objnr, WORD c, WORD *didx, WORD kind, GRECT *g );
extern void _objc_draw(OBJECT *tree, WORD startob, WORD depth);
extern void _form_center_grect(OBJECT *ob, GRECT *out );
extern WORD _form_popup( OBJECT *ob,  LONG xy );
extern int form_xerr(LONG err, const char *file);
extern void frm_xdial(WORD flag, GRECT *little, GRECT *big,
                         void **flyinf);
extern WORD form_xdo( OBJECT *tree, WORD startob, WORD *endob,
                    XDO_INF *keytab, void *fi );
extern void fs_txt( char *text, GRECT *rahmen );
extern void fs_rtxt( char *text, GRECT *rahmen );
extern WORD fs_xtnt( char *s );
extern void fs_effct( WORD texteffects );
extern void graf_rbox( int x, int y, int minw,
                        int minh, int *neuw, int *neuh);
extern void hexl( LONG i);
extern WORD _evnt_timer( LONG clicks_50hz );
extern void _graf_mkstate( WORD data[4] );
extern void set_clip_grect( GRECT *g );
extern void cdecl blitcopy_rectangle( WORD src_x, WORD src_y, WORD dst_x, WORD dst_y, WORD w, WORD h );
extern WORD appl_yield( void );
extern int cdecl _evnt_multi( WORD mtypes, MGRECT *mm1, MGRECT *mm2, LONG ms, LONG but, WORD *mbuf, WORD *out );
extern void _objc_change( OBJECT *tree, WORD objnr, WORD newstate, WORD draw );
extern WORD _wind_get_grect( WORD whdl, WORD code, GRECT *g );
