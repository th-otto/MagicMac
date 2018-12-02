#include <aes.h>
#include <tos.h>

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

void main(void)
{
	appl_init();
	shel_write(SHW_INFRECGN, 1, 0, (char *) 0, (char *) 0);
	for	(;;)
		;
}
