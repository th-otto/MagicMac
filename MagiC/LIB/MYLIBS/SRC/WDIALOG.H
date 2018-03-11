typedef struct _d
	{
	struct 	_d *next;			/* Verkettungszeiger */
	OBJECT 	*tree;			/* Objektbaum */
	int		(*handle_exit)( struct _d *d,
						 int  objnr,
						 int  clicks,
						 void *data );
	void		*user_data;		/* Benutzerinterne Daten */
	int		whdl;			/* Fensterhandle */
	GRECT	out;
	int		act_editob;		/* aktuelles Edit- Objekt */
	int		cursorpos;
	char		ident[32];			/* Kennung */
	} DIALOG;

extern int wdlg_init(
			char  *title, int kind, int x, int y, char *ident,
			int	 (*handle_exit)( DIALOG *d, int objnr, int clicks, void *data ),
			int	 code, void *data );
extern int wdlg_exit(int whdl);
extern void wdlg_redraw(DIALOG *d, GRECT *neu);
extern void subobj_wdraw(DIALOG *d, int obj, int startob, int depth);
extern int wdlg_evnt(int *mwhich, int message[16], int kreturn, int kstate,
			int button, int anzclicks, int mox, int moy);
