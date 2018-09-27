#include <wdlgwdlg.h>

#define NOTICE_MEM	512		/* Bytes pro Notiz */
#define EDITFELD 0			/* Objekt #0 ist G_EDIT */

extern void subobj_wdraw(void *d, int obj, int startob, int depth);
extern void options_dial_init_rsc( void );
extern WORD cdecl hdl_options(struct HNDL_OBJ_args);

extern int ncolours;
extern WINDOW *selected_window;
extern OBJECT *adr_options;
extern OBJECT *adr_colour;
extern void *d_options;
extern GRECT scrg;
extern char *notice_path;

extern struct prefs {
	int fontID;
	int fontH;
	int fontprop;
	char fontname[128];
	int colour;
	GRECT prefs_win;
} prefs;

/* Notiz-Fenster */

#define MAXWIDTH 40		/* Maximale Textbreite in Zeichen */
#define MOVER_HEIGHT 0	/* H”he des MOVERs in Pixeln */
/* #define MOVER_HEIGHT 3	*/	/* H”he des MOVERs in Pixeln */
#define MOVER_COLOUR LWHITE	/* Farbe des MOVERs */
#define NOTICE_W_KIND	0
extern void save_options( void );
extern void top_all_my_windows( void );
extern int dial_font( long *id, long *pt, int *mono, char *name );
extern void create_notice( int x, int y );
extern long save_notice( WINDOW *w, char *path );
extern void calc_size_notice_wind( WINDOW *w );
extern unsigned char *get_line(unsigned char *text,
						long n, long *lw );
extern void select_window( WINDOW *w );
extern void deselect_window( WINDOW *w );
extern long open_notice_wind( unsigned char *notice,
					int id,
					GRECT *g,
					int fontID, int font_is_prop, int fontH,
					int colour,
					WINDOW **pw );
long edit_notice_wind( unsigned char *notice, int id,
					WINDOW **pw );