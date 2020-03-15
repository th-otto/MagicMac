#include <tos.h>
#include <gemx.h>
#include <mint\sysvars.h>
#include "DIALLIB.H"
#include "defs.h"


long GetBootDrive(void)
{
	*tmp_path=(char)*_bootdev+'A';
	*std_paths=*tmp_path;
	return(0);
}


int main(int argc, char *argv[])
{
	if(DoAesInit())
		return(0);

	if(DoInitSystem()||CheckSystem()||CreateFNTS())
	{
		DoExitSystem();
		return(0);
	}
/*
	Supexec(GetBootDrive);
*/

	*tmp_path=(char)'A';
	*std_paths=*tmp_path;



#if USE_MENU==YES
	menu_bar(menu_tree,MENU_INSTALL);
#endif

	graf_mouse(ARROW,NULL);

#if DEBUG==ON
	strcpy(tmp_path,"MAGX.INF");
	Open(0);
#else
	if(argc<2)
	{
	int msg[8]={MN_SELECTED,0,0,ME_FILE,ME_OPEN};
		msg[1]=ap_id;
		appl_write(ap_id,16,msg);
	}
	else
	{
		strcpy(tmp_path,argv[1]);
		Open(0);
	}
#endif

	while(!doneFlag)
	{
		DoEvent();
	}
	
#if USE_ITEMS==YES
	RemoveItems();
#endif

#if USE_MENU==YES
	menu_bar(menu_tree,MENU_REMOVE);
#endif

	DoExitSystem();
	return(0);
}
