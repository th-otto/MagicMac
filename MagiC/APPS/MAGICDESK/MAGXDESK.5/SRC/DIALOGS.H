extern long init_xted(OBJECT *ob, char *path, XTED *xted,
					char *txt, char *old, int *is_8_3,
					int vislen);

extern void dialogs_init( void );
extern int  new_program( MENUPROGRAM *mp, char *type, int ispgm );
extern void dial_about(void);
extern int  dial_info(WINDOW *w, int obj, void *is_weiter);
extern void dial_neuord(void);
extern void dial_fontsel(void);
extern void dial_deskfmt( int is_fmt );
extern void dial_search( void );
extern void dial_maske(void);
extern void dial_laufwe(void);
extern void dial_anwndg(void);
extern void dial_assign_icon(void);
extern void dial_einste(void);
extern void dial_chgres( void );
extern void dial_arbsic(void);
extern int  dial_ttppar(char *pgm, char *par);
