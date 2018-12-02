#include <aes.h>
#include <tos.h>

void main(void)
{
	appl_init();
	shel_write(SHW_INFRECGN, 1, 0, (char *) 0, (char *) 0);
	while(1)
		evnt_timer(0);
}
