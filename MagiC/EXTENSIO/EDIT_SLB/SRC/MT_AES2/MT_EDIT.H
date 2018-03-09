#define G_EDIT 37

typedef void XEDITINFO;
extern XEDITINFO *mt_edit_create( WORD *global );
extern WORD mt_edit_open(OBJECT *tree, WORD obj, WORD *global);
extern void mt_edit_close(OBJECT *tree, WORD obj, WORD *global);
extern void mt_edit_delete(XEDITINFO *xi, WORD *global);
extern WORD mt_edit_cursor(OBJECT *tree, WORD obj, WORD whdl, WORD show, WORD *global);
extern WORD mt_edit_evnt(OBJECT *tree, WORD obj, WORD whdl,	EVNT *ev, WORD *global);
extern WORD mt_edit_get_buf( OBJECT *tree, WORD obj, char **buf, LONG *buflen, LONG *txtlen, WORD *global );
extern WORD mt_edit_get_format( OBJECT *tree, WORD obj, WORD *tabwidth, WORD *autowrap, WORD *global );
extern WORD mt_edit_get_colour( OBJECT *tree, WORD obj, WORD *tcolour, WORD *bcolour, WORD *global );
extern WORD mt_edit_get_cursor( OBJECT *tree, WORD obj, char **cursorpos, WORD *global );
extern WORD mt_edit_get_font( OBJECT *tree, WORD obj,	WORD *fontID, WORD *fontH, WORD *mono, WORD *global );
extern void mt_edit_set_buf( OBJECT *tree, WORD obj, char *buf, LONG buflen, WORD *global );
extern void mt_edit_set_format( OBJECT *tree, WORD obj, WORD tabwidth, WORD autowrap, WORD *global );
extern void mt_edit_set_font( OBJECT *tree, WORD obj, WORD fontID, WORD fontH, WORD mono,	WORD *global );
extern void mt_edit_set_colour( OBJECT *tree, WORD obj, WORD tcolour, WORD bcolour, WORD *global );
extern void mt_edit_set_cursor( OBJECT *tree, WORD obj, char *cursorpos, WORD *global );
extern WORD mt_edit_resized( OBJECT *tree, WORD obj, WORD *oldrh, WORD *newrh, WORD *global );
extern WORD mt_edit_get_dirty( OBJECT *tree, WORD obj,	WORD *global );
extern void mt_edit_set_dirty( OBJECT *tree, WORD obj,	WORD dirty, WORD *global );
extern void mt_edit_get_sel( OBJECT *tree, WORD obj, char **bsel, char **esel, WORD *global );
extern void mt_edit_get_pos( OBJECT *tree, WORD obj, WORD *xscroll, LONG *yscroll, char **cyscroll, char **cursorpos, WORD *cx, WORD *cy, WORD *global );
extern void mt_edit_set_pos( OBJECT *tree, WORD obj, WORD xscroll, LONG yscroll, char *cyscroll, char *cursorpos, WORD cx, WORD cy, WORD *global );
extern void mt_edit_get_scrollinfo( OBJECT *tree, WORD obj,	LONG *nlines, LONG *yscroll, WORD *yvis, WORD *yval, WORD *ncols, WORD *xscroll, WORD *xvis, WORD *global );
extern WORD mt_edit_scroll( OBJECT *tree, WORD obj, WORD whdl, LONG yscroll, WORD xscroll, WORD *global );

#define edit_create() mt_edit_create(NULL)
#define edit_open(a,b) mt_edit_open(a,b,NULL)
#define edit_close(a,b) mt_edit_close(a,b,NULL)
#define edit_delete(a) mt_edit_delete(a,NULL)
#define edit_evnt(a,b,c,d) mt_edit_evnt(a,b,c,d,NULL)
#define edit_get_buf(a,b,c,d,e) mt_edit_get_buf(a,b,c,d,e,NULL)
#define edit_set_buf(a,b,c,d) mt_edit_set_buf(a,b,c,d,NULL)
#define edit_set_format(a,b,c,d) mt_edit_set_format(a,b,c,d,NULL)
#define edit_get_format(a,b,c,d) mt_edit_get_format(a,b,c,d,NULL)
#define edit_set_font(a,b,c,d,e) mt_edit_set_font(a,b,c,d,e,NULL)
#define edit_get_font(a,b,c,d,e) mt_edit_get_font(a,b,c,d,e,NULL)
#define edit_set_colour(a,b,c,d) mt_edit_set_colour(a,b,c,d,NULL)
#define edit_resized(a,b,c,d) mt_edit_resized(a,b,c,d,NULL)
#define edit_get_dirty(a,b) mt_edit_get_dirty(a,b,NULL)
#define edit_set_dirty(a,b,c) mt_edit_set_dirty(a,b,c,NULL)
#define edit_get_sel(a,b,c,d) mt_edit_get_sel(a,b,c,d,NULL)
#define edit_get_pos(a,b,c,d,e,f,g,h) mt_edit_get_pos(a,b,c,d,e,f,g,h,NULL)
#define edit_set_pos(a,b,c,d,e,f,g,h) mt_edit_set_pos(a,b,c,d,e,f,g,h,NULL)
#define edit_get_scrollinfo(a,b,c,d,e,f,g,h,i) mt_edit_get_scrollinfo(a,b,c,d,e,f,g,h,i,NULL)
#define edit_scroll(a,b,c,d,e) mt_edit_scroll(a,b,c,d,e,NULL)
