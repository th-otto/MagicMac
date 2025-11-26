/**************************************************
*
* ALLGEMEINE INCLUDES UND DEFINITIONEN
*
**************************************************/

#define DEBUG	0

#include <aes.h>
#include <wdlgwdlg.h>
#include "de/magxdesk.h"
#include "country.h"
#include "..\applicat\appldata.h"
#include "av.h"

#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ABS(X) ((X>0) ? X : -X)

#define MIN_FNAMLEN		8

/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;


/* FÅr Kommandozeilen */

#define MAX_PARAMLEN	10240L

/* fÅr D&D: */

/*
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6
*/

#define FAP_UNIPIPE		0x01
#define FAP_NOBLOCK		0x02
#define FAP_PSEUDOTTY	0x04


/* MYDTA.icontyp oder ICON.icontyp */

#define ITYP_DISK		1
#define ITYP_DISK2		2   /* Tradition von KAOSDESK */
#define ITYP_DISK3		3   /* Tradition von KAOSDESK */
#define ITYP_DRUCKR		4
#define ITYP_PAPIER		5
#define ITYP_ORDNER		6
#define ITYP_PROGRA		7
#define ITYP_DATEI		8
#define ITYP_BTCHDA		9
#define ITYP_DEVICE		10
#define ITYP_ALIAS		11
#define ITYP_PARENT		12

extern char *gmemptr;
extern int n_deskicons;

extern long n_apps;			/* TabellenlÑnge */
extern APPLICATION *apps;	/* Tabelle */
extern long n_dfiles;		/* TabellenlÑnge */
extern DATAFILE *dfiles;		/* Tabelle */
extern long n_paths;		/* TabellenlÑnge */
extern PATHNAME *paths;		/* Tabelle */
extern long n_specs;		/* TabellenlÑnge */
extern SPECIALOBJECT *specs;	/* Tabelle */
extern CICONBLK **icons;


/**************************************************
*
* EIGENE FEHLERCODES
*
**************************************************/

#define ENOWND		-100			/* kein Fenster verfÅgbar */


/**************************************************
*
* GLOBALE VARIABLEN
*
**************************************************/

#define SCREEN     0
#define FENSTERTYP_T (NAME+CLOSER+FULLER+MOVER+INFO+SIZER+UPARROW+DNARROW+VSLIDE+HSLIDE+LFARROW+RTARROW+SMALLER)
#define FENSTERTYP_B (NAME+CLOSER+FULLER+MOVER+INFO+SIZER+UPARROW+DNARROW+VSLIDE+SMALLER)

#define ANZDRIVES	32			/* Maximale Anzahl Laufwerke */
#define ANZFENSTER	64			/* Anzahl der Fenster */
#define PLUSICONS	10			/* Anzahl freier Desktop- Icons */
#define MAX_ICONTXT	80
#define TTPLEN 63
#define AUTOUPDATE_MS	2000L	/* fÅr Fenster-Autoupdate */

#define FIRSTMAXMEMBLK	0x40000L	/* fÅr Fenster: Beginne mit 256k */
#define NEXTMEMBLK		0x40000L	/* fÅr Fenster: Steigere 256k */
#define LASTMAXMEMBLK	0x200000L	/* fÅr Fenster: Ende mit 2M */
#define MINFREEBLK	32768L		/* soviel muû noch frei sein */

/* Angemeldete Programme */
/* --------------------- */

#define ANZPROGRAMS	14			/* Anzahl Dateien in "Programme" */
#define  INDEX_CMD	0			/* Kommandointerpreter */
#define  INDEX_SHOW 1			/* Anzeigeprogramm */
#define  INDEX_PRNT	2			/* Ausgabeprogramm */
#define  INDEX_EDIT	3			/* Editor */
#define  INDEX_USER 4

typedef struct
{
	char path[128];
} MENUPROGRAM;

extern char *kachel_1;			/* Kachel 1 Plane (monochrom) */
extern char *kachel_4;			/* Kachel 4 Planes (16 Farben) */
extern char *kachel_8;			/* Kachel 8 Planes (256 Farben) */
extern char *kachel_m;			/* Kachel > 256 Farben */
extern MENUPROGRAM **kachel_path;	/* Zeiger auf aktuelle Kachel */

extern MENUPROGRAM menuprograms[ANZPROGRAMS];
extern char ext_bat[4];				/* Dateityp .BAT */
extern char ext_btp[4];				/* Dateityp .BTP */


/* Icon-Verwaltung */
/* --------------- */

typedef struct
{
	int 		icontyp;			/* Bildtyp I_FLPDSK...	*/
	unsigned char	isdisk;		/* Buchstabe fÅr Disk-Icon oder 0 */
	unsigned char  is_alias;		/* Alias ? */
	char		text[MAX_ICONTXT];	/* Text (Diskname, Pfad) */
	CICONBLK	data;
} ICON;

extern ICON	*icon;
extern int	dirty_applicat_dat;


/* Fensterverwaltung */
/* ----------------- */

typedef struct
{
	int			number;			/* Eingangsreihenfolge */
	unsigned char	flags;			/* Bit 0: "paût zu Muster" */
								/* Bit 1: versch (selected) */
								/* Bit 2: ist Programm */
	unsigned char	icontyp;
	unsigned int   time;
	unsigned int   date;
	unsigned long  filesize;
	unsigned char  attrib;			/* eigentlich redundant */
	unsigned char  is_alias;			/* 1:Alias 2:badAlias */
	unsigned short mode;			/* von XATTR */
	CICONBLK		ciconblk;
	char           filename[0];
} MYDTA;

#define MAX_SELMASK 31

#define WFLAG_ICONIFIED		1
#define WFLAG_ALLICONIFIED	2

/* Modi fÅr w->iconified:
   NORMAL:	Fenster soll auf <g> ikonifiziert werden
   HIDE:		anderes Fenster wurde mit Ctrl ikonifiziert
   ALL:		Fenster wurde mit Ctrl ikonifiziert
*/

#define ICONIFIED_MODE_NORMAL	0
#define ICONIFIED_MODE_HIDE	1
#define ICONIFIED_MODE_ALL	2

typedef struct _window
{
	int		wnr;				/* 0..ANZFENSTER-1 */
	int		handle;			/* Handle oder 0 				*/
	int		flags;			/* Bit 0: Ikonifiziert			*/
	int		kind;
	void		(*key)		(struct _window *w, int kstate, int key);
	void		(*message)	(struct _window *w, int kstate, int message[16]);
	void		(*closed)		(struct _window *w, int kstate);
	void		(*topped)		(struct _window *w);
	void		(*iconified)	(struct _window *w, GRECT *g, int mode);
	void		(*uniconified)	(struct _window *w, GRECT *g, int unhide);
	void		(*fulled)		(struct _window *w);
	void		(*arrowed)	(struct _window *w, int arrow);
	void		(*hslid)		(struct _window *w, int pos);
	void		(*vslid)		(struct _window *w, int pos);
	void		(*sized)		(struct _window *w, GRECT *g);
	void		(*moved)		(struct _window *w, GRECT *g);
	void		(*draw)		(struct _window *w, GRECT *g);
	char		path[128];		/* "", wenn nicht geîffnet 		*/
	int		real_drive;		/* tatsÑchl. Laufwerk oder -1		*/
	WORD		mdate;			/* Modifikationsdatum			*/
	WORD		mtime;			/* Modifikationszeit			*/
	char		dos_mode;			/* Dateien 8+3 (DOS)			*/
	char		maske[13];		/* etwa "*.*" 					*/
	char		sel_maske[MAX_SELMASK+1];	/* FÅr Objektselektion	*/
	char		info[60+MAX_SELMASK];		/* Infozeile 			*/
	char		title[128];		/* Titelzeile 					*/
	GRECT 	out;				/* Fenster- Gesamtmaûe 			*/
	GRECT	in;				/* Fenster- Innenmaûe 			*/
	int		showw;			/* Breite eines Objekts */
	int		showh;			/* Hîhe eines Objekts */
	int		max_hicon;		/* grîûte Iconhîhe */
	int		max_wicnobj;		/* grîûte Iconbreite inkl. Text */
	int		max_fname;		/* LÑnge des lÑngsten Dateinamens	*/
	int		max_is_alias;		/* LÑngster Dateiname ist Alias	*/
	int		xtab_namelen;		/* Breite der Namensspalte bei	*/
							/*  Vektorfonts */
	int		xtab_typelen;		/* Breite der Typspalte bei	*/
							/*  Vektorfonts und 8+3 Modus */
	int		xtab_sizelen;		/* Breite der Grîûenspalte bei	*/
							/*  Vektorfonts */
	int		xtab_datelen;		/* Breite der Datumsspalte bei	*/
							/*  Vektorfonts */
	int		xtab_timelen;		/* Breite der Zeitspalte bei		*/
							/*  Vektorfonts */
	int		xdist;			/* x-Abstand der Objekte			*/
	int		ydist;			/* y-Abstand der Objekte			*/
	int		xoffs;			/* x-Rand des ersten Objekts		*/
	int		yoffs;			/* y-Rand des ersten Objekts		*/
	int		realnum;			/* wahre Anzahl Dateien 			*/
	int		shownum;			/* mit Maske angezeigte Anzahl	*/
	int		too_much;			/* Flag fÅr "zuviele Dateien" 	*/
	int		cols;			/* Objekte/Zeile 				*/
	int		wlins;			/* Anzahl ganz sichtbarer Zeilen 	*/
	int		lins;			/* Anzahl Zeilen 				*/
	int		xscroll;			/* FÅr Textausgabe				*/
	int		max_xscroll;		/*  " */
	int		yscroll;			/* Nr. der obersten Zeile 		*/
	int		maxshift;			/* Maximales <shift> 			*/
	char		*memblk;			/* Speicherblock				*/
	long		memblksize;		/* Grîûe Speicherblocks			*/
	MYDTA	**pmydta;			/* Daten 						*/
	OBJECT	*pobj;			/* Zeiger auf dargestellte Objekte */
} WINDOW;

extern WINDOW	*fenster[ANZFENSTER+1];	/* Zeiger auf Fenster */
extern GRECT	fensterg[ANZFENSTER+1];	/* gespeicherte Positionen */

extern int dirty_win,dirty_pgm;
extern char dirty_drives[ANZDRIVES];	/* 0 = Inhalt unverÑndert */
								/* 1 = Inh.+fr.Sp. geÑndert */
								/* 2 = nur Inh. geÑndert */
extern _DISKINFO    dinfo[ANZDRIVES];

enum { OVERWRITE, BACKUP, CONFIRM };

typedef struct
{
	char		sorttyp;
	char 	showtyp;

	char 	is_1col;
	char 	is_groesse;
	char 	is_datum;
	char 	is_zeit;

	char		cnfm_del;		/* Flag: Lîschen bestÑtigen				*/
	char		cnfm_copy;	/* Flag: Kop./Versch. bestÑtigen			*/
	char		mode_ovwr;	/* Modus (0=öb,1=Backup,2=Best.)			*/
	char		check_free;	/* Freien Speicher auf Ziellaufwerk prÅfen	*/
	char		use_pp;		/* ".."-Eintrag verwenden */
	char		resident;		/* Magxdesk resident */
	char 	show_all;		/* versteckte Dateien zeigen */
	char		dnam_init;	/* Disknamen initialisieren */
	char		copy_resident;	/* Kopierprogramm resident lassen */
	char		copy_use_kobold;	/* Kobold verwenden */
	char		save_on_exit;	/* Einstellungen beim Beenden sichern */
	char		rtbutt_dclick;	/* Rechte Maustaste = Doppelklick */
	char		disk_extinfo;	/* erweiterte Disk-Informationen */
	char		show_8p3;		/* TOS-Dateisystem als 8+3 */
	char		show_prticon;	/* Druckericon anzeigen */
	char		h_icon_dist;	/* horiz. Icon-Abstand */
	char		v_icon_dist;	/* vertik. Icon-Abstand */
	char		desk_col_1;	/* Farbe fÅr Desktop-Hintergr. bei < 16 Farben */
	char		desk_patt_1;	/* Muster fÅr Desktop-Hinterg. bei < 16 Farben */
	char		desk_col_4;	/* Farbe fÅr Desktop-Hintergr. bei >= 16 Farben */
	char		desk_patt_4;	/* Muster fÅr Desktop-Hinterg. bei >= 16 Farben */
	char		desk_raster;	/* Iconraster fÅr Desktop */
	int		fontID;		/* Zeichensatz fÅr Fenster */
	int		fontH;		/* Zeichenhîhe fÅr Fenster */
	int		font_is_prop;	/* Flag fÅr Proportionalfont */
} DEFAULTS;

extern DEFAULTS status;
extern char *desk_col;
extern char *desk_patt;

extern int deflt_topwnr;

/* ALLG.C */

extern void	top_all_my_windows( void );
extern void	allg_init( void );
extern int	top_whdl( void );
extern void	ob_dsel(OBJECT *tree, int which);
extern void	ob_sel(OBJECT *tree, int which);
extern void	ob_sel_dsel(OBJECT *tree, int which, int sel);
extern void 	objc_grect(OBJECT *tree, int objn, GRECT *g);
extern void	objc_visgrect(OBJECT *tree, int objn, GRECT *g);
extern void	subobj_wdraw(DIALOG *d, int obj, int startob, int depth);
extern void	objs_hide(OBJECT *tree, ...);
extern void	objs_unhide(OBJECT *tree, ...);
extern void	objs_editable(OBJECT *tree, ...);
extern void	objs_uneditable(OBJECT *tree, ...);
extern void	objs_disable(OBJECT *tree, ...);
extern int	do_dialog(OBJECT *dialog);
extern int	do_exdialog(OBJECT *dialog,
			 int (*check)(OBJECT *dialog, int exitbutton),
			 int *was_redraw);
extern int 	find_obj(OBJECT *tree, int x, int y);
extern int 	in_grect(int x, int y, GRECT *g);
extern int	selected(OBJECT *tree, int which);
extern void	subobj_draw(OBJECT *tree, int obj, int n, char *s);
extern void	date_to_str(char *s, unsigned int date);
extern void	drv_to_str(char *s, char c);
extern long	err_alert(long e);
extern char	*get_name(char *path);
extern void	get_app_name(char *path, char apname[9]);
extern void	abbrev_path(char *dst, char *src, int len );
extern void	fname_ext(char *s, char *d);
extern void	fname_int(char *s, char *d);
extern int	fname_match(char *fname, char *fmask);
extern void	Mgraf_mouse(int type);
extern char	*print_ul(unsigned long z, char *p);
extern int	suffixtyp(char *s);
extern void	time_to_str(char *s, unsigned int time);
extern char	*err_file;
extern char	*Rgetstring( WORD string_id );
extern WORD	Rform_alert( WORD defbutton, WORD alert_id );
extern WORD	Rxform_alert( WORD defbutton, WORD alert_id,
						char drv, char *path );

/* DCLICK.C */

extern void	opn_newwnd(char *path);
extern void	open_window(char *path, char *mask,
				char *sel_mask, int new);
extern int	obj_typ(WINDOW *w, int obj, char *path, MYDTA **f,
				int *typ, int *config, APPLICATION **a);
extern int	obj_to_path(WINDOW *w, int obj, char *path, MYDTA **f);
extern int	tst_exepath(char *path);
extern void	starte_dienstpgm(char *name, int is_multi, int isargv,
						char *arg1, char *arg2, char *arg3);
extern int	start_path(char *pgmpath, char *tail, int kbsh);
extern int	starten(char *path, char *tail, int config, APPLICATION *a,
				WINDOW *w, int obj, int kbsh);
extern APPLICATION *dfile_to_app(char *filepath);
extern APPLICATION *path_to_app(char *pgmpath);
extern int  dclick(WINDOW *w, int obj, int kbsh);
extern void exit_vt52( void );
extern int  drag_and_drop(int whdl, int kbsh, int mx, int my);

/* DIALOGS.C */

#include "dialogs.h"

/* DLG_INFO.C */

#include "dlg_info.h"

/* MAGXDESK.C */

extern void	set_char_dim( void );
extern void	_ende(int code);
extern void	anfang(void);
extern int	change_res(int dev, int txt);
extern void	close_all_wind(void);
extern void	init_popup(OBJECT *dialog, int objnr,
			 POPINFO *pop, int rscpop, int defobj);
extern void	get_char_dim( void );
extern WINDOW *whdl2window(int whdl);
extern int 	icsel(WINDOW **pw, int *objn);
extern int	drv_to_icn(int drv);
extern int	is_dest(WINDOW *w, int objnr);
extern void	redraw( WINDOW *w, GRECT *neu);
extern void	set_deflt_clip( void );
extern void	shutdown( int dev, int txt );
extern void	tastatur(int code);
extern void 	tree_sel_grect	(OBJECT *tree, GRECT *g);
extern int 	walk_sel(WINDOW *w, int (*tue)(WINDOW *w, int obj, void *par), void *par);
extern OBJECT *adr_hauptmen;
extern OBJECT *adr_icons;
extern OBJECT *adr_einst;
extern OBJECT *adr_ttppar;
extern OBJECT *adr_about;
extern OBJECT *adr_datinf;
extern int	aes_handle,vdi_handle,vdi_device,char_w,char_h;
extern int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
extern GRECT	desk_g,screen_g;
extern USERBLK userblk;
extern char	const pgm_ver[];
extern int	ap_id;
extern int	folder_w;
extern int	spaltenabstand;		/* FÅr Textausgabe */

/* Externals aus KLICK.C */

extern void obj_malen	(WINDOW *w, int index);
extern void dsel_all	( void );
extern void mausknopf	(int anzahl, EVNTDATA *ev);
extern void sel_all		(WINDOW *w);
extern int  make_icon(int typ, CICONBLK *cic, char c, char *icntext,
					char *path, int is_alias, int x, int y);
extern void kill_icon(int objnr);
extern void cpmvdl_icns(WINDOW *w, char *zielpfad, int kbsh);
extern void prt_icns(WINDOW *w, int print);
extern void init_icnobj(OBJECT *o, CICONBLK *icn, int typ, char *text, int is_alias);

/* Extern aus DMENU */

extern void change_objs_menu( int updwin, int updpgm );
extern void do_menu(int title, int entry, int kbsh);
extern int key_2_menu( int key, int kstate, int *t, int *e );
extern void modify_menu( void );
extern void menu_init( void );

/* Externals aus DWINDOWS.C */

extern void	make_g_fit_screen( GRECT *g );
extern void	windows_init( void );
extern WINDOW *top_window( void );
/* extern void	close_immed(WINDOW *w); */
extern void	upd_show	( void );
extern void	upd_is	( void );
extern void	upd_sort	( void );
extern void	upd_col	( void );
extern void 	upd_drives( void );
extern void 	upd_infos ( void );
extern void	upd_mask	( WINDOW *w );
extern void	upd_selmask( WINDOW *w );
extern void	upd_path  ( WINDOW *w, int free_flag );
extern void	dirwindow_autoupdate( void );
extern void	upd_icons( void );
extern void 	dirty_info_selmask( WINDOW *w );
extern void    close_all_wind( void );
extern void    open_all_wind( void );
extern WINDOW 	*create_wnd(int wnr, char *path, char *mask,
					int shift, int flags, LONG *errcode);
extern void	delete_wnd( WINDOW *w );
extern long	opn_wnd(WINDOW *w, int fast);
extern void	upd_wind(WINDOW *w);
extern void	auto_close_windows( void );
extern void	set_dname(int lw, char *dname);
extern void	show_free( WINDOW *mywindow);

/* Externals aus DEFAULTS.C */

extern char	desk_path[128];	/* Pfad, z.B. "c:\gemsys\gemdesk\" */
extern void	load_status( int pass );
extern void	save_status(int is_inf);
extern void	reload_status(int drv);
extern void	re_read_icons(void *data);
extern void	load_app_icons( void );
extern char	inf_name[];
extern APPLICATION * find_application(char *fname);
extern DATAFILE * find_datafile(char *fname);
extern PATHNAME * find_path(char *path, char *nurname);
extern CICONBLK * pgmname_to_iconblk(char *fname);
extern CICONBLK * datname_to_iconblk(char *fname);
extern CICONBLK * foldername_to_iconblk(char *path, char *nurname);
extern CICONBLK * parentname_to_iconblk(char *path, char *nurname);
extern CICONBLK * diskname_to_iconblk(int diskname, char **name);
extern CICONBLK * specialkey_to_iconblk(long key);
extern CICONBLK *std_prt_icon;	/* fÅr Drucker */
extern CICONBLK *std_tra_icon;	/* fÅr Papierkorb */
extern CICONBLK * batchname_to_iconblk(char *fname);
extern CICONBLK * devicename_to_iconblk(char *fname);
extern CICONBLK * alias_to_iconblk(char *fname);
extern void set_desktop( void );

/* Extern aus FILES */

extern long get_real_drive(char *path);
extern long eject_medium(char *path);
extern void set_dirty(long err, char *path, int drv, char val);
extern long walk_path(char *path, long *nbytes, long *hbytes,
			int *folders, int *nfiles, int *hfiles);

/* Extern aus SPEC */

extern int  alt_keycode_2_ascii(int keycode);
extern COOKIE *getcookie(long key);
extern long read_bootsec(int lw, long *ser, int *bps, int *spc,
					int *res,	int *nfats, int *ndirs, int *nsects,
					int *media, int *spf, int *spt, int *nsides,
					int *nhid, int *exec);
extern char *os_ver_s;
extern void set_parent_paths( void );
extern void res_exec( void );
extern void get_syshdr( void );

int drive_from_letter(int drv);
int letter_from_drive(int drv);
