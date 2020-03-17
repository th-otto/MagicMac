#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include "defs.h"


WORD cdecl HandleBoot( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_CLSD )				/* Closer bet„tigt? */
			return(0);
		if ( args.obj == HNDL_OPEN )
		{
			sprintf(tree[BO_COOKIES].ob_spec.tedinfo->te_ptext,"%ld",mgx_cookies);
			CopyMaximumChars(&tree[BO_LOG],mgx_bootlog);
			CopyMaximumChars(&tree[BO_IMAGE],mgx_image);
			CopyMaximumChars(&tree[BO_TILES],mgx_tiles);

			wdlg_set_edit(args.dialog,0);
			wdlg_set_edit(args.dialog,BO_LOG);
		}
		if (args.obj == HNDL_EDCH )
		{
			if(args.events && args.events->mclicks == 2 && args.events->mbutton == 1)
			{
			char path[MPATHMAX];
				args.obj=*(int *)args.data;
				file_dialog=args.dialog;
				file_object=args.obj;
				strcpy(path,tree_addr[BOOT][args.obj].ob_spec.tedinfo->te_ptext);
				if(!*path)
					strcpy(path,std_paths);
				switch(args.obj)
				{
					case BO_TILES :
						if(OpenFileselector(GetFile,string_addr[FSEL_GETPATTERN],
								path,std_paths,file_mask,0))
							ModalItem();
						break;
					case BO_IMAGE :
						if(OpenFileselector(GetFile,string_addr[FSEL_GETPIC],
								path,std_paths,file_mask,0))
							ModalItem();
						break;
					case BO_LOG :
						if(OpenFileselector(GetAnything,string_addr[FSEL_GETLOGFILE],
								path,std_paths,file_mask,0))
							ModalItem();
						break;
				}
			}
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case BO_OK :
				changed=TRUE;
				mgx_cookies=atol(tree[BO_COOKIES].ob_spec.tedinfo->te_ptext);
				strcpy(mgx_image,tree[BO_IMAGE].ob_spec.tedinfo->te_ptext);
				strcpy(mgx_bootlog,tree[BO_LOG].ob_spec.tedinfo->te_ptext);
				strcpy(mgx_tiles,tree[BO_TILES].ob_spec.tedinfo->te_ptext);
			case BO_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}



	
