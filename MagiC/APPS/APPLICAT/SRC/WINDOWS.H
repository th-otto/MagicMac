#define NWINDOWS	1
#define WFLAG_ICONIFIED	1

typedef struct _window
{
	int		handle;			/* Handle oder 0 				*/
	int		flags;			/* Bit 0: Ikonifiziert			*/
	void		(*key)		(struct _window *w, int kstate, int key);
	void		(*button)		(struct _window *w, int kstate, int x, int y,
						int button, int nclicks);
	void		(*message)	(struct _window *w, int kstate, int message[16]);
	void		(*open)		(struct _window *w);
	void		(*close)		(struct _window *w, int kstate);
	void		(*iconified)	(struct _window *w, GRECT *g);
	void		(*uniconified)	(struct _window *w, GRECT *g, int unhide);
	void		(*alliconified)(struct _window *w, GRECT *g, int hide);
	void		(*fulled)		(struct _window *w);
	void		(*arrowed)	(struct _window *w, int arrow);
	void		(*hslid)		(struct _window *w, int pos);
	void		(*set_hshift)	(struct _window *w, int abs_shift);
	void		(*vslid)		(struct _window *w, int pos);
	void		(*set_vshift)	(struct _window *w, int abs_shift);
	void		(*sized)		(struct _window *w, GRECT *g);
	void		(*moved)		(struct _window *w, GRECT *g);
	void		(*draw)		(struct _window *w, GRECT *g);
	char		title[128];		/* Titelzeile 					*/
	char		info[60];			/* Infozeile 					*/
	GRECT 	out;				/* Fenster- Gesamtmaûe 			*/
	GRECT	in;				/* Fenster- Innenmaûe 			*/
	int		is_1col;			/* immer einspaltig				*/
	int		showw;			/* Breite eines Objekts			*/
	int		showh;			/* Hîhe eines Objekts			*/
	int		max_hicon;		/* grîûtes Icon-Objekt			*/
	int		xdist;			/* x-Abstand der Objekte			*/
	int		ydist;			/* y-Abstand der Objekte			*/
	int		xoffs;			/* x-Rand des ersten Objekts		*/
	int		yoffs;			/* y-Rand des ersten Objekts		*/
	int		shownum;			/* Anzahl	Objekte				*/
	int		cols;			/* Objekte/Zeile 				*/

	int		wlins;			/* Anzahl ganz sichtbarer Zeilen 	*/
	int		lins;			/* Anzahl Zeilen 				*/
	int		vshift;			/* Nr. der obersten Zeile 		*/
	int		max_vshift;		/* Maximales <vshift> 			*/

	int		step_hshift;		/* Schrittweite fÅr hor. Scrolling */
	int		allsteps_hshift;	/* Gesamtanzahl Schritte			*/
	int		vissteps_hshift;	/* Anzahl ganz sichtbarer Schritte	*/
	int		hshift;			/* akt. Anzahl Scrollschritte		*/
	int		max_hshift;		/* max. Anzahl Scrollschritte		*/

	OBJECT	*tree;			/* Zeiger auf dargestellte Objekte */
	long		usertype;
	void		*userdata;
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
extern int find_obj(OBJECT *tree, int x, int y);
extern void obj_malen(int whdl, OBJECT *tree, int index);
extern void init_window( WINDOW *w);
extern void window_calc_hslider(WINDOW *w);
extern void window_calc_vslider(WINDOW *w);
extern void calc_collin(WINDOW *w);
extern void calc_in(WINDOW *w);
extern int update_window(WINDOW *w);
extern void hshift(WINDOW *w, int newpos);
