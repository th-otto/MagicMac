extern void beg_dial_init_rsc( void );
extern void set_dialog_title( int action );
extern long beg_dial_prepare( int argc, char *argv[],
					char *dstpath );
extern WORD cdecl hdl_beg( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
extern WORD cdecl hdl_work( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
extern void beg_dial_action( int argc, char *argv[],
					char *dstpath, int mode );
