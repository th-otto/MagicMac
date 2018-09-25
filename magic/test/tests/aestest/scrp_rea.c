#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <mgx_dos.h>
#include <mt_aes.h>
#include <ctype.h>

int main()
{
	char scrap_path[128];


	appl_init();

	scrp_read(scrap_path);
	Cconws(scrap_path);
	appl_exit();
	return(0);
}
