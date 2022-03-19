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

extern WORD gl_wchar;
extern WORD gl_hchar;
extern WORD gl_wbox;
extern WORD gl_hbox;
extern WORD magicpc;

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
#define NUM_NVDIPC 4

extern short et4000_driver_ids[NUM_ET4000];
extern short nvdipc_driver_ids[NUM_NVDIPC];


WORD simple_popup(OBJECT *tree, WORD obj, const char*const *names, WORD num_names, WORD selected);

int change_magx_inf(WORD rez, WORD vmode);
char *load_file(const char *filename, long *size);
void read_assign_sys(const char *path);
