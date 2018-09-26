struct prefs {
	GRECT main_win;
	GRECT progr_win;
	int work_expanded;		/* ausfÅhrlicher Status */
	int dirty;
};

extern struct prefs prefs;

enum { OVERWRITE, BACKUP, CONFIRM, RENAME };
enum { DLG_WAITING, DLG_RUNNING, DLG_FINISHED };

typedef enum { FOLDER, ORDINARYFILE, ALIAS } filetype;
typedef enum { OK, CANCEL, SKIP, WAITING } exist_answer;
typedef struct {
	filetype ftype;
	char	*fname;
	int is_8_3;
	char maxnamelen;
	exist_answer answ;
	} FILEDESCR;

typedef struct {
	int action;
	int argc;
	char **argv;
	char *dstpath;
	int mode;
	} ACTIONPARAMETER;

extern void *d_beg, *d_dat, *d_working;
extern OBJECT *adr_beg;
extern OBJECT *adr_working;
extern OBJECT *adr_dat;

extern int working_is_expanded;
extern int copy_id;
extern int is_3d;
extern int run_status;
extern int action,confirm,tst_free,copy_mode,abbruch;
extern int  nargs;
extern char **xargv;
extern char *dst_path;
extern int exit_immed;
extern void down_cnt( int ord, char *aktion, char *path, long bytes );
extern void close_beg_dialog( void );
extern void close_dat_dialog( void );
extern void ackn_cancel( void );
extern void subobj_wdraw(void *d, int obj, int startob, int depth);
extern LONG cdecl action_thread( void *par );
extern void terminate_dialog( void **dialog, GRECT *pref_g );
