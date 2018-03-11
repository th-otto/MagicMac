#include <tos.h>

void main()
{
	int hdl;

	hdl = (int) Fcreate("$.$", 0);
	Fforce(1, hdl);
	Pexec(0, "c:\\bin\\cmdline.tos", "", (char *) 0);
	Fclose(hdl);
	hdl = (int) Fdup(0);
	Fforce(1, hdl);
	/* Fclose(hdl) */
	
	hdl = (int) Fcreate("$.$", 0);
	Fforce(1, hdl);
	Pexec(0, "c:\\bin\\cmdline.tos", "", (char *) 0);
	Fclose(hdl);
	hdl = (int) Fdup(0);
	Fforce(1, hdl);
}
