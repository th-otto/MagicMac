#include <wdlgwdlg.h>

extern OBJECT *adr_spc_dialog;
extern DIALOG *d_spc;

void spc_dial_init_rsc(void);
void spc_dial_set_icon(int iconnr);
int spc_get_zielobj(int x, int y, int whdl, OBJECT **tree, int *objnr, void (**set_icon)(int iconnr, int objnr), void (**malen)(int objnr));
WORD cdecl hdl_spc(struct HNDL_OBJ_args);
