#ifndef WORD
#ifdef __GNUC__
#define WORD short
#endif
#endif
#ifndef _CDECL
#ifdef __GNUC__
#define _CDECL
#endif
#endif

#ifndef FALSE
#  define FALSE 0
#  define TRUE 1
#endif

#ifndef OS_SELECTED
#define OS_SELECTED SELECTED
#define OS_DISABLED DISABLED
#define OS_SHADOWED SHADOWED
#define OS_NORMAL NORMAL
#define OS_CHECKED CHECKED
#define OF_SELECTABLE SELECTABLE
#define OF_DEFAULT DEFAULT
#define OF_HIDETREE HIDETREE
#define OF_FL3DBAK FL3DBAK
#define OF_LASTOB LASTOB
#define OF_NONE   NONE
#endif

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
#ifndef PAL
#define PAL 0x20
#endif
#ifndef NUMCOLS
#define NUMCOLS 7
#endif



extern WORD gl_wchar;
extern WORD gl_hchar;
extern WORD gl_wbox;
extern WORD gl_hbox;

struct resbase {
	struct res *next;
	short selected;
	/* ^^^ above must be same as in LBOX_ITEM */
	char *desc;
	short rez;
	short vmode;
	short flags;
#define FLAG_INFO     0x0001
#define FLAG_DEFMODE  0x0002
	short virt_hres;
	short virt_vres;
	short hres;
	short vres;
};

struct res {
	struct resbase base;
	short planes;
	short freq;
	long mode_offset;
	char descbuf[80];
};

#define MAX_DEPTHS 8
#define NUM_ET4000 6

extern struct res *possible_resolutions[MAX_DEPTHS];
extern struct res *vgainf_modes[NUM_ET4000];
extern short et4000_driver_ids[NUM_ET4000];


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

#undef ST_LOW
#undef ST_MED
#undef ST_HIGH
#undef FALCON_REZ
#undef TT_MED
#undef TT_HIGH
#undef TT_LOW
#define ST_LOW     (0 + 2)
#define ST_MED     (1 + 2)
#define ST_HIGH    (2 + 2)
#define FALCON_REZ (3 + 2)
#define TT_MED     (4 + 2)
#define TT_HIGH    (6 + 2)
#define TT_LOW     (7 + 2)

WORD simple_popup(OBJECT *tree, WORD obj, const char *const *names, WORD num_names, WORD selected);

extern struct res *st_mono_table[MAX_DEPTHS];
extern struct res *st_color_table[MAX_DEPTHS];
extern struct res *tt_color_table[MAX_DEPTHS];
extern struct res *tt_mono_table[MAX_DEPTHS];
extern struct res *vga_res_table[MAX_DEPTHS];
extern struct res *tv_res_table[MAX_DEPTHS];
extern struct res *falc_mono_table[MAX_DEPTHS];

#define N_ITEMS CHGRES_BOX_LAST-CHGRES_BOX_FIRST+1
extern WORD const ctrl_objs[5];
extern WORD const objs[N_ITEMS];
extern short const valid_planes[MAX_DEPTHS];
extern short const et4000_planes[NUM_ET4000];
extern const char *const et4000_driver_names[NUM_ET4000];

int change_magx_inf(WORD rez, WORD vmode);
struct res *sort_restab(struct res *res);
void read_assign_sys(const char *path);
void load_nvdivga_inf(void);
void *load_file(const char *filename, long *size);
