#include <wdlgwdlg.h>

typedef struct
{
	int		tmpdrv;		/* 0..25 */
	int		sides;
	int		tracks;
	int		sectors;
	int		interlv;
	int		trkincr;
	int		sidincr;
	int		clustsize;
	GRECT	format_win;
} FMT_DEFAULTS;

extern FMT_DEFAULTS prefs;

typedef enum {action_format, action_copydisk} action;

struct fmt_parameter {
	action	action;
	WORD		apid;		/* ap_id des Haupt-Thread */
	WORD		whdl;		/* Fensterhandle fÅr RÅckmeldung */
	char		diskname[66];	/* Diskname */

	WORD		device;		/* zu formatierendes GerÑt */
	WORD		do_logical;	/* nur logisch formatieren */

	WORD		src_dev;
	WORD		dst_dev;		/* fÅr Diskcopy */
	WORD		do_format;	/* Diskcopy mit Formatieren */
};

extern void drv_to_str(char *s, char c);
extern long err_alert(long e);
extern WORD global[];
extern int open_format_options( void );
extern int start_format( void *param );
extern void MYsubobj_wdraw(DIALOG *d, int obj, int n, char *s);
extern int send_message(int message[8]);
extern int send_message_break( int whdl );

extern DIALOG *d_cpydsk;
extern DIALOG *d_format;
extern DIALOG *d_fmtopt;
extern int fmt_id;
extern OBJECT *adr_iconified;
extern int gl_hhchar;

extern LONG cdecl format_thread( struct fmt_parameter *par );

extern void write_inf( void );

extern void	fmt_dial_init_rsc( int src_dev, int init, int only );
extern WORD	cdecl hdl_format( struct HNDL_OBJ_args );
extern void	cpy_dial_init_rsc( int src_dev, int dst_dev );
extern WORD	cdecl hdl_cpydsk( struct HNDL_OBJ_args );
extern WORD	cdecl hdl_fmtopt( struct HNDL_OBJ_args );

int drive_from_letter(int drv);
int letter_from_drive(int drv);
