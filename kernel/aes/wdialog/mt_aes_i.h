typedef void AES_FUNCTION(AESPB *pb);		/* Register a0 -> pb */

extern void *aes_dispatcher;
extern void sys_set_getdisp(void **disp_adr, void **disp_err);
extern AES_FUNCTION *sys_set_getfn(WORD fn);
extern WORD sys_set_setfn(WORD fn, AES_FUNCTION *f);
extern void *sys_set_appl_getinfo(AES_FUNCTION *f);
extern void sys_set_colourtab(WORD *colourtab);

