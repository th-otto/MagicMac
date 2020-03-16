#include <tos.h>
#include <gemx.h>
#include <av.h>
#include "diallib.h"

#if USE_STGUIDE == YES

char *help_file=STGUIDE_FILE;

void STGuideHelp(void);

void STGuideHelp(void)
{
char *help_article;

	help_article=GetTopic();
	if(help_article)
	{
	int stguide_id, msg[8]={VA_START,0,0,0,0,0,0,0};
		stguide_id=appl_find("ST-GUIDE");
		if(stguide_id<0)
		{
		char command[DL_PATHMAX],*path;
			strcpy(command,help_file);
			strcat(command,help_article);
		
			/*	ST-Guide inaktiv: Suche im Environment nach dem Startpfad	*/
			shel_envrn(&path,"STGUIDE=");
			if(path)
				stguide_id=shel_write(SHW_EXEC,1,SHW_PARALLEL,path,command);

			if(stguide_id<0)
			{
				/*	ST-Guide immernoch nicht gefunden :-(	*/
				form_alert(1,tree_addr[DIAL_LIBRARY][DI_HELP_ERROR].ob_spec.free_string);
				return;
			}
		}
		else
		{
		char *command;
			/*	ST-Guide aktiv: Hypertext und Seite bertragen	*/
			command=(char *)Mxalloc(strlen(help_file)+strlen(help_article)+1,MX_PREFTTRAM|MX_MPROT|MX_READABLE);
			if(!command)
			{
				form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
				return;
			}
		
			strcpy(command,help_file);
			strcat(command,help_article);
		
			msg[1]=ap_id;
			*(char **)&msg[3]=command;
			appl_write(stguide_id, 16, msg);
		}
	}
}

#endif