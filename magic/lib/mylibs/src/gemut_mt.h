#define EOS    '\0'
#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif
#ifndef TRUE
#define	TRUE	1
#define	FALSE 0
#endif

#define USA	0
#define FRG	1

#define SCREEN      0
#define VA_START		0x4711
#define AV_OPENWIND		0x4720
#define AV_XOPENWIND	0x4740
#define AV_STARTED		0x4738

extern void print_values(char *s, int n, int values[]);
extern int scan_values(char **s, int n, int values[]);
extern void Mrsrc_load( char *fname, WORD *global );
extern void objc_grect(OBJECT *tree, int objn, GRECT *g);
extern void subobj_draw(OBJECT *tree, int obj, int start, int depth);
extern int rc_intersect(GRECT *p1, GRECT *p2);
extern void  Mgraf_mouse(int type);
extern void objs_hide(OBJECT *tree, ...);
extern void objs_unhide(OBJECT *tree, ...);
extern void objs_disable(OBJECT *tree, ...);
extern void objs_enable(OBJECT *tree, ...);
extern int selected(OBJECT *tree, int which);
extern void ob_dsel(OBJECT *tree, int which);
extern void ob_sel_dsel(OBJECT *tree, int which, int sel);
extern void ob_sel(OBJECT *tree, int which);
extern void objs_setradio(OBJECT *tree, int set, ...);
extern void objs_getradio(OBJECT *tree, int *get, ...);
extern int top_whdl( void );
extern int find_obj(OBJECT *tree, int x, int y);

extern int vdi_handle;
void open_work(void);
extern int work_out[57],work_in[12];
extern int ap_id;
extern GRECT scrg;
extern int gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;

extern char *get_name(char *path);
extern void fname_int(char *s, char *d);
extern void fname_ext(char *s, char *d);
extern int is_absolute_path(char *path);
extern char *Rgetstring( WORD string_id, WORD *global );
extern WORD Rform_alert( WORD defbutton, WORD alert_id, WORD *global );
extern WORD Rxform_alert( WORD defbutton, WORD alert_id,
				char drv, char *path, WORD *global );
extern int do_dialog(OBJECT *dialog);
extern int do_exdialog(OBJECT *dialog,
			 int (*check)(OBJECT *dialog, int exitbutton),
			 int *was_redraw);
