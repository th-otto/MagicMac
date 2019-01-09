#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif

#define N_OBJS 16

#define TOP_WINOBJS	(NAME+CLOSER+FULLER+BACKDROP+ICONIFIER)
#define RGT_WINOBJS (UPARROW+DNARROW+VSLIDE)
#define BOT_WINOBJS (LFARROW+RTARROW+HSLIDE)

/* WINDOW-Struktur fuer MagiC-Kernel */

typedef struct {
	WORD state;
	WORD attr;
	void *own;			/* (APPL *) */
	WORD kind;			/* von wind_create() */
	char	*name;			/* Zeiger auf Titelzeile */
	char	*info;			/* Zeiger auf Infozeile	*/
	GRECT curr;
	GRECT prev;
	GRECT full;
	GRECT work;
	GRECT overall;			/* Umriss */
	GRECT unic;
	GRECT min;			/* Minimale Groesse */
	WORD	oldheight;		/* alte Hoehe vor Shading	*/
	WORD	hslide;		 	/* horizontale Schieberposition */
	WORD vslide; 			/* vertikale Schieberposition */
	WORD hslsize;			/* horizontale Schiebergroesse */
	WORD vslsize;			/* vertikale Schiebergroesse */
	void *wg;				/* Rechteckliste */
	void *nextwg;			/* naechstes Rechteck der Liste */
	WORD	whdl;
	OBJECT tree[N_OBJS];
	WORD is_sizer;
	WORD is_info;
	WORD is_rgtobjects;
	WORD is_botobjects;
	TEDINFO ted_name;
	TEDINFO ted_info;
} WININFO;

/* Bits von state */

#define OPENED 1
#define COVERED 2
#define ACTIVE 4
#define LOCKED 8
#define ICONIFIED 32
#define SHADED 64

/* Uebergabe-Struktur zum Einklinken */

typedef struct {
	WORD		version;		/* Versionsnummer der Struktur */
	LONG		wsizeof;		/* Groesse der WINDOW-Struktur */
	WORD		whshade;		/* Hoehe eines ge-shade-ten Fensters */
	void		(*wbm_create)( WININFO *w );
	void		(*wbm_skind)( WININFO *w );
	void		(*wbm_ssize)( WININFO *w );
	void		(*wbm_sslid)( WININFO *w, WORD vertical );
	void		(*wbm_sstr)( WININFO *w );
	void		(*wbm_sattr)( WININFO *w, WORD chbits );
	void		(*wbm_calc)( WORD kind, WORD *fg );
	WORD		(*wbm_obfind)( WININFO *w, WORD x, WORD y );
} WINFRAME_HANDLER;

/* Uebergabe-Struktur fuer globale Fenster-Einstellungen */

typedef struct {
	WORD		flags;
	WORD		h_inw;
	void		*finfo_inw;
} WINFRAME_SETTINGS;

/* Bits von flags */

#define NO_BDROP 1

extern WINFRAME_SETTINGS *settings;
extern WORD h_inw;
extern int vdi_handle;
extern OBJECT *adr_window;
