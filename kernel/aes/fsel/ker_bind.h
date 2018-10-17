/*
*
* Bindings zum Aufruf des MagiC-Kernels
*
*/

typedef struct pd
{
   void   *p_lowtpa;
   void   *p_hitpa;
   void   *p_tbase;
   LONG   p_tlen;
   void   *p_dbase;
   LONG   p_dlen;
   void   *p_bbase;
   LONG   p_blen;
   DTA    *p_dta;
   struct pd *p_parent;
   WORD   p_res0;
   WORD   p_res1;
   char   *p_env;
   char   p_devx[6];
   char   p_res2;
   char   p_defdrv;
   LONG   p_res3[18];
   char   p_cmdlin[128];
} PD;

typedef struct {
     LONG       *ap_next;      /* 0x00: Verkettungszeiger  */
     WORD       ap_id;         /* 0x04: Application-Id     */
     } APPL;

typedef struct {
     WORD      fontID;        /* Font-ID */
     WORD      fontH;         /* Netto-Zeichenhöhe für vst_height */
     WORD      fontmono;      /* Flag für "monospaced" */
     WORD      fontcharW;     /* Zeichenbreite bei mono */
     WORD      fontcharH;     /* Zeichenhöhe (brutto) */
     WORD      fontUpos;      /* Position des Unterstrichs */
     } FONTINFO;

#if DEBUG
extern void putch(char c);
#endif
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
extern void *smalloc(LONG size);
extern LONG smfree( void *memblk );
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
extern void _form_center(OBJECT *ob, GRECT *out );
extern WORD _form_popup( OBJECT *ob,  LONG xy );
extern int form_xerr(LONG err, char *file);
extern void frm_xdial(WORD flag, GRECT *little, GRECT *big,
                         void **flyinf);
extern WORD form_xdo( OBJECT *tree, WORD startob, WORD *endob,
                    void *keytab, void *fi );
extern void fs_txt( char *text, GRECT *rahmen );
extern void fs_rtxt( char *text, GRECT *rahmen );
extern WORD fs_xtnt( char *s );
extern void fs_effct( WORD texteffects );
extern void graf_rbox( int x, int y, int minw,
                        int minh, int *neuw, int *neuh);
extern void hexl( LONG i);
