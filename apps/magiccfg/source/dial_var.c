#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

#define	NO_VIS_VAR	8
int	lbox_ctrl[5] = { VA_BOX, VA_UP, VA_DOWN, VA_BACK, VA_WHITE };
int	lbox_objs[NO_VIS_VAR] = { VA_0, VA_1, VA_2, VA_3, VA_4, VA_5, VA_6, VA_7 };

LIST_BOX	*env_box;

/*
WORD cdecl set_item(LIST_BOX *box,OBJECT *tree,LBOX_ITEM *item,
				int index, void *user_data, GRECT *rect, int offset )
*/
WORD cdecl set_item(struct SET_ITEM_args args )

{
char *ptext, *str;

	ptext=args.tree[args.obj_index].ob_spec.tedinfo->te_ptext;

	if(args.item)							/* LBOX_ITEM vorhanden? */
	{
		if (args.item->selected)			/* selektiert? */
			args.tree[args.obj_index].ob_state|=OS_SELECTED;
		else
			args.tree[args.obj_index].ob_state&=~OS_SELECTED;

		if(((ENV_VAR *)args.item)->active)		/* Aktiv? */
			args.tree[args.obj_index].ob_state|=OS_CHECKED;
		else
			args.tree[args.obj_index].ob_state&=~OS_CHECKED;


		str=&((ENV_VAR *)args.item)->var;		/* Zeiger auf den String */

		if(args.first==0)
		{
			if(*ptext)
			{
				*ptext++=' ';				/* vorangestelltes Leerzeichen */
				*ptext++=' ';				/* vorangestelltes Leerzeichen */
			}
		}
		else
			args.first-=2;
		
		if(args.first<=strlen(str))
		{
			str+=args.first;

			while(*ptext&&*str)
				*ptext++=*str++;
		}
	}
	else									/* nicht benutzter Eintrag */
	{
		args.tree[args.obj_index].ob_state&=~OS_CHECKED;
		args.tree[args.obj_index].ob_state&=~OS_SELECTED;
	}

	while(*ptext)
		*ptext++=' ';					/* Stringende mit Leerzeichen auffllen */	

	return(args.obj_index);				/* Objektnummer des Startobjekts */
}

void ChooseThisVar(ENV_VAR *item, DIALOG *dial, int draw)
{
GRECT r;
OBJECT *tree;
char *ptr=strchr(&item->var,'=');
	wdlg_get_tree(dial, &tree, &r );
	wdlg_set_edit(dial,0);

	if(ptr)
		*ptr=0;
	strncpy(tree[VA_NAME].ob_spec.tedinfo->te_ptext,&item->var,tree[VA_NAME].ob_spec.tedinfo->te_txtlen);
	if(ptr)
	{
		CopyMaximumChars(&tree[VA_VARIABLE],ptr+1);
		*ptr='=';
	}
	else
		*tree[VA_VARIABLE].ob_spec.tedinfo->te_ptext=0;

	if(item->active)
		tree[VA_ACTIVE].ob_state|=OS_SELECTED;
	else
		tree[VA_ACTIVE].ob_state&=~OS_SELECTED;
	
	if(!draw)
		return;

	wind_update(BEG_UPDATE);
	wdlg_redraw(dial, &r, VA_EDIT, MAX_DEPTH);
	wind_update(END_UPDATE);

	wdlg_set_edit(dial,VA_NAME);
}

/*
void	cdecl	select_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, 
			void *user_data, int obj_index, int last_state )
*/
void	cdecl	select_item( struct SLCT_ITEM_args args )
{
	if(args.item->selected&&(args.item->selected!=args.last_state))
	{
	DIALOG_DATA *dialog;
		dialog=find_dialog_by_obj(args.tree);

		ChooseThisVar((ENV_VAR *)args.item,dialog->dial,1);
	}
}

int CreateListBox(DIALOG *dialog)
{
ENV_VAR *ptr;
	if(mgx_EnvVar==NULL)
	{
		mgx_EnvVar=(ENV_VAR *)Malloc(sizeof(ENV_VAR));
		if(mgx_EnvVar==NULL)
			return(FALSE);
		mgx_EnvVar->var=0;
		mgx_EnvVar->active=TRUE;
		mgx_EnvVar->next=NULL;
	}
	
	ptr=mgx_EnvVar;
	while(ptr)
	{
		ptr->selected=0;
		ptr=ptr->next;
	}
	mgx_EnvVar->selected=TRUE;
	ChooseThisVar(mgx_EnvVar,dialog,0);

	/* vertikale Listbox mit Auto-Scrolling und Real-Time-Slider anlegen */
	env_box=lbox_create(tree_addr[VARIABLES], select_item, set_item, 
							(LBOX_ITEM *)mgx_EnvVar,
							NO_VIS_VAR, 0, lbox_ctrl, lbox_objs, 
							LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT +
							LBOX_REAL + LBOX_SNGL, 
							40, dialog, dialog, 0, 0, 0, 0 );
	if(env_box)
		return(TRUE);
	else
		return(FALSE);
}

WORD cdecl HandleVariables(struct HNDL_OBJ_args args)
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree(args.dialog,&tree,&rect);	/* Adresse des Baums erfragen */

	if(args.obj<0)							/* Ereignis oder Objektnummer? */
	{
		if(args.obj==HNDL_OPEN)
		{
			if(!CreateListBox(args.dialog))
				return(0);
			wdlg_set_edit(args.dialog,0);
			wdlg_set_edit(args.dialog,VA_NAME);
		}
		if(args.obj==HNDL_CLSD)				/* Closer bet„tigt? */
		{
			lbox_delete(env_box);
			return(0);									/* beenden */ 
		}
		if(args.obj==HNDL_MESG)
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		if(args.clicks!=2)
			lbox_do(env_box, args.obj);
		switch(args.obj)
		{
			case VA_0 :
			case VA_1 :
			case VA_2 :
			case VA_3 :
			case VA_4 :
			case VA_5 :
			case VA_6 :
			case VA_7 :
				if(args.clicks==2)
				{
				ENV_VAR *item;
					item=(ENV_VAR *)lbox_get_item(env_box,lbox_get_first(env_box)+args.obj-VA_0);
					if(item->active)
						item->active=FALSE;
					else
						item->active=TRUE;
					lbox_update(env_box,&rect);
					changed=TRUE;
				}
				break;
			case VA_NEW : 
			{
			ENV_VAR *sel_item, *new_item;
				sel_item=(ENV_VAR *)lbox_get_slct_item(env_box);
				new_item=(ENV_VAR *)Mxalloc(sizeof(ENV_VAR)+MPATHMAX,3);
				if(new_item)
				{
					new_item->var=0;
					new_item->selected=1;
					new_item->active=TRUE;
					new_item->next=sel_item->next;

					sel_item->next=new_item;
					sel_item->selected=0;
				}

				lbox_set_asldr(env_box,lbox_get_afirst(env_box)+1,&rect);
				lbox_update(env_box,&rect);

				*tree[VA_VARIABLE].ob_spec.tedinfo->te_ptext=0;
				*tree[VA_NAME].ob_spec.tedinfo->te_ptext=0;
				tree[VA_ACTIVE].ob_state|=OS_SELECTED;
	
				tree[args.obj].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);

				wdlg_redraw(args.dialog,&rect,VA_EDIT,MAX_DEPTH);

				wdlg_set_edit(args.dialog,0);
				wdlg_set_edit(args.dialog,VA_NAME);

				changed=TRUE;
				break;
			}
			case VA_REMOVE :
			{
			int index;
			ENV_VAR *rem_item, *sel_item;
				rem_item=(ENV_VAR *)lbox_get_slct_item(env_box);
				index=lbox_get_idx((LBOX_ITEM *)mgx_EnvVar,(LBOX_ITEM *)rem_item);
				sel_item=(ENV_VAR *)lbox_get_item(env_box,index-1);
				if(sel_item!=rem_item)
				{
					sel_item->next=rem_item->next;
					if(sel_item->next)
						(sel_item->next)->selected=1;
					else
						sel_item->selected=1;
					Mfree(rem_item);
				}
				else
				{
					if(sel_item->next)
					{
						mgx_EnvVar=sel_item->next;
						mgx_EnvVar->selected=1;
						Mfree(rem_item);
						lbox_set_items(env_box,(LBOX_ITEM *)mgx_EnvVar);
					}
					else
						sel_item->var=0;
				}

				lbox_set_asldr(env_box,lbox_get_afirst(env_box),&rect);
				lbox_update(env_box,&rect);

				sel_item=(ENV_VAR *)lbox_get_slct_item(env_box);

				ChooseThisVar(sel_item,args.dialog,1);

				tree[args.obj].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				changed=TRUE;
				break;
			}
			case VA_SET : 
			{
			ENV_VAR	*sel_item;
				sel_item=(ENV_VAR *)lbox_get_slct_item(env_box);
				strcpy(&sel_item->var,tree[VA_NAME].ob_spec.tedinfo->te_ptext);
				strcat(&sel_item->var,"=");
				strcat(&sel_item->var,tree[VA_VARIABLE].ob_spec.tedinfo->te_ptext);
				if(tree[VA_ACTIVE].ob_state & OS_SELECTED)
					sel_item->active=TRUE;
				else
					sel_item->active=FALSE;

				lbox_update(env_box,&rect);

				tree[args.obj].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);

				changed=TRUE;
				break;
			}
			case VA_OK : 
			{
				lbox_delete( env_box );
				
				tree[args.obj].ob_state&=(~OS_SELECTED);
				SendCloseDialog(args.dialog);
			}
		}
	}
	return( 1 );					/* alles in Ordnung - weiter so */
}

