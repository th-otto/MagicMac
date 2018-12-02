#include <aes.h>
#include <tos.h>

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

int main()
{
	char path[128] = "blub.tst";
	int ret;

	appl_init();
	ret = shel_find(path);
	Cconws(path);
	if	(!ret)
		Cconws("-- not found --");
	return(0);
}
