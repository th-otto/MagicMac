#include <wdlgwdlg.h>

#define MAX_NAMELEN 34
#define MAX_PATHLEN 128
#define MAX_PGMN 400
#define MAX_DATN 400
#define MAX_PTHN 400
#define MAX_SPCN 12
#define MAX_LINN 800
#define MAX_RSCN 30
#define MAX_ICNN 700
#define MAXWINDEFPOS 10


typedef struct {
	char name[32];				/* SchlÅssel (Fenstername) */
	GRECT g;					/* Position */
} WINDEFPOS;

struct dialog_userdata {
	char *ident;
	int mode;					/* merken, ob Aktion bei HNDL_OPEN */
};

struct iconfile {
	char	fname[MAX_NAMELEN];		/* Dateiname */
	OBJECT *adr_icons;			/* Baum mit Icons */
	int	nicons;				/* Anzahl Icons */
	int	firsticon;			/* Index in der Icontabelle */
};

struct dat_file {
	int	sel;					/* selektiert */
/*	int	sel_icon;		*/		/* Icon selektiert */
	char	name[MAX_NAMELEN];		/* Dateityp, "" = unbenutzt */
	char rscname[MAX_NAMELEN];	/* Name der RSC-Datei */
	int  rscindex;				/* Nummer des Icons in rsc */
	int	iconnr;				/* interne Iconnummer */
	int	pgm;					/* zugehîrige Applikation */
	int  next;				/* fÅr Verkettung, bis -1 */
};

struct pgm_file {
	int	sel;					/* selektiert */
/*	int	sel_icon;		*/		/* Icon selektiert */
	char	name[MAX_NAMELEN];		/* Name ohne Ext/ "" = unbenutzt */
	char rscname[MAX_NAMELEN];	/* Name der RSC-Datei */
	int  rscindex;				/* Nummer des Icons in rsc */
	int	iconnr;				/* interne Iconnummer */
	char path[MAX_PATHLEN];		/* Voller Pfad */
	int	config;				/* Konfigurationsbits */
	long memlimit;				/* Speicherlimit */
	int	ntypes;				/* Anzahl angemeldeter Dateien */
	int	types;				/* verkettete Liste */
};

struct pth_file {
	struct pth_file *next;		/* Verkettung fÅr scrollbox */
	WORD	selected;					/* selektiert */
/*	int	sel_icon;		*/		/* Icon selektiert */
	char path[MAX_PATHLEN];		/* Voller oder rel. Pfad */
	char rscname[MAX_NAMELEN];	/* Name der RSC-Datei */
	int  rscindex;				/* Nummer des Icons in rsc */
	int	iconnr;				/* interne Iconnummer */
};

struct spc_file {
	struct spc_file *next;		/* Verkettung fÅr scrollbox */
	_WORD	selected;					/* selektiert */
/*	int	sel_icon;		*/		/* Icon selektiert */
	long	key;					/* SchlÅssel fÅr DAT-Datei */
	char name[MAX_NAMELEN];		/* Name in der Dialogbox */
	char rscname[MAX_NAMELEN];	/* Name der RSC-Datei */
	int  rscindex;				/* Nummer des Icons in rsc */
	int	iconnr;				/* interne Iconnummer */
};

struct icon {
	int	rscfile;				/* fÅr versch. Dateien */
	int	objnr;				/* Objektnummer */
/*	int	sel_pgm;	*/			/* als Programm-Icon selektiert */
/*	int	sel_dat;	*/			/* als Datei-Icon selektiert */
};

struct zeile {
	struct zeile *next;			/* Verkettung fÅr scrollbox */
	WORD	selected;			/* selektiert */
	_WORD	pgmnr;				/* Nummer des Programmnamens */
	int	reldatnr;				/* angemeldete Datei 0..ntypes-1 */
							/*  nix angemeldet: -1 */
	int	datnr;				/* absolute Nummer der Datei */
							/*  nix angemeldet: -1 */
};

extern int is_multiwindow;		/* alle Fenster sind offen */

extern int n_windefpos;
extern WINDEFPOS windefpos[MAXWINDEFPOS];
extern WINDEFPOS *def_wind_pos(char *s);
#ifdef NWINDOWS
extern WINDOW *mywindow;
#endif
extern int get_deficonnr(long key);
extern void subobj_wdraw(void *d, int obj, int startob, int depth);
extern void fname_ext(char *s, char *d);
extern int extract_apname(char *path, char *name);
extern DIALOG *xy_wdlg_init(
			HNDL_OBJ hndl_obj,
			OBJECT *tree,
			char *ident,
			int code,
			void *data,
			int title_code
			);
extern void save_dialog_xy( DIALOG *d );
extern long err_alert(long e);

extern int  rsrc_gtree(int gindex, OBJECT **tree );
extern void load_icons( void );
extern long get_inf( void );
extern long put_inf( void );
extern int spcn;
extern int pthn;
extern int datn;
extern int pgmn;
extern int icnn;
extern int linn;
extern int rscn;
extern struct pgm_file	pgmx[MAX_PGMN];
extern struct dat_file	datx[MAX_DATN];
extern struct pth_file	pthx[MAX_PTHN];
extern struct spc_file	spcx[MAX_SPCN];
extern struct icon		icnx[MAX_ICNN];
extern struct zeile		linx[MAX_LINN];
extern struct iconfile	rscx[MAX_RSCN];

extern int is_3d;
