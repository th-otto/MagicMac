#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <mint/sysvars.h>

#define MX_KER_GETINFO		(('m'<< 8) | 0)		/* mgx_dos.txt */

typedef struct _appl {
	struct _appl *next;
	WORD ap_id;
} APPL;

typedef struct {
     WORD version;
     void (*fast_clrmem)      ( void *von, void *bis );
     char (*toupper)          ( char c );
     void cdecl (*_sprintf)   ( char *dest, const char *source, LONG *p );
     void	**act_pd;
     APPL **act_appl;
} KERNEL;

static long get_syshdr(void)
{
	return *((long *)0x4f2);
}


int main(void)
{
	WORD ap_id;
	KERNEL *kernel;
	APPL *app;
	SYSHDR *syshdr;
	AESVARS *aesvars;
	
	ap_id = appl_init();
	printf("ap_id: %d %d\n", ap_id, gl_apid);
	kernel = (KERNEL *)Dcntl(MX_KER_GETINFO, NULL, 0);
	printf("kernel: %08lx\n", kernel);
	printf("version: %d\n", kernel->version);
	syshdr = (SYSHDR *)Supexec(get_syshdr);
	if (syshdr && syshdr->os_magic)
	{
		aesvars = (AESVARS *)(syshdr->os_magic);
		if (aesvars && aesvars->magic2 == 0x4D414758L)
		{
			printf("MagiC Version %04x %08lx\n", aesvars->version, aesvars->date);
		}
	}
	app = *(kernel->act_appl);
	printf("act_appl: %08lx %08lx\n", kernel->act_appl, app);
	printf("ap_id: %d\n", app->ap_id);
	printf("proc id: %d\n", (int)Pgetpid());
	appl_exit();
	return 0;
}