#ifndef CALL_MAGIC_KERNEL
#define CALL_MAGIC_KERNEL 0
#endif


extern MX_KERNEL *p_kernel;
extern MX_DFSKERNEL *p_dfskernel;


#if CALL_MAGIC_KERNEL
extern MX_KERNEL kernel;
#define KERNEL kernel
extern MX_DFSKERNEL dosxfs_kernel;
#define DFSKERNEL dosxfs_kernel
#else
#define KERNEL (*p_kernel)
#define DFSKERNEL (*p_dfskernel)
#endif

/*
 * wrappers from mxkernel.s
 */
void __CDECL kernel_fast_clrmem(void *from, void *to);
/*
 * Note: argument declared as unsigned short,
 * because Pure-C does not promote chars to int
 * in functions declared as cdecl
 */
unsigned short __CDECL kernel_toupper(unsigned short c);
void __CDECL kernel__sprintf(char *dst, const char *src, LONG *data);
void cdecl kernel_appl_yield(void);
void cdecl kernel_appl_suspend(void);
void cdecl kernel_appl_begcritic(void);
void cdecl kernel_appl_endcritic(void);
long cdecl kernel_evnt_IO(LONG ticks_50hz, MAGX_UNSEL *unsel);
void cdecl kernel_evnt_mIO(LONG ticks_50hz, MAGX_UNSEL *unsel, WORD cnt);
void cdecl kernel_evnt_emIO(APPL *app);
void cdecl kernel_appl_IOcomplete(APPL *app);
long cdecl kernel_evnt_sem(WORD mode, void *sem, LONG timeout);
void __CDECL kernel_Pfree(PD *pd);
void *__CDECL kernel_int_malloc(void);
void __CDECL kernel_int_mfree(void *block);
void __CDECL kernel_resv_intmem(void *mem, LONG bytes);
LONG __CDECL kernel_diskchange(WORD drv);
LONG __CDECL kernel_DMD_rdevinit(MX_DMD *dmd);
LONG __CDECL kernel_proc_info(WORD code, PD *pd);
LONG __CDECL kernel_mxalloc(LONG amount, WORD mode, PD *pd);
LONG __CDECL kernel_mfree(void *mem);
LONG __CDECL kernel_mshrink(void *mem, LONG newlen);

void __CDECL kernel_conv_8_3(const char *from, char *to);
void __CDECL kernel_rcnv_8_3(const char *from, char *to);
WORD __CDECL kernel_match_8_3(const char *patt, const char *fname);


#if CALL_MAGIC_KERNEL

#define Cconws(s) MX_Cconws(s)
#define Dcntl(cmd, name, arg) MX_Dcntl(cmd, name, arg)

#endif

#define Pgetpid() (unsigned short)kernel_proc_info(2, *(KERNEL.act_pd))
