#include "wglobals.h"
#include <wdlgedit.h>

#define WFLAG_ICONIFIED	1

typedef struct _wind_scroll_info
{
	long		n;			/* Anzahl Zeilen/Spalten */
	long		shift;		/* Nr der obersten Zeile, linksten Spalte */
	int		nvis;		/* Anzahl sichtbarer Zeilen/Spalten */
	long		maxshift;		/* AbhÑngig von n und nvis */
	void		(*set_shift)	(struct _window *w, long shift,
							int is_horiz);
	int		pixelsize;	/* Pixel pro Objekt */
	void		(*arrange)	(struct _window *w, int is_horiz);
} WINDSCROLLINFO;

typedef struct _window
{
	int		handle;			/* Handle oder 0 				*/
	int		flags;			/* Bit 0: Ikonifiziert			*/
	void		(*key)		(struct _window *w, int kstate, int key);
	void		(*button)		(struct _window *w, int nclicks, EVNTDATA *ev );
	void		(*message)	(struct _window *w, int kstate, int message[16]);
	void		(*open)		(struct _window *w);
	void		(*close)		(struct _window *w, int kstate);
	void		(*iconified)	(struct _window *w, GRECT *g);
	void		(*uniconified)	(struct _window *w, GRECT *g, int unhide);
	void		(*alliconified)(struct _window *w, GRECT *g, int hide);
	void		(*fulled)		(struct _window *w);
	void		(*sized)		(struct _window *w, GRECT *g);
	void		(*moved)		(struct _window *w, GRECT *g);
	int		(*arrange)	(struct _window *w);
	char		title[128];		/* Titelzeile 					*/
	char		info[60];			/* Infozeile 					*/
	GRECT 	out;				/* Fenster- Gesamtmaûe 			*/
	GRECT	in;				/* Fenster- Innenmaûe 			*/
	/* hier Benutzerdaten */
	XEDITINFO	*xedit;
	OBJECT	tree;			/* nur ein OBJECT */
	int		id_code;			/* eindeutige Nummer */
	int		selected;			/* Fenster selektiert ? */
	int		position_dirty;	/* muû noch gespeichert werden */
	char		*buf;			/* Puffer */
	long		bufsize;			/* Puffergrîûe */
	int		tabwidth;
	int		fontH;
	int		fontID;
	int		fontprop;			/* proportionaler Zeichensatz */
	int		charW;
	int		charH;
	int		bcolour;			/* Hintergrundfarbe */
	int		tcolour;			/* Textfarbe */
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


/* FÅr Fenster */
extern int	top_whdl( void );
extern WINDOW *windows[NWINDOWS];
extern WINDOW **new_window( void );
extern WINDOW **find_slot_window( WINDOW *myw );
extern WINDOW *whdl2window(int whdl);
extern void window_calc_slider(WINDOW *w, int is_horiz);
extern void init_window( WINDOW *w);
extern int update_window(WINDOW *w);
