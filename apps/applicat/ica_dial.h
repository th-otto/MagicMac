#include <wdlgwdlg.h>

extern DIALOG *d_ica;
extern OBJECT *adr_ica_dialog;
extern char *def_txt;							/* ->hdl_typ */

void ica_dial_init_rsc(void);
void ica_dial_set_icon(int iconnr);
int ica_get_zielobj(int x, int y, int whdl, OBJECT **tree, int *objnr, void (**set_icon)(int iconnr, int objnr), void (**malen)(int objnr));
WORD cdecl hdl_ica(struct HNDL_OBJ_args);
int insert_pgm(struct pgm_file *pgm);
int insert_dat(struct pgm_file *pgm, struct dat_file *dat);
int change_dat(struct pgm_file *pgm, struct dat_file *dat, char *newname);
