extern WORD gl_wchar;
extern WORD gl_hchar;
extern WORD gl_wbox;
extern WORD gl_hbox;

struct res {
	struct res *next;
	short selected;
	const char *desc;
	short rez;
	short vmode;
};

/* Values returned by VgetMonitor() */
#ifndef MON_MONO
#define MON_MONO		0
#define MON_COLOR		1
#define MON_VGA			2
#define MON_TV			3
#endif
#ifndef VGA
#define VGA 0x10
#endif

#define ST_LOW     (0 + 2)
#define ST_MED     (1 + 2)
#define ST_HIGH    (2 + 2)
#define FALCON_REZ (3 + 2)
#define TT_MED     (4 + 2)
#define TT_HIGH    (6 + 2)
#define TT_LOW     (7 + 2)

extern struct res *st_res_tab[5];
extern struct res *tt_res_tab[5];
extern struct res *vga_res_tab[5];
extern struct res *tv_res_tab[5];
extern struct res st_high[1];
extern struct res tt_high[1];

extern const char *const bpp_tab[5];
#define N_ITEMS CHGRES_BOX_LAST-CHGRES_BOX_FIRST+1
extern WORD const ctrl_objs[5];
extern WORD const objs[N_ITEMS];

struct res *get_restab(WORD vdo, WORD bpp, WORD montype);

WORD simple_popup(OBJECT *tree, WORD obj, const char*const *names, WORD num_names, WORD selected);

WORD save_rez(WORD rez, WORD vmode);
