#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include "defs.h"


#define	NO_VIS_LIB	10
int lib_ctrl[5] = { LI_BOX, LI_UP, LI_DOWN, LI_BACK, LI_WHITE };
int lib_objs[NO_VIS_LIB] = { LI_01, LI_02, LI_03, LI_04, LI_05, LI_06, LI_07, LI_08, LI_09, LI_10 };

char *lib_path="C:\\Gemsys\\MagiC\\Xtension\\";

LIST_BOX	*lib_box;

LIB_ITEM *act_item;

LIB_ITEM *AddLibrarie(char *path);


void GetNewLibrary(FILESEL_DATA *ptr, int nfiles)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(file_dialog,&tree,&rect);
	tree[file_object].ob_state&=(~OS_SELECTED);
	if(ptr->button && nfiles)	/*	mit OK beendet ?	*/
	{
	char path[MPATHMAX];
	LIB_ITEM *item;
		strcpy(path,ptr->path);
		strcat(path,ptr->name);

		item=(LIB_ITEM *)lbox_get_slct_item(lib_box);
		if(item)
			item->selected=0;
		item=AddLibrarie(path);
		if(item)
			item->selected=1;
		lbox_set_items(lib_box, (LBOX_ITEM *)mgx_SlbItems);
		lbox_set_asldr(lib_box,lbox_get_afirst(lib_box)+1,&rect);
		lbox_update(lib_box,&rect);

		itoa(item->version,tree[LI_VERSION].ob_spec.tedinfo->te_ptext,10);

		wdlg_redraw(file_dialog, &rect, LI_VERSION, MAX_DEPTH );
		wdlg_set_edit(file_dialog,0);
		wdlg_set_edit(file_dialog,LI_VERSION);

		changed=TRUE;
	}
	else
		wdlg_redraw(file_dialog,&rect,file_object,0);
}

void GetLibrary(FILESEL_DATA *ptr, int nfiles)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(file_dialog,&tree,&rect);
	if(ptr->button && nfiles)	/*	mit OK beendet ?	*/
	{
		if(strnicmp(ptr->path,lib_path,strlen(lib_path))==0)
			strcpy(ptr->path, &ptr->path[strlen(lib_path)]);
		strcpy(&act_item->str,ptr->path);
		strcat(&act_item->str,ptr->name);

		act_item->version=atoi(tree[LI_VERSION].ob_spec.tedinfo->te_ptext);

		lbox_update(lib_box,&rect);

		itoa(act_item->version,tree[LI_VERSION].ob_spec.tedinfo->te_ptext,10);

		changed=TRUE;
	}

	if(file_object)
	{
		tree[file_object].ob_state&=(~OS_SELECTED);
		wdlg_redraw(file_dialog,&rect,file_object,0);
	}
}


LIB_ITEM *AddLibrarie(char *path)
{
LIB_ITEM *ptr=mgx_SlbItems;
long ret;
	ret=(long)Mxalloc(sizeof(LIB_ITEM)+MPATHMAX,3);
	if(ret==0)
		return(NULL);
	
	if(ptr==NULL)
	{
		ptr=(LIB_ITEM *)ret;
		mgx_SlbItems=ptr;
	}
	else
	{
		while(ptr->next!=NULL)
			ptr=ptr->next;
		ptr->next=(LIB_ITEM *)ret;
		ptr=ptr->next;
	}
	ptr->next=NULL;
	ptr->selected=0;
	ptr->version=0;
	if(strnicmp(path,lib_path,strlen(lib_path))==0)
		strcpy(path, &path[strlen(lib_path)]);

	strcpy(&ptr->str,path);
	return(ptr);
}

WORD cdecl lib_set_item( struct SET_ITEM_args args )
{
char *ptext, *str, mystr[MPATHMAX+20];
	ptext = args.tree[args.obj_index].ob_spec.tedinfo->te_ptext;

	if ( args.item )							/* LBOX_ITEM vorhanden? */
	{
		if (args.item->selected )
			args.tree[args.obj_index].ob_state |= OS_SELECTED;
		else
			args.tree[args.obj_index].ob_state &= ~OS_SELECTED;

		sprintf(mystr,"%3d %s",((LIB_ITEM *)args.item)->version, &((LIB_ITEM *)args.item)->str);
		str=mystr;
		
		if ( args.first <= strlen( str ))
		{
			str += args.first;

			while ( *ptext && *str )
				*ptext++ = *str++;
		}
	}
	else									/* nicht benutzter Eintrag */
		args.tree[args.obj_index].ob_state &= ~OS_SELECTED;

	while ( *ptext )
		*ptext++ = ' ';					/* Stringende mit Leerzeichen auffllen */	

	return( args.obj_index );						/* Objektnummer des Startobjekts */
}


void	cdecl	lib_select_item( struct SLCT_ITEM_args args )
{
	if( args.item->selected&&(args.item->selected!=args.last_state))
	{
	DIALOG_DATA *dial = NULL;
	OBJECT *dummy;
	GRECT r;
		dial=find_dialog_by_obj(args.tree);
		wdlg_get_tree(dial->dial,&dummy,&r);

		itoa(((LIB_ITEM *)args.item)->version,args.tree[LI_VERSION].ob_spec.tedinfo->te_ptext,10);

		wind_update(BEG_UPDATE);
		wdlg_redraw(dial->dial,&r,LI_VERSION,MAX_DEPTH);
		wdlg_set_edit(dial->dial,0);
		wdlg_set_edit(dial->dial,LI_VERSION);
		wind_update(END_UPDATE);
	}
}


int CreateLibBox(DIALOG *dialog)
{

	/* vertikale Listbox mit Auto-Scrolling und Real-Time-Slider anlegen */
	lib_box=lbox_create(tree_addr[LIBRARIES],lib_select_item,
							lib_set_item,(LBOX_ITEM *)mgx_SlbItems,
							NO_VIS_LIB,0,lib_ctrl,lib_objs, 
							LBOX_VERT+LBOX_AUTO+LBOX_AUTOSLCT+
							LBOX_REAL+LBOX_SNGL,
							40,dialog,dialog,0,0,0,0);
	if(lib_box)
		return(TRUE);
	else
		return(FALSE);
}

WORD cdecl HandleLibraries( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );	/* Adresse des Baums erfragen */

	if(args.obj<0)								/* Ereignis oder Objektnummer? */
	{
		if(args.obj==HNDL_CLSD)
		{
			lbox_delete(lib_box);
			return(0);									/* beenden */ 
		}
		if (args.obj==HNDL_OPEN)
		{
			if(CreateLibBox(args.dialog))
			{
			LIB_ITEM *sel_item;
				sel_item=(LIB_ITEM *)lbox_get_slct_item(lib_box);
				if(sel_item)
					itoa(sel_item->version,tree[LI_VERSION].ob_spec.tedinfo->te_ptext,10);
				else
					*tree[LI_VERSION].ob_spec.tedinfo->te_ptext=0;
				wdlg_set_edit(args.dialog,0);
				wdlg_set_edit(args.dialog,LI_VERSION);
			}
			else
				return(0);
		}
		if(args.obj==HNDL_MESG)
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		lbox_do(lib_box,args.obj);
		switch(args.obj)
		{
			case LI_01 :
			case LI_02 :
			case LI_03 :
			case LI_04 :
			case LI_05 :
			case LI_06 :
			case LI_07 :
			case LI_08 :
			case LI_09 :
			case LI_10 :
			{
				if(args.clicks==2)
				{
				char path[MPATHMAX];
					act_item=(LIB_ITEM *)lbox_get_item(lib_box,lbox_get_afirst(lib_box)+args.obj-LI_01);
					if(act_item==NULL)
						break;
					if(strchr(&act_item->str,'\\')==NULL)
						strcpy(path, lib_path);
					else
						*path=0;
					strcat(path,&act_item->str);
					file_dialog=args.dialog;
					if(OpenFileselector(GetLibrary,string_addr[FSEL_SHAREDLIB],
							path,std_paths,file_mask,0))
						ModalItem();
				}
				break;
			}
			case LI_NEW : 
			{
				file_dialog=args.dialog;
				file_object=args.obj;
				if(OpenFileselector(GetNewLibrary,string_addr[FSEL_SHAREDLIB],
						lib_path,std_paths,file_mask,0))
					ModalItem();
				break;
			}
			case LI_REMOVE :
			{
			int index;
			LIB_ITEM *rem_item, *sel_item;
				rem_item=(LIB_ITEM *)lbox_get_slct_item(lib_box);
				if(rem_item)
				{
					index=lbox_get_idx((LBOX_ITEM *)mgx_SlbItems,(LBOX_ITEM *)rem_item);
					sel_item=(LIB_ITEM *)lbox_get_item(lib_box,index-1);
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
							mgx_SlbItems=sel_item->next;
							mgx_SlbItems->selected=1;
							Mfree(rem_item);
							lbox_set_items(lib_box,(LBOX_ITEM *)mgx_SlbItems);
						}
						else
						{
							sel_item->str=0;
							sel_item->version=0;
						}
					}
	
					lbox_set_asldr(lib_box,lbox_get_afirst(lib_box),&rect);
					lbox_update(lib_box,&rect);
	
					sel_item=(LIB_ITEM *)lbox_get_slct_item(lib_box);
					itoa(sel_item->version,tree[LI_VERSION].ob_spec.tedinfo->te_ptext,10);
					wdlg_redraw(args.dialog,&rect,LI_VERSION,MAX_DEPTH);
					wdlg_set_edit(args.dialog,0);
					wdlg_set_edit(args.dialog,LI_VERSION);
				}
				tree[args.obj].ob_state&=(~OS_SELECTED);

				wdlg_redraw(args.dialog,&rect,args.obj,0);
				changed=TRUE;
				break;
			}
			case LI_SET : 
			{
			char path[MPATHMAX];
				act_item=(LIB_ITEM *)lbox_get_slct_item(lib_box);
				if(act_item==NULL)
				{
					tree[args.obj].ob_state&=(~OS_SELECTED);
					wdlg_redraw(args.dialog,&rect,args.obj,0);
					break;
				}
				if(strchr(&act_item->str,'\\')==NULL)
					strcpy(path, lib_path);
				else
					*path=0;
				strcat(path,&act_item->str);
				file_dialog=args.dialog;
				file_object=args.obj;
				if(OpenFileselector(GetLibrary,string_addr[FSEL_SHAREDLIB],
						path,std_paths,file_mask,0))
					ModalItem();
				break;
			}
			case LI_OK :
				changed=TRUE;
				tree[args.obj].ob_state&=(~OS_SELECTED);
				lbox_delete( lib_box );
				SendCloseDialog(args.dialog);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}
