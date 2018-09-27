#include <wdlgwdlg.h>

extern void spc_dial_init_rsc( void );
extern void spc_dial_set_icon( int iconnr );
extern int spc_get_zielobj(int x, int y, int whdl, OBJECT **tree,
			int *objnr, void (**set_icon)(int iconnr, int objnr),
			void (**malen)(int objnr));
extern OBJECT *adr_spc_dialog;
extern DIALOG *d_spc;
extern WORD cdecl hdl_spc(struct HNDL_OBJ_args);

