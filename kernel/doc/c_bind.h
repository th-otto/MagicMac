/*
*
* Alle Funktionen des MagiC-Kernels, die von
* PureC aus aufgerufen werden koennen
*
*/


/* MATH */
/* ---- */

LONG _lmul(LONG fak1, LONG fak2);	/* d0 = fak1, d1 = fak2 */
LONG _ldiv(LONG dividend, LONG divisor);	/* d0 = divd, d1 = divisor */

/* BIOS */
/* ---- */

void putch(char c);
char altcode_asc( WORD key );
void fast_clrmem(void *von, void *bis);

/* DOS */
/* --- */

LONG Mfree( void *memblk );	/* a0 = memblk */
LONG px_malloc( LONG len );	/* d0 = len */
LONG px_Mfree( void *buf );	/* a0 = buf */
LONG px_mshrink( void *buf, LONG size );

/* AES */
/* --- */

typedef struct
{
	WORD	x;
	WORD	y;
	WORD	bstate;
	WORD	kstate;
} EVNTDATA;

typedef struct
{
	EVNTDATA evd;
	WORD	key;
	WORD	nclicks;
} EVNT_MULTI_DATA;

WORD vq_gdos( void );
WORD enable_3d;

extern void obj_to_g( OBJECT *tree, WORD objnr, GRECT *g);
void set_clip_grect( GRECT *g );
void vdi( VDIPB *pb );
char *fn_name( char *path );
void _rsrc_rcfix(void *global, RSHDR *rsc);

extern void objc_add( OBJECT *tree, WORD parent, WORD child);
extern void objc_delete( OBJECT *tree, WORD objnr);
WORD wind_update( WORD mode );	/* d0 = mode */
WORD appl_yield( void );
WORD _evnt_timer(LONG clicks_50hz);	/* d0 = clicks_50hz */
WORD cdecl _evnt_multi(WORD mtypes, MGRECT *mm1, MGRECT *mm2, LONG ms,
					LONG but, WORD mbuf[8], EVNT_MULTI_DATA *ev);

WORD cdecl _form_wkeybd(OBJECT *tree, WORD objnr, WORD *c, WORD *nxtob, WORD whandle);
WORD _form_popup( OBJECT *ob,  LONG xy );
WORD form_xdo( OBJECT *tree, WORD startob, WORD *endob,
				void *keytab, FLYINF *fi );
void frm_xdial(WORD flag, GRECT *little, GRECT *big,
					void **flyinf);
WORD form_xerr(LONG err, const char *file);
WORD form_button(OBJECT *tree, WORD objnr, WORD clicks,
					WORD *nxt_edit);
WORD form_wbutton(OBJECT *tree, WORD objnr, WORD clicks,
					WORD *nxt_edit, WORD whandle);

void _graf_mkstate( EVNTDATA *ev );

extern WORD menu_modify( OBJECT *tree, WORD objnr, WORD statemask,
				WORD active, WORD do_draw, WORD not_disabled);
void graf_mouse( WORD typ, void *data);
WORD graf_slidebox( OBJECT *tree, WORD parent, WORD objnr, WORD is_vertikal);
WORD grects_intersect( const GRECT *srcg, GRECT *dstg);
WORD xy_in_grect( WORD x, WORD y, GRECT *g );
void drawbox( WORD wmode, WORD colour, WORD aes_patt, GRECT *g);
cdecl WORD xp_rasterC( LONG words, LONG len, WORD planes,
					void *src, void *des );


void _form_center_grect(OBJECT *ob, GRECT *out);
void calc_obsize( OBJECT *tree, GRECT *size );
WORD _objc_edit(OBJECT *tree, WORD objnr,
			 WORD c, WORD *didx, WORD kind, GRECT *g);
void _objc_draw(OBJECT *tree, WORD startob, WORD depth);
void _objc_change(OBJECT *tree, WORD objnr,
			WORD newstate, WORD draw);
void objc_offset(OBJECT *tree, WORD objnr, WORD *x, WORD *y);
void fast_save_scr( GRECT *g );
int scrg_sav( GRECT *g, void **pbuf);
void scrg_rst( void **pbuf );
void cdecl blitcopy_rectangle(int src_x, int src_y,
					 int dst_x, int dst_y, int w, int h);
WORD _objc_find( OBJECT *tree, WORD startob,
			WORD depth, LONG xy );

WORD _wind_create( WORD typ, GRECT *full );
WORD wind_delete(WORD whdl);
WORD _wind_get(WORD whdl, WORD code, WORD *g);
WORD _wind_set(WORD whdl, WORD opcode, WORD koor[4]);
WORD _wind_calc( WORD type,  WORD kind,
			 GRECT *in, GRECT *out);
WORD _wind_open(WORD whdl, GRECT *g);
WORD wind_close( WORD whdl);
WORD wind_find(WORD x, WORD y );


extern GRECT desk_g,full_g;
extern WORD big_hchar,big_hchar;
extern MN_SET vmn_set;
