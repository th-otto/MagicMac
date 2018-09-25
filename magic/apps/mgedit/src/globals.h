#define NWINDOWS 64

#define WFLAG_ICONIFIED	1
#define WFLAG_SHADED	2

#define EDITFELD 0

typedef struct _window
{
	int		handle;			/* Handle oder 0 */
	int		flags;			/* Bit 0: Ikonifiziert */
	int		save_active;		/* Dateiauswahl offen: NurLesen */
	char		title[128];		/* Titelzeile */
	GRECT 	out;				/* Fenster- Gesamtmaûe */
	GRECT	in;				/* Fenster- Innenmaûe */
	char		path[128];
	char		*buf;
	long		nlines;
	long		yscroll;
	WORD		yvis;
	long		ncols;
	long		xscroll;
	WORD		xvis;
	long		bufsize;
	int		dirty;			/* Text wurde geÑndert */
	OBJECT	tree;			/* nur ein Objekt */
	XEDITINFO *xedit;
	int		fontID;
	int		fontH;
	int		fontprop;			/* proportionaler Zeichensatz */
	int		tcolour;			/* Textfarbe */
	int		bcolour;			/* Hintergrundfarbe */
	int		tabwidth;			/* TabulatorlÑnge */
} WINDOW;

typedef union _wmesag 
{
	int		message[8];
	struct	{
		int	code;
		int	dest_apid;
		int	is_zero;
		int	whdl;
		GRECT g;
		}
		msg;
} WMESAG;

extern int close_file( WINDOW *w );

/* FÅr Fenster */
extern int	top_whdl( void );
extern WINDOW *windows[NWINDOWS];
extern WINDOW **new_window( void );
extern WINDOW *whdl2window(int whdl);
extern WINDOW **find_slot_window( WINDOW *myw );
extern WINDOW *open_new_window( char *path );
extern WINDOW *whdl2window(int whdl);
extern void window_message(WINDOW *w, int kstate, int message[16]);
extern void window_set_slider(WINDOW *w);
extern void close_window( WINDOW *w );

/***/

extern int update_window(WINDOW *w, GRECT *g);


extern void subobj_wdraw(void *d, int obj, int startob, int depth);
extern void options_dial_init_rsc( void );
extern WORD cdecl hdl_options( DIALOG *d, EVNT *events, WORD exitbutton,
				WORD clicks, void *data );
extern void prefs_were_changed( void );
extern int ncolours;
extern OBJECT *adr_options;
extern OBJECT *adr_colour;
extern void *d_options;
extern GRECT scrg;

extern struct prefs {
	long bufsize;
	int fontID;
	int fontH;
	int fontprop;
	char fontname[128];
	int tcolour;
	int bcolour;
	int tabwidth;
	GRECT prefs_win;
} prefs;

/* Notiz-Fenster */

#define MAXWIDTH 40		/* Maximale Textbreite in Zeichen */
#define MOVER_HEIGHT 3	/* Hîhe des MOVERs in Pixeln */
#define MOVER_COLOUR LWHITE	/* Farbe des MOVERs */
#define EDITOR_W_KIND (NAME+CLOSER+FULLER+MOVER+SIZER+UPARROW+DNARROW+VSLIDE+HSLIDE+LFARROW+RTARROW/*+SMALLER*/)
extern void save_options( void );
extern int dial_font( long *id, long *pt, int *mono, char *name );
