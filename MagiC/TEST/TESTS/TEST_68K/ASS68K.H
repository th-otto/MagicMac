extern int sub_w(int dst, int src, int ccr);
extern int subx_w(int dst, int src, int ccr);
extern int subx_l(long dst, long src, int ccr);

extern long roxr_w(long l, long CCR, int *pCCR);
extern long roxr_l(long l, long CCR, int *pCCR);
extern long roxl_w(long l, long CCR, int *pCCR);
extern long roxl_l(long l, long CCR, int *pCCR);

extern void divs_l(long d0_d1_d2[3]);
extern void muls_l(long d0_d1_d2[3]);