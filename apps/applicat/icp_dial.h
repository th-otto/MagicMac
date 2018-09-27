#include <wdlgwdlg.h>

extern void icp_dial_init_rsc( void );
extern void icp_dial_set_icon( int iconnr );
extern int icp_get_zielobj(int x, int y, int whdl, OBJECT **tree,
			int *objnr, void (**set_icon)(int iconnr, int objnr),
			void (**malen)(int objnr));
extern DIALOG *d_icp;
extern OBJECT *adr_icp_dialog;
extern WORD cdecl hdl_icp(struct HNDL_OBJ_args);
extern int insert_pth(struct pth_file *new, struct pth_file *old);
