#include <aes.h>
#include <tos.h>
#include <magx.h>

int main()
{
	appl_init();
	shel_write(SHW_INFRECGN, 1, 0, (char *) 0, (char *) 0);
	while(1)
		evnt_timer(0,0);
	return(0);
}
