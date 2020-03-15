#include <tos.h>
#include <gemx.h>
#include <string.h>
#include <DRAGDROP.H>
#include "diallib.h"
#include SPEC_DEFINITION_FILE

#if USE_DRAGDROP == YES

void DragDrop(WORD msg[8]);


void DragDrop(WORD msg[8])
/*
	Erledigt das ganze Drag&Drop-Geschehen
*/
{
unsigned long format[MAX_DDFORMAT], sformat;
char *pipe=DD_FNAME, name[DD_NAMEMAX],
		*data=NULL;
long size,ret;
__mint_sighandler_t old_sig;
int pipe_handle,i;
CHAIN_DATA *chain_ptr;
DIALOG_DATA *dialog=NULL;
WINDOW_DATA *window=NULL;
OBJECT *tree;
GRECT rect;
int obj;

	*(int *)&pipe[17]=msg[7];
	pipe_handle=ddopen(pipe,format,&old_sig);

	chain_ptr=find_ptr_by_whandle(msg[3]);
	if(!chain_ptr)
	{
		ddreply(pipe_handle,DD_NAK);
		ddclose(pipe_handle,old_sig);
		return;
	};

	if((modal_items>=0) && (modal_stack[modal_items]!=chain_ptr->whandle))
	{
		ddreply(pipe_handle,DD_NAK);
		ddclose(pipe_handle,old_sig);
		return;
	}

	switch(chain_ptr->type)
	{
		case WIN_DIALOG:
			dialog=(DIALOG_DATA *)chain_ptr;
			break;
		case WIN_WINDOW:
			window=(WINDOW_DATA *)chain_ptr;
			break;
	}

	if(dialog)
	{
		wdlg_get_tree(dialog->dial,&tree,&rect);
		obj=objc_find(tree,ROOT,MAX_DEPTH,msg[4],msg[5]);
		if(obj<0)
		{
			ddreply(pipe_handle,DD_NAK);
			ddclose(pipe_handle,old_sig);
			return;
		};
		DD_DialogGetFormat(tree,obj,format);
	}
	else if(window)
	{
		if(!window->proc(window,WIND_DRAGDROPFORMAT,format))
		{
			ddreply(pipe_handle,DD_NAK);
			ddclose(pipe_handle,old_sig);
			return;
		};
	}
	else
	{
		ddreply(pipe_handle,DD_NAK);
		ddclose(pipe_handle,old_sig);
		return;
	};

	for(i=0;i<MAX_DDFORMAT;i++)		/*	Alle m”glichen Formate probieren	*/
	{
		ddrtry(pipe_handle,name,&sformat,&size);

		if(sformat!=format[i])
			ddreply(pipe_handle,DD_EXT);
		else
		{
			ret=(long)Mxalloc(size,3);
			if(ret!=0)
			{
				data=(char *)ret;
				ddreply(pipe_handle,DD_OK);
				Fread(pipe_handle,size,data);
			}
			else
				ddreply(pipe_handle,DD_NAK);
			break;
		}
	}
	ddclose(pipe_handle,old_sig);

	if(data!=NULL)
	{
		if(dialog)
			DD_Object(dialog->dial,&rect,tree,obj,data,format[i]);
		else if(window)
			window->proc(window,WIND_DRAGDROP,data);

		Mfree(data);
	}
	else
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
}
#endif