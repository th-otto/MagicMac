#include <tos.h>
#include <gemx.h>
#include <bgh.h>
#include "diallib.h"

#if USE_BUBBLEGEM == YES

char *bub_fname=BUBBLEGEM_FILE;

void *Help;

void DoInitBubble(void);
void DoExitBubble(void);
void Bubble(int mx,int my);


void DoInitBubble(void)
{
	Help=BGH_load(bub_fname);
}

void DoExitBubble(void)
{
	BGH_free(Help);
}

void Bubble(int mx,int my)
{
CHAIN_DATA *ptr;
int gruppe,index,typ=-1;

	ptr=find_ptr_by_whandle(wind_find(mx,my));

	if(!ptr)
		return;

	if(ptr->type==WIN_DIALOG)
	{
	OBJECT *tree=((DIALOG_DATA *)ptr)->obj;
	int i;
		if(ptr->status & WIS_ICONIFY)
		{
		GRECT box;
			tree=tree_addr[DIAL_LIBRARY];
			wind_get_grect(ptr->whandle, WF_WORKXYWH,&box);
			tree_addr[DIAL_LIBRARY][0].ob_x=box.g_x;
			tree_addr[DIAL_LIBRARY][0].ob_y=box.g_y;
		}

		index=objc_find(tree,ROOT,MAX_DEPTH,mx,my);
		if(index==-1)
			return;

		for(i=0;i<tree_count;i++)
		{
			if(tree_addr[i]==tree)
				gruppe=i;
		}
		typ=BGH_DIAL;
	}
	else if(ptr->type==WIN_WINDOW)
	{
	int data[4];
		data[0]=mx;
		data[1]=my;
		data[2]=-1;
		((WINDOW_DATA *)ptr)->proc((WINDOW_DATA *)ptr,WIND_BUBBLE,data);
		if(data[2]!=-1)
		{
			gruppe=data[2];
			index=data[3];
			typ=BGH_USER;
		}
	}

	if(typ!=-1)
		BGH_action(Help,mx,my,typ,gruppe,index);
}

#endif